# NightWhispers View-Layer Specification v1

This document defines the NightWhispers subsystem as a **view-layer projection** over the Horror.Place invariant spine and Seed contracts. It is not a standalone world model; all Zone, MajorNpc, and UrbanLegendMetaQuest records are read-only projections that resolve to canonical history via the H. API.

---

## 1. Doctrine Alignment

NightWhispers adheres to the core Horror.Place doctrine:

- **History-first**: All manifestations query invariant bundles (Black-Archivum) and Seed contracts (Atrocity-Seeds) as the single source of truth.
- **Schema-first**: All JSON/NDJSON validates against canonical schemas in `schemas/`.
- **Implication-only**: No raw horror content, narrative prose, or explicit descriptions appear in view-layer data.
- **Metric-targeted**: `mood_channels` and `bci_calibration` are inputs to UEC/EMD/STCI/CDL/ARR computation, not freeform sliders.

---

## 2. Zone as Invariant-Bound View

### 2.1 Conceptual Shape

```rust
// Conceptual Rust view (not stored; constructed at runtime)
pub struct ZoneView {
    pub id: ZoneId,                          // e.g., "LanternAlley"
    pub region_id: String,                   // refs Black-Archivum region bundle
    pub tile_ids: Vec<TileId>,               // optional fine-grained anchors
    pub invariant_ref: InvariantBundleRef,   // git@ URI to Black-Archivum bundle
    pub mood_channels: MoodChannels,         // inputs to metric computation
    pub rumor_bias_tags: Vec<String>,        // bias RumorPool seeding
    pub bci_calibration: BciCalibration,     // lab priors for arousal/valence
}
```

### 2.2 Field Semantics and Invariant Mapping

| Field | Type | Invariant/Metric Mapping | Notes |
|-------|------|-------------------------|-------|
| `id` | `ZoneId` | — | Stable identifier; aligns with `registry/zones.json` |
| `region_id` | `String` | — | Primary key for `H.bundle(region_id)` resolution |
| `tile_ids` | `Vec<TileId>` | — | Optional sub-region anchors for fine-grained CIC/MDI |
| `invariant_ref` | `InvariantBundleRef` | CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI | git@ URI to Black-Archivum; read-only |
| `mood_channels.fog` | `f32 [0,1]` | → UEC, STCI | Environmental uncertainty driver |
| `mood_channels.rain` | `f32 [0,1]` | → UEC, EMD | Sensory occlusion and mystery density |
| `mood_channels.light` | `f32 [0,1]` | → STCI, CDL | Safety contrast and cognitive dissonance |
| `mood_channels.rumor_intensity` | `f32 [0,1]` | → CIC, UEC, ARR | Direct input to rumor weight and ambiguity retention |
| `rumor_bias_tags` | `Vec<String>` | → EMD, CDL, ARR | Tags bias Seed selection toward compatible invariant profiles |
| `bci_calibration.target_arousal` | `f32 [0,1]` | Lab prior for arousal validation | Validated by Neural-Resonance-Lab; not runtime truth |
| `bci_calibration.target_valence` | `f32 [0,1]` | Lab prior for valence validation | Same as above |
| `bci_calibration.artifact_sensitivity` | `f32 [0,1]` | BCI noise handling weight | Higher = more aggressive artifact rejection |

### 2.3 Runtime Construction Pattern

Zones are never loaded from static JSON alone. The canonical construction flow is:

1. Engine calls `H.zone_view(zone_id)` via FFI/Lua.
2. Orchestrator resolves `region_id` → invariant bundle from Black-Archivum.
3. Orchestrator merges bundle invariants with view-layer `mood_channels` and `bci_calibration`.
4. Result is cached per-session; updates propagate via Orchestrator invalidation.

```lua
-- Example Lua usage (engine-side)
local zone = H.zone_view("LanternAlley")
local cic = zone.invariants.CIC  -- resolved from Black-Archivum
local target_arousal = zone.bci_calibration.target_arousal  -- design prior
```

---

## 3. MajorNpc as Persona-Contract View

### 3.1 Conceptual Shape

```rust
pub struct MajorNpcView {
    pub id: NpcId,                           // e.g., "CandleEyedWidow"
    pub persona_contract_ref: PersonaRef,    // git@ URI to Constellation-Contracts persona
    pub zone_id: ZoneId,                     // primary zone association
    pub legend_id: Option<LegendId>,         // optional link to UrbanLegendMetaQuest
    pub role_tags: Vec<String>,              // ["questgiver","antagonist","tragic"]
    pub personality_base: PersonalityVector, // trust/fear/intrigue/horror seeds
    pub rumor_tags: Vec<String>,             // tags for rumor seeding/resolution
    pub bci_calibration: NpcBciCalibration,  // social_threat, uncanny_factor, eeg_bands
}
```

