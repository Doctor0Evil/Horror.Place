# Horror.Place Seed Layer Specification (Tier‑1)

## 1. Purpose

The Seed layer defines the smallest history‑bound, engine‑consumable unit in Horror.Place: a single contract that links a region tile, a trauma bundle, a stage in a horror sequence, a precise invariant vector, and a set of entertainment metric targets. Seeds never contain raw historical detail. They are implication‑safe, schema‑validated descriptors that let engines, tools, and agents pull consistent, grounded horror behavior from the constellation without ever touching Black‑Archivum directly.

In the wider VM‑constellation, Seeds occupy the Tier‑1 public core. Black‑Archivum computes invariant bundles and cryptographically anchors them in the Dead‑Ledger. Atrocity‑Seeds uses those bundles to generate higher‑intensity event and region seeds. Spectral‑Foundry binds personas and entities to trauma anchors. The Seed layer in Horror.Place is the public‑safe surface that consumes those bundles via hashes and IDs, then exposes tile‑scale, machine‑checkable contracts for runtime systems.

---

## 2. Seed Contract Overview

Each Seed is a single JSON document that must validate against `schemas/seedcontractv1.json`.

At minimum, a Seed specifies:

- Identity and scope: `seed_id`, `version`, `region_id`, `tile_id`.
- Sequence placement: `stage` in the five‑stage horror sequence.
- Safety and intensity: `safety_tier`, `intensity_band`, `explicit_violence_forbidden`.
- History coupling: `bundle_ref` (and optional `archiverecord_ids`) binding the Seed to a Black‑Archivum invariant bundle.
- Invariant vector: `invariants` at tile scope for CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI, and `time_phase`.
- Entertainment intent: `metric_targets` for UEC, EMD, STCI, CDL, and ARR bands.
- Persona hooks: `persona_hooks` describing which god‑like personas and entity families can inhabit this Seed.
- Narrative affordances: `narrative_affordances` describing evidence types, player verbs, and resolution modes.
- Engine profile: `engine_profile` that constrains trigger frequency and player‑state requirements.
- Governance: optional `deadledger_ref` for high‑intensity Seeds, `charter_profile_id`, and `validator_signature`.

Seeds are declarative. They describe what is allowed and intended at a tile, not how any specific game must implement it. Engines must not invent new meaning around Seeds outside the constraints of the schema and this document.

---

## 3. Invariants and History Coupling

### 3.1. Invariant Vector at Tile Scope

The `invariants` object in each Seed is a tile‑scale snapshot of the history‑driven horror conditions at that location. It is not a standalone analytic result; it is derived from, and constrained by, the parent invariant bundle in Black‑Archivum.

The vector includes:

- CIC – Catastrophic Imprint Coefficient: manmade and natural trauma bound to this tile.
- MDI – Mythic Density Index: density of myths and rumors normalized over time.
- AOS – Archival Opacity Score: degree of missing, contradictory, or redacted records.
- RRM – Ritual Residue Map: strength of repeated structured human actions.
- FCF – Folkloric Convergence Factor: convergence of independent motif lines.
- SPR – Spectral Plausibility Rating: likelihood that phenomena qualify as haunting within world rules.
- RWF – Reliability Weighting Factor: aggregate credibility of sources.
- DET – Dread Exposure Threshold: how quickly presence here should affect characters.
- HVF – Haunt Vector Field: direction and magnitude of uncanny pressure.
- LSG – Liminal Stress Gradient: sharpness of transitions and thresholds.
- SHCI – Spectral‑History Coupling Index: how tightly specters must obey local history.
- time_phase – a limited vocabulary for diegetic time, such as `night`, `storm`, or `anniversary_window`.

Engines and AI modules must treat spectral entities and anomalies as query results against this vector. SHCI in particular constrains which persona behaviors are permissible: high SHCI Seeds favor reenactments and tightly scripted echoes of specific trials or evacuations, while lower SHCI Seeds support glitchy, ambiguous manifestations.

