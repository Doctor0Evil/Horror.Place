#!/usr/bin/env python3
"""
telemetry_research_loop.py
Horror.Place Playtest & Editor Telemetry Correlation Engine
────────────────────────────────────────────────────────────
Ingests structured telemetry events, correlates them with active contractCards,
identifies failure cases (low UEC / high CDL burnout), and surfaces evidence-backed
recommendations for AI-Chat refinement. Aligns with the "prompt → contract → telemetry"
research trajectory.
"""

import json
import logging
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from collections import defaultdict

logging.basicConfig(level=logging.INFO, format="[TELEMETRY] %(levelname)s: %(message)s")

@dataclass
class ContractPerformance:
    contract_id: str
    avg_uec: float
    avg_arr: float
    burnout_incidents: int
    failure_zones: List[str]
    recommendation: str

class TelemetryLoop:
    """
    Processes playtest logs, maps player behavior to contract metrics,
    and generates research-grade insights for AI-Chat training.
    """
    def __init__(self, log_dir: Path, schema_path: Optional[Path] = None):
        self.log_dir = log_dir
        self.events: List[Dict] = []
        self.contract_map: Dict[str, Any] = {}
        self.failure_db: List[Dict] = []
        
    def load_logs(self) -> int:
        """Parse JSONL telemetry dumps from playtest sessions."""
        count = 0
        for log_file in self.log_dir.glob("*.jsonl"):
            with open(log_file, "r", encoding="utf-8") as f:
                for line in f:
                    try:
                        evt = json.loads(line)
                        if evt.get("event_type") in ("playtest_metric_sample", "player_behavior_event"):
                            self.events.append(evt)
                            count += 1
                    except json.JSONDecodeError:
                        continue
        logging.info(f"Loaded {count} telemetry events from {self.log_dir}")
        return count

    def correlate_contract_performance(self) -> Dict[str, ContractPerformance]:
        """Aggregate metrics by contractId and compute performance indicators."""
        contract_metrics: Dict[str, List[Dict]] = defaultdict(list)
        for evt in self.events:
            cid = evt.get("session_context", {}).get("contract_card_snapshot", {}).get("title", "unknown")
            if cid != "unknown":
                contract_metrics[cid].append(evt)

        results: Dict[str, ContractPerformance] = {}
        for cid, evts in contract_metrics.items():
            uec_vals = [e.get("metric_samples", {}).get("UEC", {}).get("value", 0.0) for e in evts if "metric_samples" in e]
            arr_vals = [e.get("metric_samples", {}).get("ARR", {}).get("value", 0.0) for e in evts if "metric_samples" in e]
            burnouts = sum(1 for e in evts if e.get("behavior_markers") and "panic_movement" in e.get("behavior_markers", []))
            
            avg_uec = sum(uec_vals) / len(uec_vals) if uec_vals else 0.0
            avg_arr = sum(arr_vals) / len(arr_vals) if arr_vals else 0.0
            
            rec = "Stable. Maintains tension without exhaustion."
            if avg_uec < 0.45 and burnouts > 3:
                rec = "⚠️ High burnout risk. Lower DET, increase ambiguous evidence (EMD), reduce overt triggers."
            elif avg_arr < 0.75:
                rec = "📉 Low retention. Players disengage. Increase narrative ambiguity (ARR) and safe-threat contrast (STCI)."
                
            results[cid] = ContractPerformance(
                contract_id=cid, avg_uec=avg_uec, avg_arr=avg_arr,
                burnout_incidents=burnouts, failure_zones=[], recommendation=rec
            )
        return results

    def flag_failure_cases(self, threshold_uec: float = 0.40, threshold_cdl: float = 0.85) -> List[Dict]:
        """Identify sessions where metrics breached doctrinal safety caps."""
        failures = []
        for evt in self.events:
            m = evt.get("metric_samples", {})
            if m.get("UEC", {}).get("value", 1.0) < threshold_uec or \
               m.get("CDL", {}).get("value", 0.0) > threshold_cdl:
                failures.append(evt)
                self.failure_db.append({
                    "timestamp": evt.get("timestamp"),
                    "contract": evt.get("contract_card_snapshot", {}).get("title"),
                    "observed_uec": m.get("UEC", {}).get("value"),
                    "observed_cdl": m.get("CDL", {}).get("value")
                })
        logging.warning(f"Flagged {len(failures)} failure-case events for research review.")
        return failures

    def generate_ai_training_dataset(self, output_path: Path) -> None:
        """Export structured prompt→contract→telemetry mappings for model fine-tuning."""
        dataset = []
        for fail in self.failure_db:
            dataset.append({
                "instruction": f"Adjust contract '{fail['contract']}' to recover engagement.",
                "input": json.dumps({
                    "current_uec": fail["observed_uec"],
                    "current_cdl": fail["observed_cdl"]
                }),
                "output": "Reduce CDL by 0.15, increase EMD band by 0.1, convert one overt event to almost-event chain."
            })
            
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(dataset, f, indent=2)
        logging.info(f"✅ AI training dataset exported to {output_path}")

if __name__ == "__main__":
    # Example run
    pipeline = TelemetryLoop(log_dir=Path("./telemetry_logs"))
    pipeline.load_logs()
    perf = pipeline.correlate_contract_performance()
    for cid, data in perf.items():
        logging.info(f"[{cid}] UEC: {data.avg_uec:.2f} | ARR: {data.avg_arr:.2f} | {data.recommendation}")
    pipeline.flag_failure_cases()
    pipeline.generate_ai_training_dataset(Path("./research/ai_contract_refinements.json"))
