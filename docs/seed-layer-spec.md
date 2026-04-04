# Horror.Place Seed Layer Specification v1.0

> **Status**: Tier‑1 Public Core Contract  
> **Scope**: Engine‑consumable Seed definitions, invariant coupling, telemetry integration, and Dead‑Ledger attestation  
> **Audience**: Runtime engines, Lua APIs, Spectral‑Foundry, lab pipelines, Dead‑Ledger validators

---

## 2.1 Purpose and Role in the Constellation

A **Seed** is the smallest, history‑bound, engine‑consumable unit in Horror.Place. It is not raw trauma, not narrative prose, and not a gameplay event. It is a *contract* that:

1. **Binds a single region tile** to a history‑backed trauma bundle plus an invariant vector (`CIC`, `MDI`, `AOS`, …).
2. **Defines metric intent**: how activation should shift player‑facing entertainment metrics (`UEC`, `EMD`, `STCI`, `CDL`, `ARR`).
3. **Offers persona and narrative hooks** without embedding explicit content—only implication‑level affordances.

### Position Relative to Other Repos

| Repository | Relationship to Seeds |
|------------|----------------------|
| **Black‑Archivum** | Produces invariant bundles and archive records; Seeds reference bundles via `bundle_ref.id` + `hash`. Seeds never inspect raw history. |
| **Atrocity‑Seeds** | Consumes bundles to emit higher‑intensity event/region seeds; Horror.Place Seeds are the public‑safe, implication‑only layer referencing those underground constructs via hashes. |
| **Spectral‑Foundry** | Binds personas/entities to Seed `persona_hooks` and `SHCI`; Seeds declare *what* can manifest, Foundry decides *how*. |
| **Dead‑Ledger** | Anchors high‑intensity Seeds (`intensity_band >= 8`); `deadledger_ref` is mandatory at those bands for auditability. |

Seeds are **Tier‑1 contracts**: GitHub‑safe, schema‑validated, and Charter‑aligned. They enable deterministic procedural generation while preserving ambiguity for human designers.

---

## 2.2 History‑Invariant Coupling (SHCI, CIC, RRM, etc.)

Spectral entities and anomalies are **query results** against invariant bundles, not arbitrary monsters. Seeds are the deterministic interface to that history layer.

### Invariant Semantics at Seed Scope

| Invariant | Qualitative Meaning at Seed Level | Example Numeric Envelope |
|-----------|----------------------------------|-------------------------|
| **CIC** (Catastrophic Imprint) | Severity of disaster stamped on this tile; justifies environmental decay, systemic threats. | `CIC >= 7.5` → boss lair, body‑horror setpiece |
| **MDI** (Mythic Density) | Concentration of rumors/myths; drives low‑budget scares (audio glitches, apparitions). | `MDI >= 6.0` + `CIC < 4.0` → ambient whispers, shadow flickers |
| **AOS** (Archival Opacity) | Contradiction/incompleteness of records; enables hidden dungeons, shifting architecture. | `AOS >= 8.0` → secret cult lab, reality‑glitch events |
| **RRM** (Ritual Residue) | Lingering effects of repeated rituals; boot‑speed for occult mechanics. | `RRM >= 7.0` → sigil activation, blood‑powered doors |
| **SPR** (Spectral Plausibility) | Likelihood a legend could be "true" within world rules; controls apparition clarity. | `SPR >= 8.5` → fully systemic enemy; `SPR <= 3.0` → rumor‑only |
| **SHCI** (System‑History Coherence) | How tightly manifestations must adhere to documented history. | `SHCI >= 9.0` → reenactment mode; `SHCI <= 4.0` → glitch mode |
| **HVF** (Hostile Vector Field) | Directional "flow" of uncanny pressure; guides player movement, entity pathing. | `HVF.mag >= 7.0` + `dir="S"` → fog rolls south, entities drift toward hut |
| **LSG** (Liminal Stress Gradient) | Sharpness of state transitions; ideal for thresholds, doors, ridges. | `LSG >= 8.5` → manifestation allowed only at tile boundary |

### Coupling Logic

```lua
-- Pseudocode: H.should_trigger_sequence uses invariants to constrain behavior
local inv = H.sample_all(region_id, tile_id)
if inv.SHCI >= 9.0 then
    persona.behavior_mode = "reenactment"  -- Must follow archive record
elseif inv.SHCI <= 4.0 then
    persona.behavior_mode = "glitch"       -- May distort, fragment, contradict
end
if inv.SPR < 3.0 then
    -- Never manifest entity; only ambient audio/text clues
    return false
end
```

