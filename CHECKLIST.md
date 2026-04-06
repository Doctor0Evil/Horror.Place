# HorrorPlace Authoring Checklist (VM‑Constellation Safe)

This checklist defines the minimum structure and sequencing rules for new files
generated for the HorrorPlace constellation (Horror.Place, Atrocity-Seeds,
Black-Archivum, Spectral-Foundry, Death-Engine, Constellation-Contracts,
Obscura-Nexus, Orchestrator).

AI and human authors **must** follow this order:
1. Schema / contract shape
2. Registry entry
3. Data bundle / seed
4. Lua logic
5. Engine adapter / orchestration glue

---

## 1. Invariant and Metric Schemas

**Target repo:** `Horror.Place`

Before creating events, moods, or seeds, ensure schemas exist or are updated.

- [ ] `schemas/invariants_v1.json`
  - Defines fields: `CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `RWF`, `DET`, `HVF`, `LSG`, `SHCI`
  - Each has:
    - `"type": "number"`
    - `"minimum": 0.0`
    - `"maximum": 1.0` (or documented exception like `DET` bands)
- [ ] `schemas/entertainment_metrics_v1.json`
  - Defines: `UEC`, `EMD`, `STCI`, `CDL`, `ARR` in `[0.0, 1.0]`
- [ ] `schemas/mood_contract.schema.json`
  - Required fields:
    - `moodId` (e.g. `"mood.dreadforgeresonance.v1"`)
    - `tileClass` (e.g. `"spawnTile"`, `"battlefrontTile"`, `"liminalTile"`)
    - `invariants`: per‑field `{ "min": number, "max": number }`
    - `metrics`: per‑field `{ "targetMin": number, "targetMax": number }`
    - `requiredHooks`: array of hook names (`"onPlayerSpawn"`, `"onTick"`, …)

**Rule:** Never add a mood/event without a schema‑validated contract.

---

## 2. Registry Files

**Target repo:** `Horror.Place` (global indices), plus repo‑local registries.

### 2.1 Mood registry

- [ ] `registry/moods.json`
  - Structure:
    - `registry_version`
    - `registry_id`: `"mood_registry_v1"`
    - `$schema`: `schemas/mood_registry_v1.json`
    - `version`: `"1.x.y"`
    - `moods`: array of:
      - `moodId`
      - `path` (JSON contract path)
      - `luaModule` (e.g. `"moods.DreadForgeResonance.Contract"`)
      - `requiredHooks`: matches `mood_contract.schema.json`
      - `status`: `"active" | "experimental" | "deprecated"`

### 2.2 Event / atrocity registries

**Target repo:** `HorrorPlace-Atrocity-Seeds`

- [ ] `registry/events_atrocity_seeds.json`
  - Fields:
    - `registry_version`, `registry_id`
    - `$schema`: `https://horror.place/schemas/events-registry-v1.json`
    - `version`
    - `created_at`, `updated_at`
    - `events`: array of:
      - `event_id` and `eventId` (namespaced)
      - `title`
      - `descriptionRef`
      - `path`
      - `hash` (or `null` until CI fills)
      - `regionRef`
      - `invariantBundleRef`
      - `bundle_ref`
      - `safetytier`, `intensity_band`
      - `deadledgerref` object + `deadledger_ref` string
      - `region_anchors`
      - optional `invariants_summary` (CIC/AOS/DET/SHCI…)
      - optional `metrics_intent_summary` (UEC/ARR/CDL…)
      - `status`, `version`
    - `registry_metadata`
    - `audit_trail` entries

**Rule:** Registry entries must reference valid bundle IDs and existing schema
versions before any Lua or adapter code is written.

---

## 3. Invariant Bundles and Seeds

**Target repo:** `HorrorPlace-Black-Archivum`, `HorrorPlace-Atrocity-Seeds`

### 3.1 Invariant bundles