### 3.2. Bundle Binding and Provenance

The `bundle_ref` field points to a specific invariant bundle in Black‑Archivum. That bundle is the authoritative trauma profile. Seeds must not contradict their bundles. Instead, they refine the profile to tile scale by:

- Biasing CIC, RRM, and FCF into local pockets (ship graveyards, inspection gantries, forgotten sidings).
- Sculpting HVF and LSG into ridges, corridors, and thresholds where manifestations make sense.
- Adjusting DET to represent safe pockets versus zones of rapid psychological impact.

Optional `archiverecord_ids` allow a Seed to identify the exact archive atoms and composites that inspired it. This field is for auditability and tooling. Runtime engines do not consume raw archives and must never dereference archive records directly.

For Seeds above certain intensity bands (for example, `intensity_band >= 8`), a `deadledger_ref` is required. This reference anchors the Seed and its bundle in the Dead‑Ledger, ensuring entitlement checks and cryptographic verification for higher‑risk content.

---

## 4. Sequence Stages and Metric Targets

### 4.1. Five‑Stage Model

Each Seed has a `stage` that places it within a local five‑stage horror arc. The stages are:

- `stage_1_probe` – faint anomalies that test the player’s sensitivity without revealing clear threats.
- `stage_2_evidence` – deniable but accumulating evidence that something is wrong.
- `stage_3_confrontation` – crystallized threat, peak fear intensity.
- `stage_4_aftermath` – immediate consequences, partial or deferred "resolutions".
- `stage_5_residual` – long‑tail echoes and lingering traces.

This sequence applies at the scale of a tile or small cluster, not the entire game. Different regions and tiles can be at different stages concurrently. Stage transitions are orchestrated at runtime via `H.should_trigger_sequence`, based on local invariants and player metrics.

### 4.2. Entertainment Metric Targets

The Seed’s `metric_targets` object encodes how it intends to nudge the entertainment metrics:

- UEC_delta – Uncertainty Engagement Coefficient.
- EMD_delta – Evidential Mystery Density.
- STCI_delta – Safe‑Threat Contrast Index.
- CDL_delta – Cognitive Dissonance Load.
- ARR_min / ARR_max – desired band for Ambiguous Resolution Ratio.

These are deltas and bands, not absolutes. A Seed that “wants” to increase UEC may still result in a different net change if the engine clamps effects based on DET caps, player state, or global pacing rules. The Seed contract establishes a target, not a guarantee.

The five stages correspond to characteristic metric patterns:

- Stage 1: small positive UEC/EMD, ARR kept high, minimal CDL.
- Stage 2: stronger EMD and CDL, UEC rising as patterns accumulate.
- Stage 3: peak STCI and CDL, careful control of ARR to avoid over‑resolution.
- Stage 4: CDL begins to fall, ARR remains high or increases via new ambiguity.
- Stage 5: subtle shifts that maintain ARR and EMD without driving new peaks.

Telemetry is expected to record realized metric changes per Seed. Over time, labs retune `metric_targets` or bundle invariants to keep observed behavior within design envelopes.

---

## 5. Persona Hooks and Narrative Affordances

### 5.1. Persona Hooks

The `persona_hooks` object tells Spectral‑Foundry and personality systems which god‑like archetypes can inhabit this Seed and how to behave there.

- `primary_modes` selects from personas such as:

  - `archivist` – contradictory records, withheld facts.
  - `witness` – fragmented testimony, emotional failures of description.
  - `echo` – repeated phrases, ritual instructions, loop fragments.
  - `process` – impersonal systems, procedures, and mechanisms.
  - `threshold` – liminal guardians, presences bound to borders.

- `shci_band` further constrains behavior:

  - `reenactment` – close adherence to specific historical sequences.
  - `echo` – shorter patterns and motifs extracted from history.
  - `glitch` – misfires and corrupted manifestations in high AOS, low RWF conditions.