Seeds with high `HVF.mag` in high‑`LSG` tiles become natural candidates for **thresholds** (plankwalks, doorways, tree lines) where stalkers appear and audio filters crossfade.

---

## 2.3 Stage Progression and Sequence Model

The `stage` enum directly maps to the five‑stage horror sequence. Each stage has expected invariant bands and metric target behavior.

### Canonical Five‑Stage Arc

| Stage | Purpose | Expected Invariant Bands | Metric Target Behavior |
|-------|---------|-------------------------|----------------------|
| **stage_1_probe** | Subtle anomalies just above DET; plant seeds of doubt. | `CIC: 3–5`, `SPR: 2–4`, `AOS: 6–8` | Raise `UEC` +0.1, `EMD` +0.15; keep `ARR >= 0.8` |
| **stage_2_evidence** | Clear but deniable traces; high EMD, moderate UEC. | `CIC: 5–7`, `MDI: 6–8`, `RRM: 5–7` | Raise `EMD` +0.25, `STCI` +0.1; `ARR >= 0.75` |
| **stage_3_confrontation** | Peak STCI, strong CDL; threat crystallizes. | `CIC: 7–9`, `SPR: 7–9`, `SHCI: 8–10` | Raise `STCI` +0.3, `CDL` +0.2; `ARR >= 0.7` |
| **stage_4_aftermath** | De‑escalation; partial resolution, ambiguity preserved. | `CIC: 6–8`, `AOS: 7–9`, `RWF: 3–5` | Lower `CDL` -0.1, raise `ARR` to `>= 0.85` |
| **stage_5_residual** | Low‑intensity echoes; durable RRM, long‑form dread. | `RRM: 7–9`, `HVF.mag: 4–6`, `LSG: 5–7` | Sustain `UEC` +0.05/session; `ARR >= 0.9` |

### Stage Graph Adjacency

Optional `stage_graph` allows branching or linear sequences:

```json
"stage_graph": {
  "previous": ["aral_swamp_engine_city_02"],
  "next": ["aral_swamp_engine_city_04", "aral_swamp_engine_city_04_alt"]
}
```

`H.should_trigger_sequence` uses this to plan multi‑Seed arcs without hard‑coding.

---

## 2.4 H.bundle and H.should_trigger_sequence – Lua‑Facing API

### H.bundle(region_id, tile_id)

Queries the history/invariant layer (Black‑Archivum bundle registry mirrored into Horror.Place) and returns a "bundle view":

```lua
local bundle = H.bundle("aral_swamp_anomalic_belt", "engine_hut_threshold")
-- Returns:
-- {
--   invariants = { CIC=8.8, MDI=8.3, AOS=7.9, ... },
--   metric_caps = { DET_cap=9.2, ARR_floor=0.7 },
--   style_id = "biome_swamp_v1",
--   biome_profile_id = "bp_aral_dying_sea"
-- }
```

Seeds **never** inspect raw history; they only receive this sanitized view.

### H.should_trigger_sequence(region_id, tile_id, player_state)

Determines if a Seed should fire based on invariants, engine constraints, and player telemetry.

```lua
function H.should_trigger_sequence(region_id, tile_id, player_state)
    -- 1. Sample invariants for this tile
    local inv = H.sample_all(region_id, tile_id)
    
    -- 2. Gather candidate Seeds whose invariant_preconditions are satisfied
    local candidates = Seeds.for_tile(region_id, tile_id)
    candidates = filter_by_invariants(candidates, inv)
    
    -- 3. Filter by engine_profile (cooldowns, max triggers) and player_state
    candidates = filter_by_engine_profile(candidates, player_state)
    candidates = filter_by_player_metrics(candidates, player_state)
    
    -- 4. Evaluate metric_targets vs current session metrics
    local best = select_seed_by_metric_gap(candidates, player_state.metrics)
    
    -- 5. Pick Seed whose stage fits active sequence state
    if best and stage_machine.is_compatible(best.stage, region_id, tile_id) then
        return best
    end
    return nil
end
```

### DET and Detcap Interplay

A Seed's metric deltas must be clamped by both bundle‑level `detcap` and player‑state `DET`:

```lua
function Seeds.apply_metrics(seed_id, player_state)
    local seed = Seeds.load(seed_id)
    local bundle = H.bundle(seed.region_id, seed.tile_id)
    
    -- Clamp each delta by detcap and current DET
    local clamped = {}
    for metric, delta in pairs(seed.metric_targets) do
        if metric:match("_delta$") then
            local max_allowed = math.min(bundle.metric_caps.DET_cap - player_state.DET, 1.0)
            clamped[metric] = math.max(-1.0, math.min(delta, max_allowed))
        else
            clamped[metric] = delta  -- ARR_min/max pass through
        end
    end
    return clamped
end
```

