---
title: AFCS Hellscape Audio Standard
version: 1.0.0
doctype: spec-v1
tiers:
  - public
schemaref:
  - schema.Horror.Place.core.schemas.invariantsv1.json
  - schema.Horror.Place.core.schemas.entertainmentmetricsv1.json
  - schema.Horror.Place.core.schemas.audiolandscape_style_v1.json
  - schema.Horror.Place.core.schemas.moodcontractv1.json
---

# AFCS Hellscape Audio Standard

## 1. Purpose and Scope

The AFCS Hellscape Audio Standard defines an invariant-driven, mixer- and binaural‑field architecture for Horror.Place, turning audio into a systemic substrate rather than a collection of ad‑hoc event sounds. It formalizes how Hellscape Mixer and binaural field components must read invariants, entertainment metrics, and mood contracts to generate ambient beds, spectral pressure, and localized motifs, before any high‑level event SFX are considered. [file:18][file:22]

This document applies to the Tier 1 `Horror.Place` core (schemas, Lua APIs, public contracts), and to Tier 2/3 repos that declare AFCS‑compliant audio styles and mapping profiles, such as `HorrorPlace-Codebase-of-Death`, `HorrorPlace-Neural-Resonance-Lab`, and `HorrorPlace-Redacted-Chronicles`. [file:18][file:15][file:23]

---

## 2. Core Concepts and Invariants

AFCS audio is strictly invariant‑driven: every decision must flow through a `QueryHistoryLayer → SetBehaviorFromInvariants → DriveEngineAudio` pipeline. [file:18][file:22]

### 2.1 Invariant and Metric Spine

Hellscape audio must treat the following as its primary input vector:

- History layer: `CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `SHCI`, `RWF`.  
- Spatial layer: `HVF` (mag, direction), `LSG`, `DET`.  
- Experience metrics: `UEC`, `EMD`, `STCI`, `CDL`, `ARR`. [file:22]

These values are read via the canonical `H.` API (Lua side), never via ad‑hoc tables:

- `H.CIC(regionId, tileId)`
- `H.MDI(regionId, tileId)`
- `H.AOS(regionId, tileId)`
- `H.RRM(regionId, tileId)`
- `H.FCF(regionId, tileId)`
- `H.SPR(regionId, tileId)`
- `H.SHCI(regionId, tileId)`
- `H.HVF(regionId, tileId)` → `{ mag, dir_x, dir_y }`
- `H.LSG(regionId, tileId)`
- `H.RWF(regionId, tileId)`
- `H.DET(playerId)`
- `H.UEC(playerId)`
- `H.EMD(playerId)`
- `H.STCI(playerId)`
- `H.CDL(playerId)`
- `H.ARR(playerId)`
- `H.sampleAll(regionId, tileId, playerId)` → table bundling the above. [file:18][file:22]

**Rule AFCS‑A1:** All Hellscape audio logic (Lua, C/C++, engine scripts) must use `H.` to obtain invariants and metrics. No component may hardcode or bypass these values. [file:18]

### 2.2 AFCS Audio Roles

AFCS identifies two primary audio systems:

- **Hellscape Mixer:** invariant‑driven ambient and spectral bed generator; owns density, pressure, texture, and negative space. [file:18][file:23]
- **Binaural Field:** localized orbits and presence field around the listener; owns spatial clustering, directionality, and entity‑adjacent cues. [file:18]

High‑level events (e.g., SURP.SYSTM.* Systemic Timing mechanics) request *deltas* or *motifs* from these systems instead of directly playing SFX. [file:16][file:18]

---

## 3. Contract Surfaces

### 3.1 `audiolandscape_style_v1` Schema (Conceptual)

`audiolandscape_style_v1` is the canonical style contract describing how invariant bands map to abstract audio families and RTPC targets. It lives in `core/schemas/audiolandscape_style_v1.json` and is referenced by `registry/styles.json`. [file:18]

At a high level, a style contract contains:

- `styleId`: e.g., `AUDIO.HELLSCAPE.DEFAULT.V1`.  
- `bands`: list of entries, each with:
  - `invariants`: min/max for `CIC`, `AOS`, `LSG`, `HVF.mag`, `SHCI`, etc.  
  - `families`: weights for abstract sound families (e.g., `industrial_rumble`, `war_echo`, `ritual_tone`, `marsh_insects`).  
  - `rtpcTargets`: desired ranges for AFCS audio RTPCs (e.g., `base.intensity`, `noise.grain`, `stereo.width`, `pressure.lf`).  
- `metricIntent`: expected effect on `UEC`, `EMD`, `STCI`, `CDL`, `ARR` in that band. [file:18][file:22]

The schema does not expose raw curve math; it only declares bands, tags, and numeric envelopes. Curve families are implemented behind the scenes in libraries. [file:15]

**Rule AFCS‑C1:** Audio styles must be engine‑agnostic: they specify families, RTPC ranges, and metric intents, never engine-specific buses or file paths. [file:18][file:15]

### 3.2 Mood Contracts and Audio

Mood contracts (e.g., `mood.dreadforgeresonance.v1`) define invariant bands per tile class and target metric bands; audio consults these to choose intensity and density. [file:18]

Hellscape Mixer uses:

- Tile class (`spawntile`, `battlefronttile`, `liminaltile`, etc.) from the active mood.  
- Mood `invariantFloor` / `invariantCeiling` to clamp or boost local audio density, ensuring DreadForge‑style thresholds are respected. [file:18]

**Rule AFCS‑C2:** If a mood contract is active, Hellscape Mixer must treat its invariant bands as hard floors/ceilings for audio pressure and spectral density; styles may refine behavior, but never contradict mood thresholds. [file:18]

---

## 4. Lua Policy Layer

All systemic audio decisions must pass through a narrow Lua surface, in the same style as `horrorinvariants.lua` and `horroraudio.lua` from the DreadForge spec. [file:18]

### 4.1 Canonical Modules

- `engine/library/horrorinvariants.lua`  
- `engine/library/horroraudio.lua`  
- `engine/library/binaural_field.lua`  

These modules are the only accepted Lua entry points for audio policy logic.

#### 4.1.1 `horroraudio.lua`

Conceptual shape:

```lua
-- engine/library/horroraudio.lua
local H = require("engine.library.horrorinvariants")

