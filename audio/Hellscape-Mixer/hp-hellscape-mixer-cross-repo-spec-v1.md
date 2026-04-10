---
title: Hellscape Mixer Cross-Repository Audio Spec
version: 1.0.0
doctype: audio-constellation-spec
tier: 1
role: Cross-repository contract for invariant-driven audio
repos:
  - Horror.Place
  - HorrorPlace-Constellation-Contracts
  - HorrorPlace-Atrocity-Seeds
  - HorrorPlace-Spectral-Foundry
  - HorrorPlace-Neural-Resonance-Lab
  - HorrorPlace-Redacted-Chronicles
spine:
  invariants_schema: schema.Horror.Place.core.schemas.invariants.v1
  metrics_schema: schema.Horror.Place.core.schemas.entertainment-metrics.v1
  audiolandscape_schema: schema.Horror.Place.audio.audiolandscapeStyle.v1
  audiotyped_seed_schema: schema.Horror.Place.audio.audioTypedSeed.v1
  telemetry_schema_audio_rtpc: schema.Horror.Place.labs.audio-rtpc-mapping-telemetry.v1
---

# Hellscape Mixer Cross-Repository Audio Spec

This document defines how Hellscape Mixer and related audio logic are implemented across the Horror$Place VM-constellation. It ties style presets, typed seeds, Lua policies, engine adapters, and lab telemetry into one coherent, invariant-driven pipeline that spans Tier 1, Tier 2, and Tier 3 repositories.[file:18][file:34][file:9][file:15]

## 1. Roles by Repository

### 1.1 Horror.Place (Tier 1 – Core Spine)

Horror.Place is the source of truth for the invariant/metric schema spine, base audio contracts, and canonical Lua/engine APIs.[file:9][file:18]

Core responsibilities:

- Own and publish invariant and metric schemas:  
  - `schemas/core/invariantsv1.schema.json` (CIC, MDI, AOS, RRM, SPR, SHCI, DET, HVF, LSG).[file:9]  
  - `schemas/core/entertainmentmetricsv1.schema.json` (UEC, EMD, STCI, CDL, ARR and related bands).[file:9]
- Define core audio contracts:  
  - `schemas/audio/moodcontractv1.json` for mood envelopes and DreadForge-style atmosphere contracts.[file:18]  
  - `schemas/audio/audiolandscapestylev1.json` for audio landscape styles (governance fields, invariant bindings, implication rules, RTPC hooks).[file:34]
- Provide canonical Lua APIs:  
  - `lua/enginelibrary/horrorinvariants.lua` – public `H.` invariants API (`H.sampleAll`, region/tile snapshots).[file:9][file:34]  
  - `lua/enginelibrary/horrormetrics.lua` – current entertainment metric view (UEC, EMD, STCI, CDL, ARR) for directors.[file:9]  
  - `lua/enginelibrary/horroraudio.lua` – policy façade for selecting Hellscape presets/seeds based on invariants and metrics.[file:34]  
  - `lua/enginelibrary/binaural_field.lua` – spatial/binaural orbit policy returning abstract orbit plans driven by HVF/LSG/SHCI/DET.[file:15][file:18]
- Host engine adapters:  
  - Unreal: `Source/HorrorPlace/Public/HorrorAudioDirector.h` / `.cpp` – drives middleware RTPCs and sound components from Lua mixers.[file:18]  
  - Unreal: `Source/HorrorPlace/Public/HorrorBinauralFieldComponent.h` / `.cpp` – consumes orbit plans from `binaural_field.lua`.[file:15]  
  - Godot/Unity equivalents can follow the same adapter pattern and live in platform-specific subdirectories.

Horror.Place never stores raw audio; it only defines schemas, Lua APIs, and adapter code that operate on style/preset and seed IDs plus RTPC values.[file:18][file:34]

### 1.2 HorrorPlace-Constellation-Contracts (Tier 1 – Contract Authority)

Constellation-Contracts encodes cross-repo contract shapes for audio and ensures schemas remain consistent across vaults and labs.[file:9]

Core artifacts:

- Mirrored schema IDs and registry entries for audio contracts:  
  - `schemas/audio/audiolandscapestylev1.json` – shared definition with Horror.Place as schema authority.[file:34]  
  - `schemas/audio/audiotypedseedv1.json` – contract for invariant-aware, metric-bounded audio seeds.[file:34]
