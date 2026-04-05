# DreadForge Atmosphere Integrity Standard (DFAS)

## 1. Purpose and Scope

DreadForge defines a minimal, invariant-driven standard for atmospheric integrity across horror and action titles that integrate with Horror.Place.

DFAS guarantees that:

- No runtime system (audio, PCG, AI, spawn logic) makes decisions without querying the invariant layer.
- Mood contracts and invariant bands enforce a minimum level of dread and atmospheric cohesion around critical spaces such as spawns, battlefronts, and liminal tiles.
- External studios and modders can treat DreadForge as a stable contract rather than a loose set of examples.

This document applies to:

- The public `Horror.Place` repository (schemas, registries, contracts, Lua/C++ stubs).
- Tier‑2 vaults that declare DreadForge-compliant moods, seeds, and events.
- Any engine or tool that consumes Horror.Place invariants and contracts.

## 2. Naming and Concepts

### 2.1 Core Name

- **DreadForge Atmosphere Integrity Standard (DFAS)**  
- Short reference: **DreadForge**

DreadForge is descriptive and community-friendly. It signals atmosphere enforcement rather than gore.

### 2.2 Invariants and Metrics

DreadForge relies on the Horror.Place invariant and metric spine:

- History layer: `CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `SHCI`
- Spatial/manifestation: `HVF`, `LSG`, `DET`, `RWF`
- Player-experience: `UEC`, `EMD`, `STCI`, `CDL`, `ARR`

DFAS requires that all participating systems access these values exclusively through the canonical `H.*` APIs (Lua/C++/HTTP), never via ad-hoc tables.

## 3. Minimal API Surface

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
- `H.sample_all(region_id, tile_id, player_id)`

**Rule DF‑API‑1:** All DreadForge-aware Lua code must obtain invariants and metrics through these functions.

### 3.2 Audio Policy API (Lua)

**Module:** `engine/library/horror_audio.lua`

Required entry points:

- `Audio.compose_spawn_sequence(region_id, tile_id, player_id)`
- `Audio.sample_region_ambience(region_id, tile_id, player_id)`

These functions:

- Must call `H.sample_all` or related getters.
- Must return abstract descriptors (tags, weights, RTPC values), not engine calls.

### 3.3 Mood Contract API (Lua)

Each DreadForge mood must provide a Lua module with at least:

- `on_player_spawn(region_id, tile_id, player_id)`
- `on_tick(delta_seconds)`

**Example module name:** `moods.DreadForge_Resonance.Contract`

These functions:

- Must query invariants via `H.*`.
- Must respect mood contract JSON ranges for invariants and experience metrics (see section 4).

### 3.4 C++ Adapter

**Namespace:** `HorrorAudioDirector` and related classes under `cpp/adapters/`.

Required responsibilities:

- Maintain a Lua state and load `horror_invariants`, `horror_audio`, and mood modules.
- Transfer invariant snapshots into Lua or fetch them from Horror.Place APIs.
- Convert Audio.* descriptors into engine audio parameters (FMOD/Wwise/Unreal/Godot) without hardcoding invariant logic.

DFAS does not fix a single C++ API shape, but any adapter must uphold DF‑API‑1 and DF‑CI‑rules.

## 4. Schemas and Contracts

### 4.1 Mood Contract Schema

**File:** `schemas/mood_contract.schema.json`

DreadForge moods must validate against this schema, which enforces:

- `mood_id` naming: `^mood\\.[a-z0-9_\\.]+\\.v[0-9]+$`
- All numeric bands (CIC, MDI, AOS, RRM, FCF, SPR, SHCI, LSG, DET, RWF, UEC, EMD, STCI, CDL, ARR) defined as `{ "min": 0.0–1.0, "max": 0.0–1.0 }`.
- `HVF.mag` range defined similarly.
- No unknown keys.

### 4.2 DreadForge Mood Contract

**File:** `moods/mood.dreadforge_resonance.v1.json`

This contract:

- Defines required invariant bands for `battlefront_tile`, `spawn_tile`, and `liminal_tile`.
- Declares `experience_targets` ranges for `UEC`, `EMD`, `STCI`, `CDL`, `ARR`.
- Serves as the reference specification for all “combat horror” integrations (e.g., spawn zones in shooters).

### 4.3 Mood Registry

**File:** `registry/moods.json`

Each mood entry must include:

- `mood_id`
- `path` → JSON contract file path
- `lua_module` → Lua module implementing behavior
- `requires_hooks` → array of required Lua functions (e.g., `["on_player_spawn", "on_tick"]`)

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

## 5. CI Enforcement Rules

DreadForge compliance requires at minimum:

1. **Schema Validation (JSON)**  
   - All `moods/mood.*.json` files must validate against `schemas/mood_contract.schema.json`.  
   - Fail the build on any schema violation.

2. **Lua Module Linting**  
   - `scripts/mood_lint.lua` must be run in CI.  
   - It must ensure that for each mood in `registry/moods.json`, the referenced Lua module exists and exports all hooks listed in `requires_hooks`.  
   - Missing modules or hooks fail the build.

3. **No Raw Content in Contracts**  
   - Contracts must not embed raw horror content (dialogue, scene text, descriptive gore).  
   - Only abstract invariants, metrics, tags, and opaque IDs are allowed.

4. **Spawn and Liminal Integrity Checks (Recommended)**  
   - For projects adopting DreadForge, add engine-side CI or test jobs that simulate or scan all spawn and liminal tiles and verify:
     - `CIC`, `LSG`, and `HVF.mag` satisfy DreadForge mood bands.
     - Tiles that fail are reported or blocked from shipping.

5. **Versioning**  
   - Changes to `DreadForge-Standard.md`, `mood_contract.schema.json`, or `mood.dreadforge_resonance.*` must bump the mood version (e.g., `v1` → `v2`) and update `registry/moods.json`.

## 6. Adoption Guidelines for External Studios

External projects integrating DreadForge are expected to:

- Import the `schemas/`, `moods/`, `registry/`, `engine/library/`, and `cpp/adapters/` subsets appropriate to their engine.
- Wire engine events (`spawn`, `tick`, `region_change`) into DreadForge Lua hooks.
- Use Horror.Place invariant APIs (HTTP or baked NDJSON → Lua) instead of defining bespoke invariant systems.
- Run the same schema and mood lints in their CI pipelines.

Projects that satisfy all requirements MAY display the “DreadForge Atmosphere Integrity Standard” badge on their marketing and technical materials.

---

## 2) Current progress and file placement summary

Based on the VM‑constellation documents you have, here is the current logical placement and status of key pieces. This is intended as a checklist of “where files live” rather than actual file contents.

### 2.1 Horror.Place (Tier‑1 core)

**Already specified or partially present in your docs:**

- `README.md` — public core repo overview and charter.  
- `schemas/`  
  - `invariantsv1.json` — invariant structure (CIC, MDI, AOS, etc.).  
  - `entertainmentmetricsv1.json` — metrics (UEC, EMD, STCI, CDL, ARR).  
  - `stylecontractv1.json`, `personav1.json`, `regionv1.json`, `auditentryv1.json`.  
  - `mood_contract.schema.json` — now explicit for mood bands.  
- `registry/`  
  - `events.json`, `styles.json`, `personas.json`, `regions.json` — map IDs → contracts.  
  - `moods.json` — now extended to include DreadForge entry and Lua hooks.  
- `moods/`  
  - `mood.dreadforge_resonance.v1.json` — DreadForge combat mood contract.  
- `engine/library/`  
  - `horror_invariants.lua` — canonical invariant API.  
  - `horror_audio.lua` — audio policy layer (Dread Conductor).  
  - `dreadforge_bf.lua` or `moods/DreadForge_Resonance.Contract.lua` — Battlefield‑style integration logic.  
- `cpp/adapters/`  
  - `HorrorAudioDirector.h`, `HorrorAudioDirector.cpp` — engine audio adapter stub.  
- `scripts/`  
  - `mood_lint.lua` — Lua mood hook linter.  
  - Other schema linters and generators described in your CI docs.  
- `.github/workflows/` or `/.circleci/config.yml`  
  - Workflows for schema validation, mood linting, leak detection, etc.

**New file from this answer:**

- `DreadForge-Standard.md` — the spec above in the repo root.

### 2.2 HorrorPlace-Constellation-Contracts

This repo is the governance spine for the constellation:

- `schemas/`  
  - `contractCard` schemas, `prismMeta`, `agentProfile` schemas.
- `contracts/`  
  - High‑level contractCards for moods, events, personas, styles (including DreadForge references as doctrinal entries).
- `registry/`  
  - Cross‑repo mapping: which moods and schemas live in which Tier‑2 repos.
- `docs/`  
  - Extended VM‑constellation description, AI‑copilot rules, and structural blueprints.

DreadForge here is a doctrinal entry and cross‑repo reference, not implementation code.

### 2.3 HorrorPlace-Atrocity-Seeds (Tier‑2 vault)

This vault holds seeds and invariant packs:

- `schemas/`  
  - Seed schemas: region seeds, tileset seeds, multi‑sensory seeds.  
- `seeds/`  
  - `region_invariant_pack.*` files: NDJSON or JSON carrying CIC/MDI/AOS/LSG/HVF/SPR gradients for archetypes (war_trauma, backrooms, marsh, etc.).  
- `moods/` (optional, if you decide to keep some moods here)  
  - Additional mood contracts specialized for underground content (with Tier‑2 constraints).  
- `ci/` and workflows for hashing/signing seeds and ensuring they match schema.

DreadForge seeds for war/battlefront maps can live here, referenced from Tier‑1 registry by `deadledgerref` or equivalent.

### 2.4 HorrorPlace-Black-Archivum

This is your trauma and history archive:

- `schemas/`  
  - `event_atomic`, `site_profile`, `derivative_inference`.  
- `archives/`  
  - NDJSON histories that generate or justify high CIC/MDI/AOS/SHCI in seeds.  

DreadForge uses this via invariant bundles; it does not live here as code.

### 2.5 Horror.Place-Orchestrator

Service that propagates updates:

- Python service that:
  - Polls vaults for new signed seeds/contracts.  
  - Verifies signatures and hashes.  
  - Updates Tier‑1 registries (including `moods.json` and `regions.json`) when new DreadForge‑compatible data is ready.

### 2.6 External engine repos / game projects

For each engine integration (e.g., Godot kit, Unreal plugin, Battlefield‑style SDK):

- `engine/{engine_name}/`  
  - Engine‑specific bindings to `H.*` APIs and DreadForge moods.  
- `examples/`  
  - Minimal map or level showing DreadForge spawn/battlefront behavior.  

These repos pull in `DreadForge-Standard.md` as the normative reference and must keep their adapters consistent with the API surface defined there.

---
