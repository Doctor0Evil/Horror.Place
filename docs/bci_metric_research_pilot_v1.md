# BCI → Metric Pilot Contract v1
## Cross-Repo Research Object (Neural-Resonance-Lab + Redacted-Chronicles)

### 1. Purpose

This pilot contract defines a minimal, shared shape for BCI payloads and a simple rule set for mapping BCI-derived fear indices to entertainment metrics (UEC, ARR, CDL) during early Horror$Place experiments.[file:10][file:11][file:20]

It is intentionally small and conservative so that:
- **HorrorPlace-Neural-Resonance-Lab** can implement and test BCI adapters quickly.
- **HorrorPlace-Redacted-Chronicles** can log and summarize results using a common schema.
- Future, more complex contracts can build on this without breaking early data.[file:10][file:11]

### 2. BCI Payload Schema (Conceptual)

All labs MUST treat a single BCI sample as an object of the following shape before any repo-specific extensions:

```jsonc
{
  "session_id": "string",        // local-only identifier, Tier-3 only
  "t": 0.0,                      // seconds since session start
  "region_id": "string",         // matches invariants region_id
  "event_id": "string | null",   // optional, current Surprise.Event! ID
  "fear_index": 0.0,             // 0.0–1.0 normalized
  "arousal": 0.0,                // -1.0 (low) to 1.0 (high)
  "valence": 0.0,                // -1.0 (negative) to 1.0 (positive)
  "source": "eeg|face|mixed",    // modality used
  "confidence": 0.0              // 0.0–1.0 confidence in this reading
}
```

Tier-1 does not store these raw payloads; they only exist in Tier-3 repos and derived summaries.[file:10][file:11]

### 3. Minimal BCI → Intensity Modes

For the first 4–8 weeks of research, all participating labs MUST agree on three coarse "intensity modes" computed from BCI payloads:

- `UNDERSTIMULATED`
- `OPTIMAL_STRESS`
- `OVERWHELMED`

A reference rule (Neural-Resonance-Lab may refine internally, but output MUST match):

- If `fear_index < 0.2` and `confidence >= 0.5` → `UNDERSTIMULATED`.
- If `0.2 <= fear_index <= 0.8` and `confidence >= 0.5` → `OPTIMAL_STRESS`.
- If `fear_index > 0.8` and `confidence >= 0.5` → `OVERWHELMED`.
- If `confidence < 0.5` → carry forward last known mode or treat as `OPTIMAL_STRESS` fallback.

These modes are what the Director and Surprise.Events! logic read, NOT raw fear values, for v1 experiments.[file:20][file:11]

### 4. Metric Adjustment Rules (Pilot)

When mapping intensity modes to entertainment metrics, the following target tendencies apply:

- `UNDERSTIMULATED`:
  - Aim to **raise UEC** (uncertainty) by adding mild anomalies or clues.
  - Avoid large STCI spikes (no big attacks), keep CDL modest.
- `OPTIMAL_STRESS`:
  - Maintain current UEC and ARR; choose events that **reinforce** but do not radically alter CDL.
- `OVERWHELMED`:
  - Aim to **reduce STCI** in the next 10–30 seconds (fewer shocks).
  - Allow ARR to rise slightly (more ambiguity) by delaying direct clarifications.
  - DO NOT schedule new Shock-phase Surprise.Events! while in this mode.[file:11][file:20]

Labs are free to experiment with concrete implementations, but research logs MUST record:
- Timestamped intensity mode transitions.
- Local UEC/ARR/CDL estimates before and after applying these rules.

### 5. Telemetry Summary Requirements

For every agent or event configuration tested under this pilot:

Tier-3 labs MUST be able to emit a Tier-1-safe summary of this form:

```jsonc
{
  "agent_id": "string",
  "event_id": "string | null",
  "region_band": {
    "CIC": "low|mid|high",
    "AOS": "low|mid|high",
    "LSG": "low|mid|high"
  },
  "samples": 42,
  "mean_delta_UEC": 0.12,
  "mean_delta_ARR": 0.05,
  "mean_delta_CDL": 0.08,
  "mode_time_fraction": {
    "UNDERSTIMULATED": 0.20,
    "OPTIMAL_STRESS": 0.65,
    "OVERWHELMED": 0.15
  }
}
```

No raw BCI traces or per-subject identifiers may appear in Tier-1-visible files.[file:10][file:11]

### 6. Immediate Implementation Targets

- **Neural-Resonance-Lab**:
  - Implement the intensity mode logic in Lua and produce at least one local test log today using synthetic data.
- **Redacted-Chronicles**:
  - Implement a script that reads raw BCI logs and emits a `bci_metric_summary_v1` JSON object as above.
- **Liminal-Continuum**:
  - Prepare to ingest `bci_metric_summary_v1` objects for future agent ranking.
- **Obscura-Nexus / Process-Gods-Research**:
  - Tag any early experiments with `region_band` fields so their telemetry can be consumed by this pilot.

This pilot can be adopted immediately without changing any horror content. It only defines how to **talk about** BCI, intensity, and metrics in a shared, machine-checkable way.