- Registry schemas and manifest contracts for audio and surprise mechanics:  
  - `schemas/registry/registry-audioTypedSeeds.v1.json` – NDJSON row shape for audio seed registries in vault repos.[file:34]  
  - `schemas/registry/registry-audioStyles.v1.json` – NDJSON row shape for styles/presets (e.g., Hellscape Mixer, spectral seeds).[file:34][file:18]
- Shared documentation templates:  
  - `docs/audio/audio-style-spec-template-v1.md` – spec template for any concrete `audiolandscapestylev1` instance.[file:34]  
  - `docs/audio/audio-typed-seed-spec-template-v1.md` – spec template for typed audio seeds bound to invariants and metrics.[file:34]

Constellation-Contracts is the single place CI checks that vault and lab repos only use valid schema IDs and registry shapes and that all audio artifacts are implication-only.[file:9][file:32]

### 1.3 HorrorPlace-Atrocity-Seeds (Tier 2 – Invariant-Tagged Audio Seeds)

Atrocity-Seeds is the Tier 2 vault for invariant-tagged audio seeds and related Hellscape Mixer engine code.[file:34][file:32]

Core artifacts:

- Audio schema and registry copies (using Tier 1 schema IDs):  
  - `schemas/audio/audiotypedseedv1.json` – validated against Constellation-Contracts ID.[file:34]  
  - `engineseeds/registry_audioTypedSeeds.json` – NDJSON registry of seed IDs, schema refs, safety tiers, invariant applicability bands, style/preset IDs, and hashes.[file:34][file:32]
- Engine-facing code:  
  - `engineaudio/hellscapemixer.rs` – Rust mixer that consumes invariant snapshots, metrics, style contracts, and audio seeds to produce `SegmentCommand` arrays per region/tile.[file:34]  
  - `engineaudio/hellscapeaudiomap.lua` – Lua façade that calls `H.sampleAll`, `Metrics.current`, and FFI into `hellscapemixer.rs`, returning abstract segment lists or preset/seed choices.[file:34][file:18]
- Seed bundles:  
  - `engineseeds/seeds_hellscape_baseline_v1.json` – bundle of initial typed audio seeds (e.g., ventilation rhythms, negativespace beds, spectral misdirection patterns) referencing style and preset IDs (such as the spectral seeds A01–A12 catalogued in Horror.Place).[file:34][file:18]

Atrocity-Seeds never stores raw audio files; it stores contracts and registries that describe how invariant/metric-driven seeds behave, ensuring deterministic, auditable audio logic.[file:34][file:32]

### 1.4 HorrorPlace-Spectral-Foundry (Tier 2 – Styles & Personas)

Spectral-Foundry defines audio landscape styles, persona hooks, and mapping profiles that sit above the invariant spine.[file:18][file:20]

Core artifacts:

- Concrete style contracts:  
  - `styles/audio/audiolandscape_hellscape_mixerv1.json` – implementation of `audiolandscapestylev1` describing bands, frequency focus, seed-byte mapping, and RTPC hooks for Hellscape mixes.[file:34]  
  - Additional style contracts, such as corridor dread, spectral void, and techno-occult grids, referencing invariant and metric intentions.
- Persona audio preferences:  
  - Persona contracts (e.g., `personas/archivist_audio_prefs.json`) specifying preferred audio styles, preset families, and mapping profile IDs for different SHCI personas.[file:20]  
  - Hooks into persona metrics and goals (e.g., Archivist preferring high ARR and EMD in high-AOS regions) that bias audio style and mapping selection without bypassing invariants or safety caps.[file:20][file:15]
- Middleware mappings:  
  - Bus layouts, RTPC mapping configs, and Wwise/MetaSounds/other graphs, represented as JSON/YAML config files that map abstract RTPC names (e.g., `bf_intensity`, `hellscape_pressureLF`, `spectral_stereoWidth`) into middleware parameters.[file:34][file:15]

Spectral-Foundry never overrides the core invariant/metric logic; it only narrows styles and preferences that plug into Hellscape Mixer and binaural field policy.[file:18][file:15]

### 1.5 HorrorPlace-Neural-Resonance-Lab & Redacted-Chronicles (Tier 3 – Empirical Evolution)

Neural-Resonance-Lab and Redacted-Chronicles own the experimental audio stack, with telemetry, hex-coded mapping families, and BCI integrations.[file:15][file:35]

Core artifacts:

- Telemetry schemas:  
  - `schemas/audio/audio_rtpc_mapping_telemetry_v1.json` – NDJSON schema for per-decision records capturing invariants, metrics, mapping family hex codes, RTPC outputs, and metric deltas (ΔUEC, ΔARR, ΔCDL, ΔEMD, ΔSTCI) over short windows.[file:15]  
  - BCI-related schemas such as `schemas/bci/bci-metrics-envelope-v1.json`, providing derived fields (`bciFearIndex`, `bciAttentionFocus`, `bciBreathPhase`) that may enter mapping functions at Tier 3 only.[file:35]
- Mapping family definitions:  
  - `mappings/audio/audio_mapping_family_index.json` – registry of hex-coded mapping families (e.g., `0xPKLIN`, `0xPKSIG`, `0xPKHYS`) and parameter ranges.[file:15]  
  - Kotlin or Rust implementations of the family formulas and wrappers that can be hot-swapped in experiments.
- Analysis and promotion tools:  
  - Kotlin analysis pipelines that compute expected metric deltas and risk rates for each family and parameter vector, ranking profiles by composite scores under safety constraints.[file:15]  
  - Scripts that generate promotion proposals as JSON changesets for Tier 1/Tier 2 mapping defaults, subject to human review.

Tier 3 never directly drives production engines; successful mappings are always promoted back as deterministic contract updates (e.g., updated style contracts, mapping profiles) in Horror.Place and Spectral-Foundry.[file:15][file:9]

## 2. Data Flow Overview

### 2.1 Core Runtime Path

1. **World state → invariants/metrics**  
   - Engine updates region/tile state and calls into `horrorinvariants.lua` and `horrormetrics.lua` to retrieve invariant and metric snapshots.[file:9][file:18]

2. **Lua policy → abstract audio plan**  
   - `horroraudio.lua` and `binaural_field.lua` read invariants and metrics, query Hellscape Mixer and seed registries, and return abstract descriptors:
     - For beds and events: lists of `SegmentCommand` or `{ presetId, seedId, weight, layers }` entries.[file:34]  
     - For spatial/binaural: orbit plans and field parameters (e.g., intensity, pressureLF, stereoWidth, orbit arrays).[file:15][file:18]

3. **Engine adapters → sound objects & RTPCs**  
   - Unreal/Godot/Unity adapters translate abstract descriptors into engine-specific calls:
     - Creating or updating audio components.  
     - Setting RTPC values based on abstract names defined in style contracts.[file:18][file:34]

4. **Telemetry (optional, Tier 3)**  
   - In experimental builds, each decision is logged to `audio_rtpc_mapping_telemetry_v1.ndjson` with input state, mapping family, RTPC outputs, and resulting metric deltas.[file:15]

### 2.2 Authoring & Promotion Path

1. **Designers & AI-augmented tools** build or refine:
   - Style contracts in Spectral-Foundry (`audiolandscapestylev1`).[file:34]  
   - Typed seeds in Atrocity-Seeds (`audiotypedseedv1`).[file:34]  
   - Preset catalogs in Horror.Place (`hp-audio-presets-spectral-seeds-v1.md`).[file:34]

2. **CI & CHAT_DIRECTOR** validate:
   - Schema conformity, invariant/metric field ranges, and Charter-compliant text.[file:9][file:34]  
   - Registry linkages and promotion rules in Constellation-Contracts.[file:9][file:32]

3. **Labs** run experiments:
   - Swap mapping families, run controlled sessions, and log audio RTPC telemetry.[file:15]  
   - Analyze results and generate promotion PRs.

4. **Core repos** accept successful mappings:
   - Update default mapping profiles in style contracts and Lua policy modules (e.g., coefficients for linear/sigmoid curves in `binaural_field.lua` or Hellscape Mixer).[file:15][file:18]

## 3. Required Schemas and Modules (By Name)

This section summarizes the concrete schema and module names every tier must implement or consume.

### 3.1 Schemas (JSON)

Tier 1 (Horror.Place / Constellation-Contracts):

- `schemas/core/invariantsv1.schema.json` – invariant vocabulary (CIC, MDI, AOS, RRM, SPR, SHCI, DET, HVF, LSG).[file:9]  
- `schemas/core/entertainmentmetricsv1.schema.json` – entertainment metrics (UEC, EMD, STCI, CDL, ARR).[file:9]  
- `schemas/audio/moodcontractv1.json` – mood contracts and DreadForge envelopes.[file:18]  
- `schemas/audio/audiolandscapestylev1.json` – audio landscape style contract.[file:34]  
- `schemas/audio/audiotypedseedv1.json` – typed audio seed contract.[file:34]  
- `schemas/audio/audio_rtpc_mapping_telemetry_v1.json` – telemetry shape (mirrored or referenced in Tier 3).[file:15]