### 3.2 Field Semantics and Metric Mapping

| Field | Type | Invariant/Metric Mapping | Notes |
|-------|------|-------------------------|-------|
| `id` | `NpcId` | — | Stable identifier; aligns with `registry/personas.json` |
| `persona_contract_ref` | `PersonaRef` | SHCI, metricInfluence, invariantCoupling | Points to Tier-1 persona contract; source of truth for behavior |
| `zone_id` | `ZoneId` | — | Routing key for presence and rumor propagation |
| `legend_id` | `Option<LegendId>` | — | Optional link to NightWhispers legend state machine |
| `role_tags` | `Vec<String>` | → UEC, EMD, STCI | Coarse semantic roles mapped to metric influence vectors |
| `personality_base.trust` | `f32 [0,1]` | → STCI, CDL | Higher trust reduces safe-threat contrast |
| `personality_base.fear` | `f32 [0,1]` | → UEC, EMD | Seeds uncertainty and mystery density in interactions |
| `personality_base.intrigue` | `f32 [0,1]` | → EMD, ARR | Drives clue ambiguity and unresolved narrative threads |
| `personality_base.horror` | `f32 [0,1]` | → CIC, DET | Contributes to local trauma magnitude and exposure caps |
| `rumor_tags` | `Vec<String>` | → EMD, CDL, ARR | Tags the NPC can seed, respond to, or resolve |
| `bci_calibration.social_threat` | `f32 [0,1]` | Lab prior for social anxiety validation | Validated by Neural-Resonance-Lab |
| `bci_calibration.uncanny_factor` | `f32 [0,1]` | → CDL, STCI | Tunes uncanny valley effects; validated via EEG/EDA |
| `bci_calibration.recommended_eeg_band_focus` | `Vec<String>` | Lab guidance for signal analysis | e.g., `["theta","gamma"]` for this NPC's interaction profile |

### 3.3 Persona Resolution Flow

1. Engine requests `H.npc_view(npc_id)`.
2. Orchestrator fetches persona contract from `HorrorPlace-Constellation-Contracts` via `persona_contract_ref`.
3. Personality vectors and metric influences are merged with view-layer extensions (`rumor_tags`, `bci_calibration`).
4. Result is cached; persona updates propagate via contract versioning.

---

## 4. UrbanLegendMetaQuest as Seed-Like Contract

UrbanLegendMetaQuest is not a lore container; it is a **Seed-like controller** that references Atrocity-Seeds sequence contracts and persona hooks.

### 4.1 Contract Reference

- Schema: `schema://HorrorPlace-Constellation-Contracts/nightwhispers-legend-contract-v1.json`
- Location: `HorrorPlace-Constellation-Contracts/contracts/nightwhispers-legend-contract-v1.json`

### 4.2 Key Fields (Summary)

| Field | Type | Purpose |
|-------|------|---------|
| `legend_id` | `String` | NightWhispers-internal stable ID |
| `seed_ids` | `Vec<String>` | References to Atrocity-Seeds sequence seeds |
| `persona_hooks` | `Vec<PersonaRef>` | Persona contracts that can trigger/resolve this legend |
| `metric_targets` | `MetricDeltaEnvelope` | Target deltas for UEC/EMD/STCI/CDL/ARR |
| `bci_target_refs` | `Vec<BciCalibrationRef>` | Links to validated calibration descriptors |
| `status_transitions` | `LegendFsmSpec` | Deterministic state machine: Asleep→Awakening→Active→Fulfilled/Broken |
| `hazard_delta_rules` | `HazardRuleSet` | How `hazard_delta` adjusts per action/intensity |

### 4.3 Runtime Query Pattern

```rust
// Pseudocode: legend resolution via History API
fn resolve_legend_for_manifestation(
    legend_id: &str,
    current_zone: &ZoneView,
) -> Option<ManifestationPlan> {
    // 1. Load legend contract via Orchestrator
    let legend = H.legend_contract(legend_id)?;
    
    // 2. Filter seeds by invariant compatibility
    let compatible_seeds = legend.seed_ids.iter()
        .filter(|seed_id| {
            let seed = H.seed_contract(seed_id)?;
            seed.invariants.compatible_with(&current_zone.invariants)
        })
        .collect::<Vec<_>>();
    
    // 3. Score by metric target alignment
    let best_seed = compatible_seeds.into_iter()
        .max_by_key(|seed| metric_alignment_score(seed, &legend.metric_targets))?;
    
    // 4. Build manifestation plan bounded by DET/SPR/SHCI
    Some(ManifestationPlan::new(best_seed, &legend, current_zone))
}
```

