#!/usr/bin/env python3
"""
scripts/generate_report.py
Horror$Place Invariant Heatmap Generator

Reads NDJSON region seed files, calculates composite dread scores,
and outputs a CSV compatible with editor heatmap importers and CI telemetry.
"""

import argparse
import csv
import json
import sys
from pathlib import Path
from typing import Dict, List, Any

# Composite dread weighting (tunable per project, but kept in [0,1] bands)
WEIGHTS = {
    "CIC": 0.30,     # Catastrophic Imprint Coefficient
    "LSG": 0.25,     # Liminal Stress Gradient
    "HVF_mag": 0.20, # Haunt Vector Field magnitude
    "MDI": 0.15,     # Mythic Density Index
    "SPR": 0.10      # Spectral Plausibility Rating
}

REQUIRED_FIELDS = ["region_id", "tile_id", "tile_class"]
INVARIANT_FIELDS = [
    "CIC",
    "MDI",
    "AOS",
    "RRM",
    "FCF",
    "SPR",
    "SHCI",
    "LSG",
    "RWF",
    "DET",
    "HVF_mag"
]


def calculate_composite_dread(tile: Dict[str, Any]) -> float:
    """Calculate weighted composite dread score for heatmap coloring."""
    score = 0.0
    for field, weight in WEIGHTS.items():
        value = tile.get(field, 0.0)
        if isinstance(value, (int, float)):
            score += float(value) * float(weight)
    # Clamp to [0, 1] to respect invariant band conventions
    if score < 0.0:
        return 0.0
    if score > 1.0:
        return 1.0
    return score


def classify_zone(dread_score: float) -> str:
    """
    Map composite score to designer-friendly zone tags.

    These tags can be used in editors to quickly visualize safe vs. high-pressure
    regions, and in CI to enforce mood contracts for specific tile classes.
    """
    if dread_score >= 0.75:
        return "EXTREME_HAZARD"
    if dread_score >= 0.60:
        return "HIGH_DREAD"
    if dread_score >= 0.45:
        return "MODERATE_TENSION"
    return "LOW_STRESS"


def parse_ndjson(filepath: Path) -> List[Dict[str, Any]]:
    """
    Parse NDJSON file line-by-line with error recovery.

    Each non-empty line is expected to be a single JSON object representing
    one invariant bundle / seed row for a specific region_id + tile_id.
    """
    records: List[Dict[str, Any]] = []
    line_num = 0

    try:
        with filepath.open("r", encoding="utf-8") as handle:
            for raw_line in handle:
                line_num += 1
                stripped = raw_line.strip()
                if not stripped:
                    continue
                try:
                    obj = json.loads(stripped)
                    if not isinstance(obj, dict):
                        print(
                            f"[WARN] Line {line_num} in {filepath.name}: "
                            f"expected object, got {type(obj).__name__}",
                            file=sys.stderr,
                        )
                        continue
                    records.append(obj)
                except json.JSONDecodeError as exc:
                    print(
                        f"[WARN] Line {line_num} in {filepath.name}: {exc}",
                        file=sys.stderr,
                    )
    except OSError as exc:
        print(f"Error: Failed to read {filepath}: {exc}", file=sys.stderr)
        return []

    return records


def normalize_seed(seed: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normalize a raw seed object into a flat dict with required fields.

    Ensures missing invariants default to 0.0 so downstream tools can rely on
    numeric values without additional checks.
    """
    normalized: Dict[str, Any] = {}

    # Required identifiers (region_id, tile_id, tile_class)
    for key in REQUIRED_FIELDS:
        normalized[key] = seed.get(key)

    # Invariants of interest (default to 0.0)
    for key in INVARIANT_FIELDS:
        value = seed.get(key, 0.0)
        if isinstance(value, (int, float)):
            normalized[key] = float(value)
        else:
            normalized[key] = 0.0

    return normalized


def generate_csv(seeds: List[Dict[str, Any]], output_path: Path) -> None:
    """
    Write processed seed data to CSV format.

    Output columns are intentionally editor- and CI-friendly:
    identifiers, key invariants, composite_dread, and a zone tag.
    """
    headers = [
        "region_id",
        "tile_id",
        "tile_class",
        "CIC",
        "LSG",
        "HVF_mag",
        "MDI",
        "SPR",
        "composite_dread",
        "recommended_zone",
    ]

    try:
        with output_path.open("w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=headers)
            writer.writeheader()

            for raw_seed in seeds:
                seed = normalize_seed(raw_seed)
                composite = calculate_composite_dread(seed)
                row = {
                    "region_id": seed.get("region_id"),
                    "tile_id": seed.get("tile_id"),
                    "tile_class": seed.get("tile_class"),
                    "CIC": seed.get("CIC", 0.0),
                    "LSG": seed.get("LSG", 0.0),
                    "HVF_mag": seed.get("HVF_mag", 0.0),
                    "MDI": seed.get("MDI", 0.0),
                    "SPR": seed.get("SPR", 0.0),
                    "composite_dread": f"{composite:.4f}",
                    "recommended_zone": classify_zone(composite),
                }
                writer.writerow(row)
    except OSError as exc:
        print(f"Error: Failed to write CSV {output_path}: {exc}", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Generate invariant heatmap CSV from NDJSON seed packs "
            "for Horror$Place-compatible tools."
        )
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Path to .ndjson invariant seed file",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=None,
        help="Output CSV path (default: <input>.csv)",
    )
    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: Input file {args.input} not found.", file=sys.stderr)
        sys.exit(1)

    output_path = args.output or args.input.with_suffix(".csv")

    print(f"[*] Reading: {args.input}")
    seeds = parse_ndjson(args.input)
    if not seeds:
        print("[!] No valid seed records found.", file=sys.stderr)
        sys.exit(1)

    print(f"[*] Processing {len(seeds)} seed records...")
    generate_csv(seeds, output_path)
    print(f"[+] Heatmap exported: {output_path}")


if __name__ == "__main__":
    main()