This ensures Seeds cannot push player dread beyond safe thresholds while still allowing meaningful metric shifts.

---

## 2.5 Telemetry, Dead‑Ledger, and Feedback Loops

### Telemetry Summary per Seed

For each Seed activation, log aggregated metric effects:

```json
{
  "seed_id": "aral_swamp_engine_city_03",
  "session_id": "sess_abc123",
  "observed_deltas": {
    "UEC": +0.12,
    "EMD": +0.18,
    "STCI": +0.09,
    "CDL": +0.04,
    "ARR_realized": 0.81
  },
  "target_deltas": { ... },
  "detcap_effective": 9.2,
  "deadledger_ref": "dl_7f3a9c2e1b4d8f6a"
}
```

Summaries are stored in `registry/metriccontributionlog.json` (Tier‑1‑safe) or referenced via IDs into underground telemetry vaults.

### Dead‑Ledger Integration

Any Seed with `intensity_band >= 8` must have:

1. A signed Seed artifact (Seed id, hash, bundle_ref, metric profile, compliance report).
2. A ledger entry in Dead‑Ledger referencing this artifact.
3. `deadledger_ref` recorded in Seed registries and optionally in the Seed file itself.

**Mock End‑to‑End Flow**:

```
1. Author creates Seed JSON → validates against seedcontractv1.json
2. CI pipeline signs Seed with validator_signature (Git commit hash)
3. If intensity_band >= 8:
   a. Submit Seed artifact to Dead‑Ledger API
   b. Receive deadledger_ref = "dl_7f3a9c2e1b4d8f6a"
   c. Embed deadledger_ref in Seed metadata
4. Seed registered in registry/seedregistry.json with hash + ref
5. Runtime engine fetches Seed via registry, verifies signature + deadledger_ref
```

### Feedback to Seed Design

Labs analyze telemetry to adjust `metric_targets` or revise underlying bundles:

- If `ARR_realized` consistently < `ARR_min` target → raise ambiguity in narrative affordances, adjust stage adjacency, or loosen `resolution_modes`.
- If `UEC_delta` observed << target → increase `AOS` or `MDI` in invariant bundle, or add `clue_types: ["archival_gap"]`.
- If `DET` spikes beyond `detcap` → lower `STCI_delta` or add `required_player_state.DET_max` constraints.

New revisions of Seeds and bundles follow Black‑Archivum versioning: semantic version bumps, signed commits, re‑registration with updated hashes.

---

## 3. Supporting Artifacts

### 3.1 Seed Registry and NDJSON Feed

**`registry/seedregistry.json`** (Horror.Place core):

```json
{
  "seeds": [
    {
      "seed_id": "aral_swamp_engine_city_03",
      "region_id": "aral_swamp_anomalic_belt",
      "tile_id": "engine_hut_threshold",
      "path": "seeds/aral/swamp_engine_city_03.json",
      "hash": "a1b2c3d4e5f6...",
      "safety_tier": "standard",
      "intensity_band": 7,
      "deadledger_ref": null,
      "public_descriptor_ref": "desc_aral_swamp_03",
      "bundle_ref": { "id": "ba_aral_swamp_v2", "hash": "..." },
      "biome_profile_id": "bp_aral_dying_sea"
    }
  ]
}
```

**NDJSON Export**: One‑Seed‑per‑line, schema‑compliant, used by labs and BCI pipelines without exposing raw archives.

### 3.2 Biome/Profile Registry and Style Bindings

**`schemas/biomeprofilev1.json`** describes biome profiles that Bundles and Seeds refer to. `biome_profile_id` in Seed points to style contracts describing audio, visual, semantic, and implication rules. Ensure ranges in Seed invariants and metric_targets are consistent with style invariants/metrics (e.g., Machine Canyon bands).

### 3.3 Lua Façade Module for Seeds

Canonical Lua module in Horror.Place core:

```lua
-- horror_place/seeds.lua
local Seeds = {}

function Seeds.load(seed_id)
    -- Load Seed JSON metadata by ID from registry cache
end

function Seeds.for_tile(region_id, tile_id)
    -- List Seeds eligible for that tile given invariants
end

function Seeds.should_fire(seed_id, player_state)
    -- Evaluate engine_profile, DET, metrics
end

function Seeds.apply_metrics(seed_id, player_state)
    -- Clamp and apply metric_targets in a DET‑bounded way
end

return Seeds
```

All systems go through `Seeds`/`H` bundles, never through ad‑hoc JSON decoding.

