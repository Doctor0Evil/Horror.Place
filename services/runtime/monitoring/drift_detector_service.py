#!/usr/bin/env python3
"""
drift_detector_service.py
Continuous Contract-Drift Monitoring Service
────────────────────────────────────────────
Runs in the Unreal Editor background or playtest runtime to sample live metrics,
compare them against the active contractCard bands, and emit structured warnings
when values drift beyond configured thresholds. Aligns with Aral-Seam post-Soviet
tension pacing and Ice-Pick Lodge "intentional discomfort" design philosophy.
"""

import time
import logging
import threading
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional, Tuple
from enum import Enum

logging.basicConfig(level=logging.INFO, format="[DRIFT-DET] %(levelname)s: %(message)s")

class DriftSeverity(str, Enum):
    NOMINAL = "nominal"
    WARNING = "warning"
    CRITICAL = "critical"

@dataclass
class MetricSample:
    metric_name: str
    value: float
    timestamp: float
    context: Dict[str, str] = field(default_factory=dict)

@dataclass
class DriftReport:
    severity: DriftSeverity
    metric: str
    observed: float
    expected_band: Tuple[float, float]
    drift_pct: float
    suggestion: str

class DriftDetector:
    """
    Thread-safe service that polls live metric streams, normalizes them,
    and checks against contractCard metric envelopes.
    """
    def __init__(self, poll_interval_ms: int = 500, warning_thresh: float = 0.10, critical_thresh: float = 0.25):
        self.poll_interval = poll_interval_ms / 1000.0
        self.warning_thresh = warning_thresh
        self.critical_thresh = critical_thresh
        self._contract: Optional[Dict] = None
        self._running = False
        self._thread: Optional[threading.Thread] = None
        self._callbacks: List[Callable[[DriftReport], None]] = []
        self._latest_report: Optional[DriftReport] = None

    def load_contract(self, contract: Dict) -> None:
        """Bind the detector to an active contractCard."""
        self._contract = contract["metrics"]
        logging.info(f"Contract loaded. Monitoring bands: {list(self._contract.keys())}")

    def register_callback(self, fn: Callable[[DriftReport], None]) -> None:
        """Attach UI logger, telemetry hook, or auto-correct trigger."""
        self._callbacks.append(fn)

    def _simulate_live_stream(self) -> Dict[str, float]:
        """
        PLACEHOLDER: Replace with Unreal Engine C++ bridge or Lua runtime hook.
        Returns normalized 0.0-1.0 metrics for the current frame.
        """
        import random
        return {
            "UEC": random.uniform(0.55, 0.80),
            "EMD": random.uniform(0.40, 0.70),
            "STCI": random.uniform(0.05, 0.25),
            "CDL": random.uniform(0.10, 0.45),
            "ARR": random.uniform(0.75, 0.95)
        }

    def _evaluate_drift(self, live: Dict[str, float]) -> Optional[DriftReport]:
        if not self._contract:
            return None
            
        for metric, band in self._contract.items():
            val = live.get(metric, 0.0)
            mn, mx = band
            if mn <= val <= mx:
                continue
                
            mid = (mn + mx) / 2
            drift = abs(val - mid) / ((mx - mn) / 2)
            severity = DriftSeverity.CRITICAL if drift > self.critical_thresh else DriftSeverity.WARNING
            
            suggestion = self._generate_suggestion(metric, val, band)
            report = DriftReport(severity, metric, val, (mn, mx), drift, suggestion)
            self._latest_report = report
            
            for cb in self._callbacks:
                cb(report)
            return report
        return None

    def _generate_suggestion(self, metric: str, val: float, band: Tuple[float, float]) -> str:
        """Doctrine-aligned remediation hints based on Aral-Sea horror pacing."""
        mn, mx = band
        if val > mx:
            return f"{metric} exceeded. Reduce overt events, convert to 'almost-event' chain, or lower audio intensity."
        return f"{metric} below band. Increase environmental evidence density or extend liminal transition zones."

    def start(self) -> None:
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._poll_loop, daemon=True)
        self._thread.start()
        logging.info("Drift detector started.")

    def stop(self) -> None:
        self._running = False
        if self._thread:
            self._thread.join()
        logging.info("Drift detector stopped.")

    def _poll_loop(self) -> None:
        while self._running:
            try:
                live_metrics = self._simulate_live_stream()
                self._evaluate_drift(live_metrics)
            except Exception as e:
                logging.error(f"Drift polling error: {e}")
            time.sleep(self.poll_interval)

if __name__ == "__main__":
    # Example integration
    det = DriftDetector(poll_interval_ms=1000)
    det.load_contract({
        "metrics": {
            "UEC": [0.55, 0.75], "EMD": [0.45, 0.65], "STCI": [0.0, 0.2],
            "CDL": [0.0, 0.3], "ARR": [0.8, 1.0]
        }
    })
    det.register_callback(lambda r: logging.warning(f"DRIFT: {r.metric} → {r.observed:.2f} | {r.suggestion}"))
    det.start()
    time.sleep(5)
    det.stop()
