---
title: Spectral Audio Seeds v1 – Hellscape Mixer Catalog
version: 1.0.0
doctype: audio-preset-catalog
tier: 1
role: Human-facing catalog of invariant-driven audio presets for seed generation and engine wiring
invariants_used:
  - CIC
  - MDI
  - AOS
  - RRM
  - SPR
  - SHCI
  - DET
  - HVF
  - LSG
metrics_used:
  - UEC
  - EMD
  - ARR
  - CDL
tiers:
  - standard
deadledger_surface:
  - zkpproof_schema
  - verifiers_registry
---

# Spectral Audio Seeds v1 – Hellscape Mixer Catalog

This document defines a Tier‑1, GitHub‑safe catalog of **spectral** audio preset families for the Hellscape Mixer and Dread Conductor surfaces. Each entry is a preset family, not a single sound, and is designed to be consumed by schema‑driven seeds (e.g., `audiotypedseedv1.json`) and engine policy layers (Lua + Rust), not by game code directly.[file:34]

All presets are implication‑only descriptions bound to invariants and entertainment metrics; they never reference raw audio assets or file paths. Engines select and blend these families by ID using invariants and metrics, then map them to concrete sound objects and RTPC curves via the Hellscape Mixer and Spectral Library.[file:34][file:9]

## 1. Usage in the VM‑Constellation

Spectral audio presets are intended to be used as follows:

- **Seed contracts** (e.g., `audiotypedseedv1.json`) reference preset IDs as part of their `stylerefs` or equivalent style/preset fields, never embedding asset details.[file:34]
- **Hellscape Mixer** (`hellscapemixer.rs`) reads region invariants (CIC, MDI, AOS, RRM, SPR, SHCI, DET, HVF, LSG) and session metrics (UEC, EMD, STCI, CDL, ARR), filters seeds and presets by eligibility bands, and produces a time‑segmented plan of sound‑object IDs and RTPC values.[file:34]
- **Lua audio map APIs** (e.g., `enginelibrary/horroraudio.lua` or `engineaudio/hellscapeaudiomap.lua`) expose high‑level functions like `Audio.pickSeed` and `HellscapeAudio.buildForRegion`, returning abstract sequence descriptors `{ presetId, weight, layers }` or `SegmentCommand` arrays to engine adapters.[file:34]
- **Engine adapters** (Godot, Unreal, FMOD, Wwise) translate RTPC names and sound IDs into actual routing, panning, HRTF presets, and DSP graphs without altering invariant/metric logic.[file:34]

This keeps invariants and metrics as the governing layer for when and how presets can manifest, while the preset IDs and names remain human‑readable handles for CHAT_DIRECTOR, designers, and CI linting.[file:29][file:34]

## 2. Canonical Preset Table – Spectral Audio Seeds v1

Each entry below is a preset family. Invariants and metrics are expressed as **typical operating bands**, not hard schema caps; concrete gating is enforced in seed contracts and mixer code using the same ranges and semantics.[file:34][file:9]

### Table 1 – Spectral Preset Families