local Audio = {}

-- Core Hellscape query: called once per tick for each active region/player.
function Audio.sample_region_ambience(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    -- 1. Classify invariant band and mood class.
    -- 2. Select audiolandscape_style_v1 band.
    -- 3. Compute RTPC targets: base.intensity, noise.grain, stereo.width, pressure.lf, etc.
    -- 4. Apply DET-aware caps and safety envelopes.
    -- 5. Return a pure data table, no engine calls.
    return {
        tags = { "hellscape", "war_echo" },
        rtpc = {
            ["base.intensity"] = 0.72,
            ["noise.grain"]   = 0.45,
            ["pressure.lf"]   = 0.60,
            ["stereo.width"]  = 0.30,
        },
        orbits = {
            -- Declarative binaural orbit descriptors, e.g., spectral loops or artillery ghosts.
        }
    }
end

-- Optional focused call for spawn audio.
function Audio.compose_spawn_sequence(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    -- Compute a short spawn motif descriptor, respecting DET, mood, and style.
    return {
        pattern_id = "DF_SPAWN_DEFAULT",
        rtpc = { ["spawn.hit"] = 0.9 },
        tags = { "spawn", "dreadforge" }
    }
end

return Audio
```

Policy modules never call engine APIs; they only return tables the adapter layer consumes. [file:18]

#### 4.1.2 `binaural_field.lua`

Conceptual shape:

```lua
-- engine/library/binaural_field.lua
local H = require("engine.library.horrorinvariants")

local Binaural = {}

-- Returns orbit descriptors for binaural localization.
function Binaural.sample_field(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    -- Use HVF direction, CIC, SHCI to place orbits that echo local trauma.
    return {
        center_bias = { x = inv.HVF.dir_x, y = inv.HVF.dir_y },
        density = 0.5,
        orbits = {
            {
                id = "spectral_shells",
                count = 3,
                radius = 4.0,
                drift_rate = 0.1,
                clarity = inv.SPR,
            }
        }
    }
end

return Binaural
```

**Rule AFCS‑L1:** All Lua audio modules must read invariants via `H.` and return *only* pure descriptor tables. No direct engine calls, file paths, or bus names are allowed. [file:18][file:22]

---

## 5. Engine Adapter Layer

The adapter layer translates Lua descriptors into engine audio calls. It must be thin and deterministic. [file:18][file:23]

### 5.1 Responsibilities

Per engine (e.g., Unreal, Godot), an adapter component must:

- Maintain a Lua state and load `horrorinvariants`, `horroraudio`, and `binaural_field`. [file:18]
- Once per frame (or at a tuned cadence), call:

  - `Audio.sample_region_ambience(regionId, tileId, playerId)`  
  - `Binaural.sample_field(regionId, tileId, playerId)`

- Map returned `rtpc` values into engine RTPCs / parameters (e.g., Wwise RTPCs or FMOD parameters). [file:15]
- Instantiate or update audio components to realize `orbits` descriptions spatially. [file:18]

Adapter code may be engine‑specific but must never re‑implement invariant logic.

**Rule AFCS‑E1:** Engine adapters may only consume descriptor tables and must not perform their own invariant or metric lookups; all such logic resides in Lua modules and shared libraries. [file:18]

---

## 6. Event Layer Integration

Event‑driven systems (e.g., Systemic Timing mechanics) operate as a *delta layer* on top of Hellscape Mixer. [file:16][file:18]

- **Systemic Timing events** like `SURP.SYSTM.SCHEDJUMP.MUTABLE.v1` instruct audio to temporarily adjust specific RTPCs (e.g., tension pulses) rather than play hard‑coded stingers. [file:16]
- Event Lua stubs call into `horroraudio.lua` to request motif descriptors, then annotate event contracts with tags and expected metric shifts; engine code binds those tags to banks or templates. [file:16][file:18]

**Rule AFCS‑EV1:** Events may not bypass Hellscape Mixer; they must request motifs or RTPC deltas via the audio policy layer to ensure consistency with invariants and mood contracts. [file:16][file:18]

---

## 7. Hex‑Coded Mapping Families (Research Tier)

AFCS audio supports an optional research layer where audio RTPC mappings are implemented as hex‑coded mapping families, owned by Rust and Tier 3 labs. [file:15]

### 7.1 Hex Mapping Concept

- Each mapping family (e.g., `0xPKLIN`, `0xPKSIG`, `0xPKHYS`) defines a function from invariants + metrics + optional BCI fields to RTPC targets (e.g., `pressure.lf`, `whisper.send`, `stereo.width`). [file:15]
- Families are implemented in Rust, with safety envelopes and mutation rules; Lua and engine scripts treat them as opaque profile IDs. [file:15]

AFCS audio contracts must not expose hex codes directly; instead, styles reference local `audioProfileId` values that resolve to hex families in lab repos. [file:15]

**Rule AFCS‑R1:** Hex‑coded mapping families and their parameter vectors are confined to Tier 3 research repos; public schemas reference only profile IDs, not family codes. [file:15][file:23]

---

## 8. Safety and DET Enforcement

Hellscape audio must respect `DET` at all times, treating it as a master cap on exposure to intense pressure and spectral density. [file:22]

- Lua policy clamps RTPC targets when `DET(playerId)` exceeds configured thresholds.  
- Rust research layers enforce additional slope caps and overload limits when experimenting with BCI‑driven mappings. [file:15][file:22]

**Rule AFCS‑S1:** No audio mapping may push RTPCs beyond DET‑scaled comfort envelopes; if computed values exceed envelopes, they must be clamped before reaching engine RTPCs. [file:15][file:22]

---

## 9. CI and Linting Requirements

To prevent flat or inconsistent soundscapes, AFCS audio requires CI enforcements similar to DreadForge: [file:18]

- **Schema validation:** All `audiolandscape_style_v1` contracts must validate against the core schema.  
- **Lua module linting:** A script `scripts/audio_lint.lua` must verify that `horroraudio.lua` and `binaural_field.lua` export required functions and that no forbidden engine calls exist.  
- **Invariant coverage checks:** Headless jobs sample invariants and metrics across test maps and flag regions where mood contracts demand high CIC/LSG/HVF but audio styles or policies would yield low intensity or no spectral presence. [file:18][file:23]

**Rule AFCS‑CI1:** Builds must fail if any region or tile classified as liminal, battlefront, or high‑CIC lacks corresponding Hellscape audio density according to mood and style contracts. [file:18]

---

## 10. Telemetry and Empirical Loop

AFCS audio is designed for empirical evolution:

- Telemetry logs per‑tick audio RTPC states, invariants, and entertainment metrics, tagged by style ID and audio profile ID. [file:15][file:22]
- Tier 3 tools (Kotlin) analyze these logs to correlate mapping profiles with changes in `UEC`, `ARR`, `CDL`, and `STCI`, under different invariant contexts. [file:15]

Validated profiles may then be promoted into default styles or policy presets.

**Rule AFCS‑T1:** Audio telemetry must capture enough context (style ID, mood ID, invariants, metrics, RTPCs) to empirically evaluate mapping performance and support promotion/demotion of mapping profiles. [file:15][file:22]

---

## 11. Placement in the VM‑Constellation

Within the broader constellation:

- Tier 1 `Horror.Place` hosts this spec, core schemas, public styles, and Lua policy modules. [file:18][file:23]
- Tier 2 vaults (e.g., `HorrorPlace-Codebase-of-Death`) host additional styles, mood variants, and extended audio profiles bound to specific seeds and personas. [file:23]
- Tier 3 labs (`Neural-Resonance-Lab`, `Redacted-Chronicles`) host hex mapping families, Rust mutation engines, and BCI‑aware RTPC experimentation, exposed only via profile IDs and telemetry summaries. [file:15][file:23]

AFCS Hellscape Audio thus becomes the canonical, invariant‑driven audio standard linking history, mood, and empirical research into one coherent sound engine.
