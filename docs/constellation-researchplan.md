# HorrorPlace VM Constellation Research Plan v1

## 1. Architectural Doctrine
The HorrorPlace VM operates as a distributed, ledger-governed entertainment engine. Core invariants and entertainment metrics dictate system state, while the Dead-Ledger provides immutable attestation for all first-class artifacts (agents, seeds, bundles). All cross-repo communication adheres to strict schema contracts; internal research documents may iterate freely provided their outputs collapse into spine formats before crossing repository boundaries.

## 2. Tier Architecture
- **Tier 1 (Horror.Place)**: Canonical schema definitions, invariant/metric doctrine, orchestrator routing rules, and public API surfaces.
- **Tier 2 (Codebase-of-Death, Liminal-Continuum, Obscura-Nexus, Redacted-Chronicles)**: Content generation, marketplace validation, style experimentation, and telemetry compression. Operates on redacted summaries and derived BCI states.
- **Tier 3 (Neural-Resonance-Lab, Process-Gods-Research, Black-Archivum, Spectral-Foundry)**: Raw physiology ingestion, high-SHCI process modeling, normalized trauma archives, and spectral persona generation. Strictly isolated from external surfaces.

## 3. Invariant & Metric Framework
### Core Invariants
`SHCI`, `CIC`, `AOS`, `SPR`, `RRM`, `HVF`, `LSG`, `DET` (normalized 0.0–1.0, HVF -1.0–1.0). Govern system tension, predictability, and environmental coupling.

### Entertainment Metrics
`UEC` (Uncertainty Expectancy Curve), `EMD` (Emotional Micro-Dynamics), `STCI` (Surprise-Tension-Cognitive Inhibition), `CDL` (Contextual Dread Latency), `ARR` (Arousal-Response Resonance). Tracked per session phase and mapped to style/BCI adjustments.

## 4. Dead-Ledger Protocol Surface
All artifacts are anchored via `deadledgerref` (pattern: `^dl-[a-f0-9]{64}$`). Attestation families:
- Bundle: `ledgerentrybundleattestationv1.json`
- Agent: `ledgerentryagentattestationv1.json`
- Spectral Seed: `ledgerentryspectralseedattestationv1.json`
Proof types: `agegating`, `charteragreement`, `alnmembership`, `bcistate`. Verification executed via orchestrator CI before marketplace ingestion or runtime entitlement grants.

## 5. BCI Parameterization Strategy
Raw physiology never leaves Tier 3. Neural-Resonance-Lab computes derived states (`fear_band`, `overload_flag`, `comfort_band`, `challenge_band`) and publishes `bciseedv1.json` profiles. Runtime consumes only derived ranges via `Policy.DeadLedger.*` and `BCI.*` APIs. Iteration on mapping algorithms does not require ledger or schema changes.

## 6. Security & Redaction Pipeline
Three-stage compression: Ingestion (Tier 3 validation) → Redaction (field stripping, threshold capping, bucketing) → Projection (Tier-2 summary emission). Hard caps on overload duration and entropy checks prevent synthetic/stale data propagation. All summaries hash-linked to Dead-Ledger for auditability.

## 7. Phased Execution Roadmap
- **Phase 1 (Spine Lock)**: Finalize JSON schemas, Lua runtime contract, orchestrator CI, and verifier registry. Block all non-spine merges.
- **Phase 2 (Telemetry Bootstrap)**: Deploy headless sim runners, activate redaction pipeline, validate BCI proof routing, run end-to-end agent ranking loop.
- **Phase 3 (Experimentation)**: Process-god matrices, style-metric mappings, neuro-responsive event tuning. All outputs feed back into Dead-Ledger provenance and marketplace ranking.
