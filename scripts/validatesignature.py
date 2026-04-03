#!/usr/bin/env python3
"""
Signature validation entrypoint for Horror.Place CI.

Responsibilities:
- Load a signature JSON document from disk.
- Validate it against core/schemas/signaturev1.json (Draft 2020-12).
- Enforce basic invariants not expressible purely in JSON Schema.
- Provide well-structured failure messages for CI.
- Prepare hooks for Dead-Ledger / ALN integration (SessionRegistry, CapabilityAttestor, PolicyGuard).

This script is intended to be called from GitHub Actions / CircleCI as a required gate
before any generator runs for core schemas, registries, or other canonical artifacts.
"""

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict

try:
    import jsonschema
except ImportError:
    print("ERROR: jsonschema package is required to run validatesignature.py", file=sys.stderr)
    sys.exit(2)


def load_json(path: Path) -> Dict[str, Any]:
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERROR: Signature file not found: {path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"ERROR: Failed to parse JSON from {path}: {e}", file=sys.stderr)
        sys.exit(1)


def load_schema(repo_root: Path) -> Dict[str, Any]:
    schema_path = repo_root / "core" / "schemas" / "signaturev1.json"
    try:
        with schema_path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERROR: Signature schema not found at {schema_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"ERROR: Failed to parse signature schema JSON: {e}", file=sys.stderr)
        sys.exit(1)


def validate_against_schema(signature: Dict[str, Any], schema: Dict[str, Any]) -> None:
    try:
        jsonschema.validate(instance=signature, schema=schema)
    except jsonschema.exceptions.ValidationError as e:
        print("ERROR: Signature failed JSON Schema validation.", file=sys.stderr)
        print(f"- Path: {'/'.join(map(str, e.path))}", file=sys.stderr)
        print(f"- Message: {e.message}", file=sys.stderr)
        sys.exit(1)


def parse_iso8601(dt: str, field_name: str) -> datetime:
    try:
        parsed = datetime.fromisoformat(dt.replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=timezone.utc)
        return parsed
    except Exception:
        print(f"ERROR: Field {field_name} must be a valid ISO 8601 datetime, got: {dt}", file=sys.stderr)
        sys.exit(1)


def validate_time_bounds(signature: Dict[str, Any]) -> None:
    issued_at = parse_iso8601(signature["issued_at"], "issued_at")
    expires_at = parse_iso8601(signature["expires_at"], "expires_at")

    if expires_at <= issued_at:
        print("ERROR: expires_at must be strictly greater than issued_at.", file=sys.stderr)
        sys.exit(1)

    now = datetime.now(timezone.utc)
    if now > expires_at:
        print("ERROR: Signature has expired.", file=sys.stderr)
        sys.exit(1)


def validate_envelopes(signature: Dict[str, Any]) -> None:
    inv_env = signature.get("invariant_envelope", {})
    met_env = signature.get("metric_envelope", {})

    def check_range(obj: Dict[str, Any], key: str) -> None:
        r = obj.get(key)
        if not isinstance(r, dict):
            print(f"ERROR: invariant/metric envelope for {key} must be an object with min and max.", file=sys.stderr)
            sys.exit(1)
        min_v = r.get("min")
        max_v = r.get("max")
        if not isinstance(min_v, (int, float)) or not isinstance(max_v, (int, float)):
            print(f"ERROR: invariant/metric envelope for {key} must have numeric min and max.", file=sys.stderr)
            sys.exit(1)
        if not (0.0 <= min_v <= 1.0 and 0.0 <= max_v <= 1.0):
            print(f"ERROR: invariant/metric envelope for {key} must be within [0.0, 1.0].", file=sys.stderr)
            sys.exit(1)
        if max_v < min_v:
            print(f"ERROR: invariant/metric envelope for {key} has max < min.", file=sys.stderr)
            sys.exit(1)

    for key in ["CIC", "MDI", "AOS", "RRM", "FCF", "SPR", "RWF", "DET", "HVF", "LSG", "SHCI"]:
        check_range(inv_env, key)

    for key in ["UEC", "EMD", "STCI", "CDL", "ARR"]:
        check_range(met_env, key)


def validate_operation_scope(signature: Dict[str, Any]) -> None:
    op = signature["operation"]
    target_path = signature["target_path"]
    contract_type = signature["contract_type"]

    if op == "validate_only" and not target_path:
        print("ERROR: validate_only operation requires a target_path.", file=sys.stderr)
        sys.exit(1)

    if contract_type == "registry_entry" and not target_path.startswith("core/registry/"):
        print("ERROR: registry_entry contract_type must target core/registry/ paths.", file=sys.stderr)
        sys.exit(1)


def validate_basic_policy_fields(signature: Dict[str, Any]) -> None:
    policy_profile = signature["policy_profile"]
    entitlement_tier = signature["entitlement_tier"]

    if policy_profile.strip() == "":
        print("ERROR: policy_profile must be a non-empty string.", file=sys.stderr)
        sys.exit(1)

    if entitlement_tier not in ["tier1_core", "tier2_vault", "tier3_lab"]:
        print("ERROR: entitlement_tier must be one of tier1_core, tier2_vault, tier3_lab.", file=sys.stderr)
        sys.exit(1)


def validate_constraints_hash_shape(signature: Dict[str, Any]) -> None:
    constraints_hash = signature["constraints_hash"]
    if not isinstance(constraints_hash, str):
        print("ERROR: constraints_hash must be a hex string.", file=sys.stderr)
        sys.exit(1)
    if len(constraints_hash) != 64:
        print("ERROR: constraints_hash must be a 64-character hex string.", file=sys.stderr)
        sys.exit(1)
    try:
        int(constraints_hash, 16)
    except ValueError:
        print("ERROR: constraints_hash must contain only hex characters.", file=sys.stderr)
        sys.exit(1)


def validate_signature(signature: Dict[str, Any], schema: Dict[str, Any]) -> None:
    validate_against_schema(signature, schema)
    validate_time_bounds(signature)
    validate_envelopes(signature)
    validate_operation_scope(signature)
    validate_basic_policy_fields(signature)
    validate_constraints_hash_shape(signature)
    # Hooks for Dead-Ledger / ALN integration:
    # - validate_session_with_dead_ledger(signature)
    # - validate_capability_token(signature)
    # - validate_policy_with_aln(signature)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate a Horror.Place first-pass signature before generation."
    )
    parser.add_argument(
        "--signature",
        required=True,
        help="Path to the signature JSON file."
    )
    parser.add_argument(
        "--repo-root",
        required=False,
        help="Path to the repository root (defaults to current working directory)."
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    sig_path = Path(args.signature).resolve()
    repo_root = Path(args.repo_root).resolve() if args.repo_root else Path.cwd().resolve()

    signature = load_json(sig_path)
    schema = load_schema(repo_root)

    validate_signature(signature, schema)

    print("Signature validation passed.")
    sys.exit(0)


if __name__ == "__main__":
    main()