### 3.4 Seed Authoring Templates and Linting

**Templates**: `templates/seed.template.json` with safe baseline metrics, conservative invariants, persona_hooks for lower‑intensity archetypes.

**Linter Script** validates Seeds against:
- `seedcontractv1.json`
- Style contracts (e.g., `evidencetypesallowed` vs narrative affordances)
- Charter rules (no forbidden terms, `explicit_violence_forbidden: true`)
- Cross‑repo references (bundle_ref exists in Black‑Archivum; deadledger_ref exists when required)

### 3.5 Seed Telemetry and Metrics Registry

**`registry/metriccontributionlog.json`** (Seed‑scoped slice):

```json
{
  "seed_id": "aral_swamp_engine_city_03",
  "targets": { "UEC_delta": 0.15, "EMD_delta": 0.2, ... },
  "observed_avg": { "UEC": 0.12, "EMD": 0.18, ... },
  "detcap_effective": 9.2,
  "deadledger_ref": "dl_7f3a9c2e1b4d8f6a",
  "last_updated": "2026-01-15T10:30:00Z"
}
```

Used as quantitative justification when Seeds are anchored in Dead‑Ledger and when labs retune bundles.

---

## 4. Design Qualities: Diversity, Flexibility, Quality

### Diversity
- Seeds are small, tile‑scale contracts; many Seeds can share a bundle but differ in `tile_id`, `stage`, `persona_hooks`, and `narrative_affordances`, making micro‑variation trivial while maintaining historical coherence.
- Biome and style bindings let the same trauma profile manifest as different sensory experiences across games or modes, as long as metrics and invariants stay within defined bands.

### Flexibility
- `metric_targets` describe deltas, not absolutes, so the same Seed can behave differently under different Directors or personality mixes, while still honoring invariant contracts.
- Stages and `stage_graph` allow both linear and branching sequence designs without changing schema; orchestration logic lives in Lua/engine code, not in ad‑hoc JSON hacks.

### Quality
- Tying every Seed to an invariant bundle and Dead‑Ledger attestation at higher bands gives consistent trauma alignment and auditability.
- Schema‑validated invariants, metrics, persona hooks, and narrative affordances ensure that all generated horror is history‑grounded, implication‑based, and inspected by deterministic tooling before it reaches any runtime.

---

> **Appendix A: Example Seed (NDJSON Row)**
> ```json
> {"schema":"https://horror.place/schemas/seedcontractv1.json","seed_id":"aral_swamp_engine_city_03","version":"1.2.0","region_id":"aral_swamp_anomalic_belt","tile_id":"engine_hut_threshold","stage":"stage_2_evidence","created_at":"2026-01-10T08:00:00Z","updated_at":"2026-01-15T10:30:00Z","safety_tier":"standard","intensity_band":7,"deadledger_ref":null,"invariants":{"CIC":8.8,"MDI":8.3,"AOS":7.9,"RRM":7.0,"FCF":7.5,"SPR":8.6,"RWF":6.2,"DET":6.0,"LSG":9.0,"SHCI":9.0,"HVF":{"mag":8.0,"dir":"S"},"time_phase":{"phase":"night"}},"metric_targets":{"UEC_delta":0.15,"EMD_delta":0.2,"STCI_delta":0.1,"CDL_delta":0.05,"ARR_min":0.75,"ARR_max":0.9},"bundle_ref":{"id":"ba_aral_swamp_v2","hash":"a1b2c3d4e5f6..."},"biome_profile_id":"bp_aral_dying_sea","persona_hooks":{"primary_modes":["echo","witness"],"shci_band":"reenactment"},"narrative_affordances":{"clue_types":["spectral_testimony_fragment","environmental_anomaly"],"player_actions":["observe","follow_sound"],"resolution_modes":["partial"]},"engine_profile":{"trigger_cooldown_sec":300,"max_triggers_per_session":2},"explicit_violence_forbidden":true,"validator_signature":"a1b2c3d4e5f6..."}
> ```

> **Appendix B: Stage Transition Heuristics**
> - `stage_1 → stage_2`: Trigger when `UEC >= 0.6` AND `EMD >= 0.5` AND player has interacted with ≥2 clue_types.
> - `stage_2 → stage_3`: Trigger when `STCI >= 0.7` OR player DET >= 7.0.
> - `stage_3 → stage_4`: Trigger after confrontation resolution OR `CDL >= 0.8` for >60s.
> - `stage_4 → stage_5`: Trigger when `ARR >= 0.85` AND player has left locus tile.
> - `stage_5` persists as long as `RRM >= 7.0` in region; may re‑trigger `stage_1` Seeds in adjacent tiles.