| ID   | Canonical Name                 | Invariant Focus (typical bands)                                                                                         | Metric Intent (UEC / EMD / ARR / CDL)                     | Primary Use in VM‑Constellation                                                                                                    |
|------|--------------------------------|--------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| A01  | Dead_Echoes                    | CIC 0.4–0.7, MDI 0.3–0.6, AOS 0.4–0.8; RRM low–mid                                                                        | UEC 0.6–0.8, EMD 0.5–0.7, ARR ≥ 0.7, CDL ≤ 0.5            | Catastrophe‑afterglow beds: distant impact tails, clipped voices, reverbs that decay into noise; suitable for ruins and crime sites with partially documented trauma.[file:34] |
| A02  | Demon_Grid                     | CIC 0.5–0.9, MDI 0.6–1.0, AOS 0.5–1.0; RRM mid–high, FCF high                                                             | UEC 0.7–0.9, EMD 0.7–1.0, ARR 0.6–0.9, CDL 0.5–0.7        | High‑MDI techno‑occult zones: modulation, bit‑crushed voices, glitched choirs; used where folklore and experiments overlap, emphasizing pattern‑heavy dread with ambiguity.[file:34] |
| A03  | Trapped_Phantom                | CIC 0.3–0.6, SHCI 0.7–1.0, SPR 0.6–1.0; HVF weak, LSG mid                                                                 | UEC 0.6–0.8, EMD 0.6–0.9, ARR ≥ 0.7, CDL ≤ 0.6            | Localized, high‑coupling entity loops: breaths through walls, repeating pleas, footsteps that never leave a room; tightly bound to a single tile or object with strong SHCI.[file:34] |
| A04  | Hellscape_Grasp                | CIC 0.7–1.0, MDI 0.5–0.9, DET 0.6–0.9; HVF strong, LSG high                                                               | UEC 0.5–0.7, EMD 0.7–1.0, ARR 0.4–0.7, CDL 0.5–0.8        | High‑intensity trauma fields: layered drones, metallic scrapes, pressure sweeps following HVF; used in battlefronts, boss arenas, or maximum‑dread corridors under DreadForge moods, with det‑capped exposure.[file:34][file:9] |
| A05  | Murder_Echoes                  | CIC 0.5–0.9, AOS 0.4–0.9, RRM mid; SHCI 0.6–1.0                                                                           | UEC 0.6–0.9, EMD 0.7–1.0, ARR ≥ 0.7, CDL 0.5–0.8          | Close‑range forensic horror: impacts, staggered heartbeats, half‑audible last words; surfaces in tiles tagged with clustered deaths and ritualized violence, staying implication‑only.[file:34][file:34] |
| A06  | Spectral_Void                  | CIC 0.2–0.5, MDI 0.2–0.5, AOS 0.7–1.0; SPR low–mid                                                                        | UEC 0.7–1.0, EMD 0.5–0.8, ARR ≥ 0.8, CDL 0.4–0.7          | “Missing history” soundfields: near‑silence, sub‑bass swells, distant unlocatable tones; used in high‑AOS archives, blackout zones, or redacted facilities where records are scarce.[file:34][file:9] |
| A07  | Interdimensional_Grinder       | CIC 0.5–0.9, MDI 0.5–1.0, LSG 0.6–1.0; HVF curling, SPR mid                                                                | UEC 0.6–0.8, EMD 0.7–1.0, ARR 0.5–0.8, CDL 0.6–0.8        | Liminal tearing presets: metal‑on‑geometry scraping, phasing engines, partial pitch‑shift swarms; triggered where LSG spikes and PCG introduces twisted topology along liminal corridors.[file:34][file:34] |
| A08  | Lair_of_Spectral_Frequencies   | CIC 0.4–0.8, MDI 0.6–1.0, RRM 0.6–1.0; SHCI high                                                                          | UEC 0.7–0.9, EMD 0.8–1.0, ARR 0.6–0.9, CDL 0.5–0.7        | “Boss habitat” ambience: dense harmonic clusters, persistent motifs, call‑and‑response chimes; used for core haunt nodes and repeating encounter hubs associated with a persistent entity.[file:34][file:20] |
| A09  | Unescapable_Darkness           | CIC 0.3–0.7, AOS 0.5–1.0, DET 0.5–0.9; SPR mid, HVF inward                                                                 | UEC 0.7–1.0, EMD 0.6–0.9, ARR ≥ 0.8, CDL 0.5–0.8          | Enclosure‑pressure sets: occluded room tone, distant movement circling the listener, “breathing” walls; used for maze cores and collapse events where exits close behind the player while caps respect DET.[file:34][file:9] |
| A10  | Tunnels_of_Ghouls              | CIC 0.4–0.8, MDI 0.5–0.9, LSG 0.5–1.0; HVF along corridors                                                                 | UEC 0.6–0.8, EMD 0.6–0.9, ARR 0.5–0.8, CDL 0.5–0.7        | Movement‑channeled soundscapes: scraping ahead and behind, echoing laughs, disturbed debris in sync with HVF; ideal for choke points, sewer runs, trench lines, and similar corridor systems.[file:34] |
| A11  | Rooms_of_Haunting_Voices       | CIC 0.3–0.6, MDI 0.6–1.0, AOS 0.3–0.7; SPR high indoors                                                                    | UEC 0.7–0.9, EMD 0.7–1.0, ARR 0.6–0.9, CDL 0.4–0.7        | Interior vocal clusters: overlapping whispers, arguments across eras, prayer loops; tied to rooms with repeated gatherings or interrogations, with intelligibility bounded by Tier‑1 rules.[file:34][file:34] |
| A12  | Black_Hallways                 | CIC 0.3–0.7, AOS 0.5–1.0, LSG 0.6–1.0; HVF forward/back                                                                    | UEC 0.7–1.0, EMD 0.6–0.9, ARR ≥ 0.8, CDL 0.5–0.8          | Archetypal corridor dread: narrowed stereo, disappearing footsteps, distant slams gated by LSG; used for “pure liminal” connector tiles between major regions, feeding corridor‑focused seeds.[file:34] |

All ranges and intents must be interpreted as **design envelopes**. The governing schemas (e.g., `audiolandscapestylev1.json`, `audiotypedseedv1.json`) and the Hellscape Mixer are responsible for enforcing exact min/max bands, DET caps, and per‑session exposure limits according to the VM‑constellation governance framework.[file:34][file:9]

## 3. Preset IDs and Engine‑Facing Handles

### 3.1. ID Convention

Preset IDs are simple, stable strings:

- Pattern: `A##.Name` where `A##` is a human‑readable catalog index and `Name` is a camel‑cased handle without spaces, matching the table above.
- Example IDs:  
  - `A01.Dead_Echoes`  
  - `A12.Black_Hallways`

These IDs are intended to be embedded in:

- Typed audio seed contracts (`stylerefs` or `presetIds` lists) under Tier‑2 Atrocity‑Seeds vaults.[file:34]
- Spectral Library registries (e.g., `registry_soundobjects.json`, `registry_audio_presets.json`) as classification tags for bundles of sound objects.[file:34]
- Lua policy code (e.g., `enginelibrary/horroraudio.lua`, `engineaudio/hellscapeaudiomap.lua`) purely as logical tags, never as filenames.[file:34]

### 3.2. Example Lua Usage (Policy Layer)

Within `enginelibrary/horroraudio.lua`, a high‑level selector might behave conceptually as:

```lua
-- Pseudo-code only; real implementation must live in engine repo.
local Presets = {
  A01 = "A01.Dead_Echoes",
  A12 = "A12.Black_Hallways",
  -- ... etc ...
}

-- Returns an abstract preset choice based on invariants, not assets.
function HorrorAudio.pickSpectralPreset(regionId, tileId, playerId)
  local inv = H.sampleAll(regionId, tileId, playerId)  -- CIC, MDI, AOS, RRM, SPR, SHCI, DET, HVF, LSG
  -- Example routing: high CIC + high AOS + high LSG → Black_Hallways
  if inv.CIC >= 0.3 and inv.CIC <= 0.7
     and inv.AOS >= 0.5 and inv.LSG >= 0.6 then
    return { preset = Presets.A12, weight = 0.8, layers = { "low_drones", "door_slams_sparse" } }
  end
  -- Fallbacks based on other invariant combinations...
  return { preset = Presets.A06, weight = 1.0, layers = { "void_floor", "far_tones" } }
end
```

The policy module returns a structured descriptor; the Rust Hellscape Mixer and engine adapters map this descriptor to concrete segments, sound IDs, and RTPC curves while respecting `audiolandscapestylev1` and `audiotypedseedv1` constraints.[file:34]

## 4. Integration with Schemas and Seeds

This catalog is not itself a schema or registry; it is a human‑facing reference that other machine‑readable contracts must align with:

- **Style schemas**: `schemas/audiolandscapestylev1.json` defines governance fields (safety tier, intensity band, `detcap`), invariant bindings, implication rules for metrics, seed‑byte mapping, RTPC hooks, and spatialization modes. Concrete styles (e.g., `audiolandscape_hellscape_mixerv1.json`) will reference these presets as part of their documentation and tagging.[file:34]
- **Typed seed schemas**: `schemas/audiotypedseedv1.json` binds individual audio seeds to invariant preconditions, metric envelopes, channel families, and `stylerefs` that may include IDs from this catalog.[file:34]
- **Registries**: vault‑side registries (e.g., `engineseeds/registry_audiotypedseeds.json`) track which seeds use which presets, their safety tiers, and their promotion status, enabling CI and Dead‑Ledger governance to reason about circulation and eligibility without exposing raw content.[file:34][file:40]

Any future expansion of this table must remain compatible with:

- The invariant ranges and metric semantics defined in `invariantsv1` and `entertainmentmetricsv1` schemas.[file:9]
- The Atrocity‑Seeds hellscape audio design (typed seeds, registry, Rust mixer, Lua façade), including safety constraints such as `explicit_violence_forbidden = true` for Tier‑1 audio descriptors.[file:34][file:18]

## 5. CI, Governance, and Evolution

Though this file is human‑facing, it participates in the same governance loop as other VM‑constellation artifacts:

- **Linting and CI**: scripts may validate that every preset row:
  - References only known invariants and metrics.
  - Uses ranges that are coherent with the canonical invariant scale (0–1 or 0–10 as specified in the invariants spine).
  - Documents metric intents that are consistent with configured caps for Tier‑1 content.[file:9][file:29]
- **Telemetry feedback**: telemetry from Hellscape Mixer runs (region, preset IDs, seeds, invariant/metric deltas) can be analyzed in Tier‑2/Tier‑3 repos (e.g., Spectral‑Foundry, Neural‑Resonance‑Lab) to tune preset ranges and add new families that perform well against UEC/EMD/ARR/CDL objectives.[file:34][file:15]
- **Dead‑Ledger integration**: high‑impact presets (e.g., those used in critical encounter regions) may eventually be linked to Dead‑Ledger proofs via higher‑tier descriptors, but this catalog intentionally contains no proofs, PII, or trauma data, only labels and invariant‑metric envelopes.[file:40]

This catalog should be treated as the canonical, Tier‑1 reference for spectral audio preset families leveraged by Hellscape Mixer and related audio systems. All future audio seed and style work that aims to participate in spectral, invariant‑driven soundscapes should either map onto these entries or clearly document why a new family is required.
