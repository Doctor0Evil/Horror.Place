# DreadForge Atmosphere Integrity Standard (DFAS)

**Specification Version:** 1.0.0  
**Canonical ID:** `standard.dreadforge.v1`  
**Status:** Active  
**License:** Apache 2.0 (with DreadForge Seal trademark guidelines)

---

## 1. Purpose and Scope

DreadForge defines a minimal, invariant‑driven standard for atmospheric integrity across horror and action titles that integrate with Horror.Place. It treats atmosphere as a first‑class, measurable property anchored to geo‑historical invariants rather than a loose, aesthetic overlay.

DFAS guarantees that:

- No runtime system (audio, PCG, AI, spawn logic) makes decisions without querying the invariant layer.
- Mood contracts and invariant bands enforce a minimum level of dread and atmospheric cohesion around critical spaces such as spawns, battlefronts, and liminal tiles.
- External studios and modders can treat DreadForge as a stable contract rather than a loose set of examples.

This document applies to:

- The public `Horror.Place` repository (schemas, registries, contracts, Lua/C++ stubs).
- Tier‑2 vaults that declare DreadForge‑compliant moods, seeds, and events.
- Any engine or tool that consumes Horror.Place invariants and contracts.

---

## 2. Naming and Concepts

### 2.1 Core Name

- **Full name:** DreadForge Atmosphere Integrity Standard (DFAS)  
- **Short reference:** DreadForge

DreadForge is descriptive and community‑friendly. It signals atmosphere enforcement rather than gore and is intended as an open standard that any engine or tool can adopt.

### 2.2 Invariants and Metrics

DreadForge relies on the Horror.Place invariant and metric spine. All values are normalized to `[0.0, 1.0]` unless otherwise specified in the canonical schemas.

**History layer invariants**

- `CIC` – Catastrophic Imprint Coefficient  
- `MDI` – Mythic Density Index  
- `AOS` – Archival Opacity Score  
- `RRM` – Ritual Residue Map  
- `FCF` – Folkloric Convergence Factor  
- `SPR` – Spectral Plausibility Rating  
- `SHCI` – Spectral‑History Coupling Index  

**Spatial / manifestation**

- `HVF` – Haunt Vector Field (magnitude and direction)  
- `LSG` – Liminal Stress Gradient  
- `DET` – Dread Exposure Threshold (may use a wider numeric range in some runtime schemas)  
- `RWF` – Reliability Weighting Factor  

**Player‑experience metrics**

- `UEC` – Uncertainty Engagement Coefficient  
- `EMD` – Evidential Mystery Density  
- `STCI` – Safe‑Threat Contrast Index  
- `CDL` – Cognitive Dissonance Load  
- `ARR` – Ambiguous Resolution Ratio  

DFAS requires that all participating systems access these values exclusively through the canonical `H.*` APIs (Lua/C++/HTTP), never via ad‑hoc tables.

**Rule DF‑API‑1:** All DreadForge‑aware code must obtain invariants and metrics through the canonical `H.*` functions.

---

## 3. Minimal API Surface

The DFAS API is deliberately narrow. Lua policy modules read invariants and decide behavior; engine‑specific code translates those decisions into audio, VFX, and gameplay effects.

### 3.1 Invariants API (Lua)

**Module:** `engine/library/horror_invariants.lua`

Required functions (signatures may be extended but not removed):

- `H.CIC(region_id, tile_id)`  
- `H.MDI(region_id, tile_id)`  
- `H.AOS(region_id, tile_id)`  
- `H.RRM(region_id, tile_id)`  
- `H.FCF(region_id, tile_id)`  
- `H.SPR(region_id, tile_id)`  
- `H.SHCI(region_id, tile_id)`  
- `H.HVF(region_id, tile_id)` → returns `{ mag = number, dir = { x = number, y = number } }`  
- `H.LSG(region_id, tile_id)`  
- `H.DET(player_id)`  
- `H.RWF(region_id, tile_id)`  
- `H.UEC(player_id)`  
- `H.EMD(player_id)`  
- `H.STCI(player_id)`  
- `H.CDL(player_id)`  
- `H.ARR(player_id)`  
- `H.sample_history(region_id, tile_id)`  
- `H.sample_all(region_id, tile_id, player_id)` → returns a table containing all relevant invariants and metrics