- [ ] `contracts/invariant_bundles/<region>_<topic>_vN.json`
  - Fields:
    - `bundleId`
    - `regionId`
    - `tiles`: array of tiles with:
      - `tileId`
      - invariants (`CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `RWF`, `DET`, `HVF`, `LSG`, `SHCI`)
    - provenance metadata (source, author, RWF hints)

### 3.2 Seed packs (NDJSON)

- [ ] `seeds/<region>_invariant_pack_vN.ndjson`
  - Each line:
    - `seedId`
    - `regionId`
    - `tileId`
    - subset of invariants (at least `CIC`, `AOS`, `DET`, `LSG`, `SHCI`)

**Rule:** CI validates all bundles and seed packs against invariant schemas
before any contract points to them.

---

## 4. Lua Policy Modules

**Target repo:** `Horror.Place`

### 4.1 Invariants API

- [ ] `engine/library/horror_invariants.lua`
  - Exports:
    - `H.CIC(regionId, tileId)`
    - `H.MDI(regionId, tileId)`
    - `H.AOS(regionId, tileId)`
    - `H.RRM(regionId, tileId)`
    - `H.FCF(regionId, tileId)`
    - `H.SPR(regionId, tileId)`
    - `H.RWF(regionId, tileId)`
    - `H.DET(regionId | playerId)`
    - `H.HVF(regionId, tileId)`
    - `H.LSG(regionId, tileId)`
    - `H.SHCI(regionId, tileId)`
    - `H.UEC(playerId)`
    - `H.EMD(playerId)`
    - `H.STCI(playerId)`
    - `H.CDL(playerId)`
    - `H.ARR(playerId)`
    - `H.sampleHistory(regionId, tileId)`
    - `H.sampleAll(regionId, tileId, playerId)`

**Rule:** All systems must query through `H.*` rather than touching raw tables.

### 4.2 Mood modules

- [ ] One Lua file per mood under `moods/`, e.g.
  - `moods/DreadForgeResonance.Contract.lua`
- [ ] Must export at least hooks listed in `registry/moods.json`:
  - `onPlayerSpawn(regionId, tileId, playerId, role)`
  - `onTick(deltaSeconds, regionId, playerState)`
- [ ] Hooks must:
  - call `H.sampleAll(...)` before deciding behavior
  - enforce the mood contract bands (invariants + metrics)
  - return structured tables describing actions (no engine calls)

---

## 5. Engine Adapters and Directors

**Target repos:** `Death-Engine`, `Horror.Place-Orchestrator`, engine‑specific
integration repos.

- [ ] C/C++ adapters (e.g. `cpp/adapters/HorrorAudioDirector.h/.cpp`):
  - Hold a Lua state
  - Load `horror_invariants.lua`, mood modules, and director modules
  - Translate abstract Lua tables into engine calls (audio, VFX, AI)
- [ ] Director Lua modules (e.g. `engine/SurpriseDirector.lua`):
  - Use `H.*` and BCI adapters
  - Implement peaking/dying curves for Surprise.Events!
  - Never bypass entitlement / mood contracts

---

## 6. CI / Linting Requirements

**Target repo:** all constellation repos

- [ ] JSON Schema validation workflow:
  - Validate all `schemas/*.json` as self‑consistent
  - Validate all `contracts/*.json`, `registry/*.json`, `events/*.json`,
    `invariant_bundles/*.json` against schemas
- [ ] Lua mood linter:
  - `scripts/mood_lint.lua`:
    - Load `registry/moods.json`
    - Require each `luaModule`
    - Assert all `requiredHooks` exist
- [ ] Invariant bundle linter:
  - Ensure all invariants in bundles/seeds are within allowed ranges
- [ ] Dead‑Ledger integration checks (where applicable):
  - Recompute file hashes
  - Compare with `deadledgerref` envelopes if configured

**Rule:** No PR can merge if:
- A registry references a non‑existent file or module
- A mood module is missing required hooks
- Any invariant is out of contract or schema range

---