- `allowed_entities` can reference entity or loop contracts (for example, shadow entity behaviors or spectral loops) that are permitted at this tile.

Persona logic must always begin with a history query: the AI behavior tree calls into the invariant and Seed layer, sets internal state from SHCI and primary_modes, then selects speech patterns, appearances, and disappearances accordingly.

### 5.2. Narrative Affordances

The `narrative_affordances` object defines what kind of narrative work the Seed supports.

- `clue_types` draws from evidence types already codified in style contracts:

  - `bloodstained_object`
  - `disturbed_earth`
  - `contradictory_record`
  - `missing_person_reference`
  - `spectral_testimony_fragment`
  - `empty_space_implication`

These are semantic categories, not literal text. They tell content systems what kind of descriptive templates or assets to select.

- `player_actions` lists verbs like `observe`, `document`, `approach`, `evade`, `follow_sound`, `wait`, `refuse`. This is the set of actions that can meaningfully interact with the Seed. Game‑specific systems should map verbs to mechanics but not invent new verbs that contradict the Seed.

- `resolution_modes` sets expectations about how much closure this Seed can provide:

  - `none` – pure implication, contributes to ARR without resolving anything.
  - `partial` – some hypotheses strengthened, others remain live.
  - `branch` – resolution depends on player choices, often across multiple Seeds.
  - `late_revelation` – this Seed lays groundwork for a resolution far away in space or time.

Optional `loop_id` marks Seeds that belong to longer‑running spectral loops. Loop contracts describe how repeated visits and triggers alter metrics and manifestations.

---

## 6. Engine Integration: H.bundle and H.should_trigger_sequence

### 6.1. H.bundle

The engine utility `H.bundle(region_id, tile_id)` (or equivalent in engine bindings) is responsible for returning a bundle view for a given location. It performs two jobs:

1. Resolve the `bundle_ref.id` for that tile via registries.
2. Load the corresponding invariant bundle payload (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI plus caps and recommended ranges).

Seeds never query Black‑Archivum directly. They are authored and validated against bundles offline. At runtime, `H.bundle` is the only sanctioned way to access bundle‑level trauma profiles. It ensures entitlement checks and Dead‑Ledger verification are performed before any content is loaded.

### 6.2. H.should_trigger_sequence

`H.should_trigger_sequence(region_id, tile_id, player_state)` is the canonical decision point for whether a Seed should fire on this frame or tick. The recommended flow:

1. Query invariants and Seeds:

   - `inv = H.sample_all(region_id, tile_id)` – CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI, time_phase.
   - `seeds = Seeds.for_tile(region_id, tile_id)` – all Seeds whose invariants, time_phase, and safety tiers are valid for this environment.

2. Filter Seeds:

   - Remove Seeds whose `engine_profile` cooldowns or `max_triggers_per_session` are exhausted.
   - Remove Seeds whose `required_player_state` constraints are not met (for example, DET too high or too low).

3. Evaluate metric intent:

   - For each candidate Seed, compute projected metric changes by combining current metrics, Seed `metric_targets`, bundle detcaps, and global pacing rules.
   - Discard Seeds whose projected changes violate DET limits or safety constraints.

4. Respect stage logic:

   - Maintain a per‑tile and per‑region stage state machine.
   - Prefer Seeds whose `stage` matches the current stage.
   - Allow occasional “backfill” Seeds from earlier stages to maintain EMD and ARR.

5. Return decision:

   - If no Seeds pass filters, return false/no‑Seed.
   - Otherwise, select a Seed based on director policy (for example, pick the one whose metric deltas most closely align with target trajectories) and return it as the next event to manifest.

Engines must treat this sequence as a hard rule: no Seed should trigger without a full pass through invariant and metric evaluation. This is how the design keeps horror grounded, safe, and measurable.

---

## 7. Telemetry, Governance, and Feedback

