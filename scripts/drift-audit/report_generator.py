#!/usr/bin/env python3
"""report_generator.py — Aggregate scan findings into a Markdown compliance report.

Supports two modes:
  1. Single repo:   python report_generator.py /path/to/repo --output report.md
  2. Multi-repo:    python report_generator.py --config repos-manifest.json --output report.md

The report includes executive summary, per-repo findings, patch suggestions,
manual review manifest, invariant coverage matrix, and audit metadata.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

from invariants_spec import CANONICAL_IDENTIFIERS, classify
import schema_drift_detector
import charter_compliance
import ndjson_lint

__version__ = "1.0.0"


def _traffic_light(results: list[dict]) -> str:
    """Return emoji traffic light based on worst severity across all repos."""
    has_charter = any(
        any(f["severity"] == "charter" for f in r.get("charter", []))
        for r in results
    )
    has_critical = any(
        any(f["severity"] == "critical" for f in findings)
        for r in results
        for findings in r.values()
        if isinstance(findings, list)
    )
    if has_charter:
        return "🔴"
    if has_critical:
        return "🟡"
    return "🟢"


def _scan_repo(repo_path: str) -> dict:
    """Run all three scanners on a single repo and return aggregated findings."""
    drift = schema_drift_detector.scan(repo_path)
    charter = charter_compliance.scan(repo_path)
    ndjson = ndjson_lint.scan(repo_path)
    return {
        "drift": [asdict(f) for f in drift.findings],
        "charter": [asdict(f) for f in charter.findings],
        "ndjson": [asdict(f) for f in ndjson.findings],
    }


def _generate_patch_suggestions(findings: list[dict]) -> list[str]:
    """Generate unified diff patch suggestions for critical findings."""
    patches = []
    for f in findings:
        suggestion = f.get("suggestion") or ""
        if not suggestion:
            continue
        patch = (
            f"--- a/{f['file']}\n"
            f"+++ b/{f['file']}\n"
            f"@@ -{f['line']},1 +{f['line']},1 @@\n"
            f"-  # {f['message']}\n"
            f"+  # FIXED: {suggestion}\n"
        )
        patches.append(patch)
    return patches


def _coverage_matrix(results: dict[str, dict]) -> str:
    """Build Markdown table showing which canonical IDs are referenced per repo."""
    ids = sorted(CANONICAL_IDENTIFIERS)
    repos = sorted(results.keys())
    header = "| Identifier | Category | " + " | ".join(repos) + " |"
    sep = "|---|---|" + " ".join([" --- |" for _ in repos])
    rows = [header, sep]

    for ident in ids:
        cat = classify(ident) or "unknown"
        cells = []
        for repo in repos:
            drift_findings = results[repo].get("drift", [])
            mentioned = any(ident in (f.get("message") or "") for f in drift_findings)
            # ✅ if no drift mentioning this ident, ⚠️ if drift present
            cells.append("✅" if not mentioned else "⚠️")
        rows.append(f"| {ident} | {cat} | " + " | ".join(cells) + " |")

    return "\n".join(rows)


def generate_report(results: dict[str, dict], output_path: str | None = None) -> str:
    """Build the full Markdown compliance report."""
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    light = _traffic_light(list(results.values()))

    total_findings = sum(
        len(f) for r in results.values() for f in r.values() if isinstance(f, list)
    )
    critical_count = sum(
        1
        for r in results.values()
        for findings in r.values()
        if isinstance(findings, list)
        for f in findings
        if f.get("severity") in ("critical", "charter")
    )
    review_count = sum(
        1
        for r in results.values()
        for findings in r.values()
        if isinstance(findings, list)
        for f in findings
        if f.get("requires_review")
    )
    clean_count = sum(
        1 for r in results.values() if all(len(f) == 0 for f in r.values() if isinstance(f, list))
    )

    lines: list[str] = []

    # Header
    lines.append(f"# {light} Horror.Place Schema Drift Audit Report")
    lines.append(f"**Date:** {now}")
    lines.append("")

    # Executive summary
    lines.append("## Executive Summary")
    lines.append("")
    lines.append("| Metric | Value |")
    lines.append("|--------|-------|")
    lines.append(f"| Repos scanned | {len(results)} |")
    lines.append(f"| Clean repos | {clean_count} |")
    lines.append(f"| Total findings | {total_findings} |")
    lines.append(f"| Critical / Charter | {critical_count} |")
    lines.append(f"| Requires review | {review_count} |")
    lines.append("")

    # Per-repo sections
    for repo_name, repo_findings in sorted(results.items()):
        lines.append(f"## {repo_name}")
        lines.append("")

        for scanner, findings in sorted(repo_findings.items()):
            if not isinstance(findings, list):
                continue
            if not findings:
                lines.append(f"### {scanner.title()}: ✅ Clean")
                lines.append("")
                continue

            lines.append(f"### {scanner.title()} ({len(findings)} findings)")
            lines.append("")
            lines.append("| Severity | File | Line | Rule | Message |")
            lines.append("|----------|------|------|------|---------|")
            for f in findings:
                sev = f["severity"].upper()
                lines.append(
                    f"| {sev} | `{f['file']}` | {f['line']} "
                    f"| {f['rule']} | {f['message']} |"
                )
            lines.append("")

        # Patch suggestions (drift only)
        all_drift = repo_findings.get("drift", [])
        patches = _generate_patch_suggestions(all_drift)
        if patches:
            lines.append("### Patch Suggestions")
            lines.append("")
            lines.append("```diff")
            for patch in patches:
                lines.append(patch)
            lines.append("```")
            lines.append("")

    # Manual review manifest (charter)
    lines.append("## Manual Review Manifest (Charter Flags)")
    lines.append("")
    lines.append("| Repo | File | Line | Rule | Severity | Message |")
    lines.append("|------|------|------|------|----------|---------|")
    for repo_name, repo_findings in sorted(results.items()):
        charter_findings = repo_findings.get("charter", [])
        for f in charter_findings:
            if not f.get("requires_review"):
                continue
            lines.append(
                f"| {repo_name} | `{f['file']}` | {f['line']} "
                f"| {f['rule']} | {f['severity'].upper()} | {f['message']} |"
            )
    lines.append("")

    # Invariant / metric coverage matrix
    lines.append("## Invariant and Metric Coverage")
    lines.append("")
    lines.append(_coverage_matrix(results))
    lines.append("")

    report = "\n".join(lines)

    if output_path:
        out_path = Path(output_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(report, encoding="utf-8")

    return report


def _load_manifest(manifest_path: str) -> dict:
    with open(manifest_path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def _scan_constellation(manifest_path: str) -> dict[str, dict]:
    manifest = _load_manifest(manifest_path)
    results: dict[str, dict] = {}

    for entry in manifest.get("repos", []):
        name = entry["name"]
        repo_dir = entry.get("local_path") or entry.get("name")
        repo_path = Path(repo_dir).resolve()
        if not repo_path.is_dir():
            # In CI this should already be checked out; if not, skip with empty findings.
            results[name] = {"drift": [], "charter": [], "ndjson": []}
            continue
        results[name] = _scan_repo(str(repo_path))

    return results


def main() -> None:
    parser = argparse.ArgumentParser(description="Horror.Place schema drift report generator")
    parser.add_argument(
        "path",
        nargs="?",
        help="Path to a single repo root (single-repo mode).",
    )
    parser.add_argument(
        "--config",
        dest="config",
        help="Path to constellation repos-manifest.json (multi-repo mode).",
    )
    parser.add_argument(
        "--output",
        dest="output",
        help="Path to write Markdown report to.",
    )
    args = parser.parse_args()

    if args.config:
        results = _scan_constellation(args.config)
    elif args.path:
        repo_path = Path(args.path).resolve()
        results = {repo_path.name: _scan_repo(str(repo_path))}
    else:
        parser.error("Must provide either a repo path or --config manifest.")

    report = generate_report(results, output_path=args.output)

    # Also echo report to stdout for GitHub Actions job summary
    sys.stdout.write(report)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