These functions must obtain data from Horror.Place schemas and registries (HTTP, NDJSON, or baked data), not from hard‑coded values.

### 3.2 Audio Policy API (Lua)

**Module:** `engine/library/horror_audio.lua`

Required entry points:

- `Audio.compose_spawn_sequence(region_id, tile_id, player_id)`  
- `Audio.sample_region_ambience(region_id, tile_id, player_id)`

These functions:

- Must call `H.sample_all` or related getters.
- Must return abstract descriptors (tags, weights, RTPC values, cue IDs), not direct engine calls.

Engine‑specific audio middleware integration (FMOD, Wwise, Unreal, Godot, etc.) must live behind a separate adapter and must not be called directly from these policy functions.

### 3.3 Mood Contract API (Lua)

Each DreadForge mood must provide a Lua module with at least:

- `on_player_spawn(region_id, tile_id, player_id)`  
- `on_tick(delta_seconds)`

**Example module name:** `moods.DreadForge_Resonance.Contract`

These functions:

- Must query invariants via `H.*`.
- Must respect mood contract JSON ranges for invariants and experience metrics (see section 4).
- Must not perform engine‑specific work directly; they may call into `Audio.*` and other policy modules.

### 3.4 C++ Adapter

**Namespace:** `HorrorAudioDirector` and related classes under `cpp/adapters/`.

Required responsibilities:

- Maintain a Lua state and load `horror_invariants`, `horror_audio`, and mood modules.
- Transfer invariant snapshots into Lua or fetch them from Horror.Place APIs.
- Convert `Audio.*` descriptors into engine audio parameters (FMOD/Wwise/Unreal/Godot) without hardcoding invariant logic.

Example shape:

```cpp
class HorrorAudioDirector {
public:
    void OnRegionTileChanged(PlayerId player,
                             RegionId region,
                             TileId tile,
                             const InvariantSample& sample);

    void OnSpawn(PlayerId player,
                 RegionId region,
                 TileId tile,
                 const InvariantSample& sample);

    void Tick(PlayerId player,
              float deltaSeconds,
              const InvariantSample& sample);

private:
    void ApplyRTPCs(PlayerId player,
                    const std::map<std::string, float>& rtpcs);

    void PlayAbstractCue(PlayerId player,
                         const AudioCueDescriptor& cue);
};
```

DFAS does not fix a single C++ API shape, but any adapter must uphold DF‑API‑1 and DF‑CI rules.

---

## 4. Schemas and Contracts

### 4.1 Mood Contract Schema

**File:** `schemas/mood_contract.schema.json`

DreadForge moods must validate against this schema, which enforces:

- `mood_id` naming: `^mood\.[a-z0-9_\.]+\.v[0-9]+$`
- All numeric bands (`CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `SHCI`, `LSG`, `DET`, `RWF`, `UEC`, `EMD`, `STCI`, `CDL`, `ARR`) defined as:
  - `{ "min": 0.0–1.0, "max": 0.0–1.0 }` value objects
- `HVF_mag` range defined similarly.
- No unknown keys (`additionalProperties: false`).

The schema is aligned with the Horror.Place core schema style (Draft 2020‑12, canonical `schemaHorror.Place.core.schemas.*` URIs).

### 4.2 DreadForge Mood Contract

**File:** `moods/mood.dreadforge_resonance.v1.json`

This contract:

- Defines required invariant bands for tile classes such as `battlefront_tile`, `spawn_tile`, and `liminal_tile`.
- Declares `experience_targets` ranges for `UEC`, `EMD`, `STCI`, `CDL`, `ARR`.
- Serves as the reference specification for all “combat horror” integrations (for example, spawn zones in shooters).

Example structure (abbreviated):

```json
{
  "mood_id": "mood.dreadforge_resonance.v1",
  "version": "1.0.0",
  "tile_profiles": [
    {
      "tile_class": "spawn_tile",
      "invariant_floor": { "CIC": 0.60, "LSG": 0.65, "HVF_mag": 0.40 },
      "invariant_ceiling": { "CIC": 1.00, "LSG": 1.00, "HVF_mag": 1.00 }
    }
  ],
  "experience_targets": {
    "UEC": { "min": 0.55, "max": 0.85 },
    "EMD": { "min": 0.60, "max": 0.90 },
    "STCI": { "min": 0.55, "max": 0.80 },
    "CDL": { "min": 0.65, "max": 0.90 },
    "ARR": { "min": 0.75, "max": 1.00 }
  }
}
```

**Enforcement rule:** Any tile marked with a class in this contract must have runtime invariant values that fall within the specified floor/ceiling bounds. Violations must be logged and may trigger fallback behavior (for example, reselecting a spawn tile).

### 4.3 Mood Registry

**File:** `registry/moods.json`

Each mood entry must include:

- `mood_id`
- `path` → JSON contract file path
- `lua_module` → Lua module implementing behavior
- `requires_hooks` → array of required Lua functions (for example, `["on_player_spawn", "on_tick"]`)

Example:

```json
{
  "mood.dreadforge_resonance.v1": {
    "path": "moods/mood.dreadforge_resonance.v1.json",
    "lua_module": "moods.DreadForge_Resonance.Contract",
    "requires_hooks": [
      "on_player_spawn",
      "on_tick"
    ]
  }
}
```

---

## 5. CI Enforcement Rules

DreadForge compliance requires at minimum:

1. **Schema Validation (JSON)**  
   - All `moods/mood.*.json` files must validate against `schemas/mood_contract.schema.json`.  
   - CI must fail the build on any schema violation.

2. **Lua Module Linting**  
   - `scripts/mood_lint.lua` must be run in CI.  
   - It must ensure that for each mood in `registry/moods.json`, the referenced Lua module exists and exports all hooks listed in `requires_hooks`.  
   - Missing modules or hooks fail the build.

3. **No Raw Content in Contracts**  
   - Contracts must not embed raw horror content (dialogue, scene text, descriptive gore).  
   - Only abstract invariants, metrics, tags, and opaque IDs are allowed.

4. **Spawn and Liminal Integrity Checks (Recommended)**  
   - For projects adopting DreadForge, add engine‑side CI or test jobs that simulate or scan all spawn and liminal tiles and verify:
     - `CIC`, `LSG`, and `HVF_mag` satisfy DreadForge mood bands.
     - Tiles that fail are reported or blocked from shipping.

5. **Versioning**  
   - Changes to `DreadForge-Standard.md`, `schemas/mood_contract.schema.json`, or any `mood.dreadforge_resonance.*` file must bump the mood version (for example, `v1` → `v2`) and update `registry/moods.json`.

---

## 6. Adoption Guidelines for External Studios

External projects integrating DreadForge are expected to:

- Import the `schemas/`, `moods/`, `registry/`, `engine/library/`, and `cpp/adapters/` subsets appropriate to their engine.
- Wire engine events (`spawn`, `tick`, `region_change`) into DreadForge Lua hooks.
- Use Horror.Place invariant APIs (HTTP or baked NDJSON → Lua) instead of defining bespoke invariant systems.
- Run the same schema and mood lints in their CI pipelines.

Projects that satisfy all requirements may display the “DreadForge Atmosphere Integrity Standard” badge on their marketing and technical materials.

---

## 7. Current Progress and File Placement Summary

This section summarizes the current logical placement and status of key DreadForge‑related pieces across the VM‑constellation. It is a checklist of “where files live,” not a list of contents.

### 7.1 Horror.Place (Tier‑1 core)

Already specified or partially present in your docs:

- `README.md` — public core repo overview and charter.  
- `schemas/`  
  - `invariantsv1.json` — invariant structure (`CIC`, `MDI`, `AOS`, etc.).  
  - `entertainmentmetricsv1.json` — player metrics (`UEC`, `EMD`, `STCI`, `CDL`, `ARR`).  
  - `stylecontractv1.json`, `personav1.json`, `regionv1.json`, `auditentryv1.json`.  
  - `mood_contract.schema.json` — explicit schema for mood bands.  
- `registry/`  
  - `events.json`, `styles.json`, `personas.json`, `regions.json` — map IDs → contracts.  
  - `moods.json` — includes the DreadForge entry and Lua hooks.  
- `moods/`  
  - `mood.dreadforge_resonance.v1.json` — DreadForge combat mood contract.  
- `engine/library/`  
  - `horror_invariants.lua` — canonical invariant API.  
  - `horror_audio.lua` — audio policy layer.  
  - `moods/DreadForge_Resonance.Contract.lua` — battlefield‑style integration logic.  
- `cpp/adapters/`  
  - `HorrorAudioDirector.h`, `HorrorAudioDirector.cpp` — engine audio adapter stub.  
- `scripts/`  
  - `mood_lint.lua` — Lua mood hook linter.  
  - Other schema linters and generators described in CI docs.  
- `.github/workflows/` or `.circleci/config.yml`  
  - Workflows for schema validation, mood linting, leak detection, etc.

**New / clarified file in this spec:**

- `DreadForge-Standard.md` — this spec in the repo root.

### 7.2 HorrorPlace‑Constellation‑Contracts

This repo is the governance spine for the constellation:

- `schemas/` — `contractCard` schemas, `prismMeta`, `agentProfile` schemas.  
- `contracts/` — high‑level contractCards for moods, events, personas, styles (including DreadForge references as doctrinal entries).  
- `registry/` — cross‑repo mapping: which moods and schemas live in which Tier‑2 repos.  
- `docs/` — extended VM‑constellation description, AI‑copilot rules, and structural blueprints.

DreadForge here is a doctrinal entry and cross‑repo reference, not implementation code.

### 7.3 HorrorPlace‑Atrocity‑Seeds (Tier‑2 vault)

This vault holds seeds and invariant packs:

- `schemas/` — seed schemas: region seeds, tileset seeds, multi‑sensory seeds.  
- `seeds/` — `region_invariant_pack.*` files: NDJSON or JSON carrying `CIC/MDI/AOS/LSG/HVF/SPR` gradients for archetypes (war_trauma, backrooms, marsh, etc.).  
- `moods/` (optional) — additional mood contracts specialized for underground content (with Tier‑2 constraints).  
- `ci/` and workflows for hashing/signing seeds and ensuring they match schema.

DreadForge seeds for war/battlefront maps can live here, referenced from Tier‑1 registries by `deadledgerref` or equivalent.

### 7.4 HorrorPlace‑Black‑Archivum

This is the trauma and history archive:

- `schemas/` — `event_atomic`, `site_profile`, `derivative_inference`.  
- `archives/` — NDJSON histories that generate or justify high `CIC/MDI/AOS/SHCI` in seeds.

DreadForge uses this via invariant bundles; it does not live here as code.

### 7.5 Horror.Place‑Orchestrator

Service that propagates updates:

- Polls vaults for new signed seeds/contracts.  
- Verifies signatures and hashes.  
- Updates Tier‑1 registries (including `moods.json` and `regions.json`) when new DreadForge‑compatible data is ready.

### 7.6 External Engine Repos / Game Projects

For each engine integration (for example, Godot kit, Unreal plugin, Battlefield‑style SDK):

- `engine/{engine_name}/` — engine‑specific bindings to `H.*` APIs and DreadForge moods.  
- `examples/` — minimal map or level showing DreadForge spawn/battlefront behavior.  

These repos pull in `DreadForge-Standard.md` as the normative reference and must keep their adapters consistent with the API surface defined here.

---

*This specification is a living document. Last updated: 2026‑01‑XX*  
*© 2026 Horror$Place Consortium. Licensed under Apache 2.0.*