### 7.1. Telemetry per Seed

For every Seed activation, runtime must log:

- `seed_id`, `region_id`, `tile_id`, `bundle_ref.id`.
- Player metrics before and after firing: UEC, EMD, STCI, CDL, ARR, and DET.
- Active personas and entities (based on `persona_hooks`).
- Applied resolution modes and player actions.

Aggregated over sessions, this telemetry is used to:

- Estimate actual average deltas per Seed and compare them with `metric_targets`.
- Detect Seeds that consistently overshoot DET or push ARR too low.
- Identify invariant combinations that are under‑ or over‑performing.

These summaries are stored in Tier‑1‑safe registries. Underground systems may maintain more detailed, gated telemetry with Dead‑Ledger‑mediated access.

### 7.2. Dead‑Ledger Attestation

For Seeds in higher intensity bands, or for research builds, a Dead‑Ledger entry is required. This entry typically includes:

- The Seed’s hash and registry coordinates.
- The referenced bundle’s hash and registry coordinates.
- A compliance report hash confirming schema validation, Charter checks, and range audits.
- Entitlement rules describing which safety tiers and jurisdictions may access this Seed.

Engines never hold Dead‑Ledger proofs locally. Instead, an entitlement service or client queries the ledger, obtains a proof that the current session may access this Seed, and then unlocks it in local registries. Without a valid proof, the Seed is treated as non‑existent.

### 7.3. Retuning and Versioning

When telemetry suggests that a Seed behaves differently in practice than intended, or when bundles are updated, the Seed layer responds via:

- Version bumps on Seeds (`version` field) with updated `metric_targets` or invariants.
- New bundle revisions in Black‑Archivum with updated invariant profiles.
- Registry updates to point to the latest versions while retaining older versions for audit and reproducibility.

Versioned Seeds remain addressable so that research builds can rerun old configurations, but production orchestrators should use only the latest attested versions for each safety tier.

---

## 8. Authoring and Validation

Seed authoring is expected to be guided, not free‑form. Authors should:

- Start from templates in `templates/seed.template.json` or stage‑specific variants.
- Choose a bundle and ensure all invariant values lie within bundle constraints.
- Set `metric_targets` consistent with the intended stage and global pacing.
- Pick persona and narrative affordances that can be satisfied by existing styles, assets, and AI templates.

Validation is multi‑layered:

1. JSON Schema validation against `schemas/seedcontractv1.json`.
2. Cross‑schema validation against style contracts, entertainment metrics, and Charters.
3. Registry validation to ensure bundle IDs, biome profiles, and Dead‑Ledger references exist and match.

Only Seeds that pass all validation should be allowed into public registries or used by any runtime. Every Seed must be auditable from behavior back to history: from a player’s observed anomaly, through the active Seed, through its bundle, and finally into the archive records that shaped the trauma profile.

---

## 9. Engine‑Facing Lua API Sketch

The Seed layer is intended to be consumed through a narrow Lua API, not through ad‑hoc JSON parsing. A typical facade module might expose:

- `Seeds.load(seed_id)` – returns a Seed object.
- `Seeds.for_tile(region_id, tile_id)` – returns candidate Seeds for that tile, pre‑filtered by safety tier and time_phase.
- `Seeds.should_fire(seed_id, player_state)` – returns true/false and projected metric changes.
- `Seeds.apply_metrics(seed_id, player_state)` – clamps and applies metric deltas consistent with DET caps and director rules.

Internally, these calls always perform:

1. `QueryHistoryLayer` – sample invariants via bundles and Seed invariants.
2. `SetBehaviorFromInvariants` – impose constraints on personas, entities, and metrics.
3. `LogTelemetry` – record actual behavior for future tuning.

This pattern keeps horror grounded in data, traceable from ledger to tile, and tunable over time, while preserving implication‑first, non‑explicit design principles required by the Horror.Place Charter.