Tier 2 (Atrocity-Seeds / Spectral-Foundry):

- `schemas/audio/audiotypedseedv1.json` – local copy with canonical `$id` from Tier 1.[file:34]  
- `registry/registry-audioTypedSeeds.v1.json` – NDJSON entry schema for audio seeds.[file:34]  
- `registry/registry-audioStyles.v1.json` – NDJSON entry schema for style contracts.[file:34][file:9]

Tier 3 (Neural-Resonance-Lab / Redacted-Chronicles):

- `schemas/labs/audio_rtpc_mapping_telemetry_v1.json` – telemetry envelope; references Tier 1 invariant and metric schema IDs.[file:15]  
- `schemas/bci/bci-metrics-envelope-v1.json` – BCI metrics envelope for lab-only input signals.[file:35]

### 3.2 Lua Modules

Tier 1 (Horror.Place):

- `lua/enginelibrary/horrorinvariants.lua`  
  - Functions: `H.sampleAll(regionId, tileId, playerId)`, plus helpers for HVF/LSG/historical coupling.[file:9]

- `lua/enginelibrary/horrormetrics.lua`  
  - Functions: `Metrics.current(regionId, playerId)` returning UEC, EMD, STCI, CDL, ARR.[file:9]

- `lua/enginelibrary/horroraudio.lua`  
  - Functions:  
    - `HorrorAudio.pickSpectralPreset(regionId, tileId, playerId)` → preset descriptor (e.g., `A12.Black_Hallways`).[file:34]  
    - `HorrorAudio.buildBedPlan(regionId, tileId, playerId)` → segment list based on Hellscape seeds and styles.[file:34]

- `lua/enginelibrary/binaural_field.lua`  
  - Functions:  
    - `BinauralField.plan(regionId, tileId, playerId)` → orbit plan and field parameters driven by HVF/LSG/SHCI/DET.[file:15][file:18]

Tier 2 (Atrocity-Seeds):

- `engineaudio/hellscapeaudiomap.lua`  
  - Functions:  
    - `HellscapeAudio.buildForRegion(regionId, tileId, moodId)` → calls `hellscapemixer.rs` via FFI, returns segment commands or preset/seed mixes.[file:34]

Tier 2 (Spectral-Foundry):

- Optional helper modules for persona-aware preferences (e.g., `lua/persona/audio_prefs_archivist.lua`) that annotate or filter style selections without bypassing `H.` APIs.[file:20][file:18]

## 4. Spatial & Binaural Integration

Hellscape Mixer and binaural field logic are coordinated but separable:

- Hellscape Mixer handles **landscape-level** beds and rhythmic structures, structured via styles and seeds.[file:34]  
- Binaural field policy handles **near-field and head-centric** behaviors, structured via `binaural_field.lua` orbit plans and mapped through engine adapters.[file:15][file:18]

Both components:

- Use invariants and metrics as shared inputs, particularly CIC, AOS, SHCI, HVF, LSG, DET, UEC, ARR, CDL.[file:9][file:18]  
- Output abstract RTPCs and identifiers using a shared vocabulary agreed between Horror.Place and Spectral-Foundry.[file:34][file:15]  
- Are subject to the same safety and exposure caps (DET, metric envelopes, Charter filters).[file:34][file:18]

## 5. CI and Governance Hooks

Every repository participating in this constellation must:

- Validate JSON artifacts against the canonical schema IDs defined in Horror.Place and Constellation-Contracts, using AJV or equivalent validators in CI.[file:9][file:34]  
- Run content-leak and Charter-compliance scans to ensure no raw audio or explicit content leaks into contracts, markdown, or registries.[file:32][file:34]  
- For Tier 2/Tier 3 audio experiments, attach promotion metadata (e.g., originating telemetry runs, mapping family IDs, confidence intervals) when proposing changes to Tier 1 mapping defaults.[file:15]

This spec should be maintained alongside other Hellscape Mixer documentation in `audio/Hellscape-Mixer`, and referenced by schema and contract docs across the constellation whenever audio behavior crosses repository boundaries.[file:18][file:34][file:9]