---

## 5. RumorPool as Invariant-Aware Nervous System

The RumorPool tick logic must query invariants before spawning events.

### 5.1 Enhanced Tick Pseudocode

```text
function tick_rumors_with_invariants(pool, dt_minutes, player_loc, player_state):
    // 1. Resolve current zone invariants via H. API
    zone_view = H.zone_view(player_loc)
    local_invariants = zone_view.invariants  // CIC, MDI, AOS, etc.
    
    // 2. Apply decay and belief feedback (as before)
    for rumor in pool.active_rumors:
        // ... decay logic ...
    
    // 3. Sort by invariant-aware priority
    sorted_rumors = sort_desc(pool.active_rumors, key = lambda r:
        r.weight * 
        (0.5 + r.truthiness * 0.3 + r.embellishment * 0.2) *
        invariant_compatibility_score(r.tags, local_invariants)  // NEW
    )
    
    // 4. Spawn with DET/SPR gating
    for rumor in sorted_rumors:
        if can_spawn(rumor, local_invariants, player_state):  // NEW: checks DET, SPR, SHCI
            spawn_world_event(rumor.spawned_event_tag, player_loc)
            rumor.weight *= 0.4  // dampen post-spawn
    
    // 5. Cull low-weight rumors
    pool.active_rumors = filter(sorted_rumors, r => r.weight > 0.05)
```

### 5.2 Invariant Compatibility Scoring

```rust
fn invariant_compatibility_score(rumor_tags: &[String], invariants: &InvariantVector) -> f32 {
    let mut score = 1.0;
    
    // High CIC zones favor high-intensity rumors
    if invariants.CIC > 0.7 && rumor_tags.iter().any(|t| t.contains("cataclysm")) {
        score *= 1.3;
    }
    
    // High SPR zones favor historically plausible rumors
    if invariants.SPR > 0.6 && rumor_tags.iter().any(|t| t.contains("folklore")) {
        score *= 1.2;
    }
    
    // High AOS zones favor ambiguous/contradictory rumors
    if invariants.AOS > 0.5 && rumor_tags.iter().any(|t| t.contains("contradiction")) {
        score *= 1.15;
    }
    
    score.clamp(0.0, 2.0)
}
```

---

## 6. BCI Calibration as Lab-Validated Priors

`bci_calibration` fields are **design hypotheses**, not runtime truth. They must be validated by Neural-Resonance-Lab before use in adaptive systems.

### 6.1 Validation Workflow

1. Lab loads `ZoneView`/`MajorNpcView` JSON from Horror.Place.
2. Testbed renders scenes using invariant bundles and style contracts.
3. Physiological data (EEG, EDA, HRV) is collected and summarized via `bci-metric-summary-v1.json`.
4. Statistical analysis compares `target_arousal/valence` to measured values.
5. Validated calibration overlays are published back to Horror.Place as read-only references.

### 6.2 Adaptive System Boundaries

Once validated, adaptive controllers may adjust NightWhispers parameters **only within safe envelopes**:

- Arousal must never exceed `target_arousal + 0.15` without explicit DET override.
- Rumor decay adjustments are capped at ±20% per tick.
- All changes are logged with before/after metric snapshots for audit.

---

## 7. Schema References

All NightWhispers view-layer artifacts validate against:

- `schema://Horror.Place/nightwhispers-zone-v1.json`
- `schema://Horror.Place/nightwhispers-majornpc-v1.json`
- `schema://HorrorPlace-Constellation-Contracts/nightwhispers-legend-contract-v1.json`

These schemas enforce `additionalProperties: false`, canonical invariant/metric ranges, and git@ URI patterns for cross-repo references.

---

## 8. Migration Notes for Existing NightWhispers Code

1. Replace static `Zone`/`MajorNpc` JSON loads with `H.zone_view()`/`H.npc_view()` calls.
2. Remove any hardcoded invariant values; always resolve via `invariant_ref`.
3. Update FFI signatures to return view-layer structs, not raw data.
4. Add `schemaref` fields to all emitted JSON for CI validation.
5. Ensure `deadledgerref` is present for any artifact with `intensityband >= 8`.

---

*This document is implication-only and schema-bound. It contains no raw horror content, narrative prose, or explicit descriptions of harm. All references to trauma, history, or spectral phenomena are mediated through invariant bundles and Seed contracts.*
