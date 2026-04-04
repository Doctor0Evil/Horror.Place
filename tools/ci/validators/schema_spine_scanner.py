#!/usr/bin/env python3
"""
schema_spine_scanner.py
Horror.Place CI Pre-Commit Validator
────────────────────────────────────
Enforces the Horror.Place doctrine by validating signature documents against 
JSON Schemas, verifying the Subset Rule (contractCard invariants/metrics vs 
envelopes), and ensuring deadledgerref anchoring before commit acceptance.

Usage:
    python schema_spine_scanner.py --signature path/to/signature.json --schema-dir ./schemas
"""

import argparse
import json
import logging
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

try:
    import jsonschema
    from jsonschema import validate, ValidationError, Draft202012Validator
except ImportError:
    logging.error("Missing dependency: pip install jsonschema")
    sys.exit(1)

logging.basicConfig(
    level=logging.INFO,
    format="[SCHEMA-SCANNER] %(levelname)s: %(message)s"
)

class SignatureValidator:
    """Validates Horror.Place signatures against doctrine schemas and envelope rules."""
    
    def __init__(self, schema_dir: Path):
        self.schema_dir = schema_dir.resolve()
        self.schemas: Dict[str, Any] = {}
        self._load_schemas()
        
    def _load_schemas(self) -> None:
        """Load all referenced JSON Schemas into memory."""
        schema_files = {
            "contract_card": self.schema_dir / "core/contracts/coreschemascontractcardv1.json",
            "signature": self.schema_dir / "core/signatures/coreschemassignaturev1.json"
        }
        for name, path in schema_files.items():
            if not path.exists():
                raise FileNotFoundError(f"Missing schema: {path}")
            with open(path, "r", encoding="utf-8") as f:
                self.schemas[name] = json.load(f)
                
    def validate_structure(self, signature: Dict[str, Any]) -> List[str]:
        """Validate raw JSON structure against signature schema."""
        errors: List[str] = []
        try:
            validate(instance=signature, schema=self.schemas["signature"])
        except ValidationError as e:
            errors.append(f"Schema violation: {e.message} at {list(e.path)}")
        return errors

    def _check_subset_rule(self, sig: Dict[str, Any]) -> List[str]:
        """Ensure contractCard values lie strictly within signature envelopes."""
        errors: List[str] = []
        card_inv = sig["contractCard"]["invariants"]
        card_met = sig["contractCard"]["metrics"]
        env_inv = sig["invariantenvelope"]
        env_met = sig["metricenvelope"]

        for key in ("CIC", "AOS", "RRM", "LSG", "DET", "SHCI"):
            val = card_inv[key]
            mn, mx = env_inv[key]["min"], env_inv[key]["max"]
            if not (mn <= val <= mx):
                errors.append(f"Subset rule violation: {key}={val} outside envelope [{mn}, {mx}]")

        for key in ("UEC", "EMD", "STCI", "CDL", "ARR"):
            band = card_met[key]
            env_band = env_met[key]
            if band != env_band:
                errors.append(f"Band match violation: {key} {band} != envelope {env_band}")
                
        return errors

    def _check_deadledger_anchor(self, sig: Dict[str, Any]) -> List[str]:
        """Ensure deadledgerref matches expected pattern and exists in registry."""
        errors: List[str] = []
        ref = sig.get("contractCard", {}).get("deadledgerref")
        if not ref or not ref.startswith("deadledger://"):
            errors.append("Missing or malformed deadledgerref in contractCard")
        # TODO: Integrate with Dead-Ledger API for live existence check
        return errors

    def validate(self, signature_path: Path) -> Tuple[bool, List[str]]:
        """Run full validation suite. Returns (is_valid, errors)."""
        with open(signature_path, "r", encoding="utf-8") as f:
            signature = json.load(f)
            
        errors = self.validate_structure(signature)
        errors.extend(self._check_subset_rule(signature))
        errors.extend(self._check_deadledger_anchor(signature))
        
        return len(errors) == 0, errors

def main() -> None:
    parser = argparse.ArgumentParser(description="Horror.Place Schema Spine Scanner")
    parser.add_argument("--signature", required=True, type=Path, help="Path to signature.json")
    parser.add_argument("--schema-dir", required=True, type=Path, help="Root directory of schemas")
    args = parser.parse_args()
    
    validator = SignatureValidator(args.schema_dir)
    valid, errors = validator.validate(args.signature)
    
    if not valid:
        logging.error("Commit BLOCKED. The following doctrine violations were detected:")
        for err in errors:
            logging.error(f"  ❌ {err}")
        sys.exit(1)
        
    logging.info("✅ Signature validated. Contract boundaries enforced. Commit allowed.")

if __name__ == "__main__":
    main()
