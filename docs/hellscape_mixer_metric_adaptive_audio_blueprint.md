# From Seed to Spectral Library: Blueprint for the Hellscape Mixer

## 1. Purpose and Fit in the VM-Constellation

The Hellscape Mixer is the canonical, invariant- and metric-driven audio subsystem for Horror.Place’s sovereign horror engine. Its role is to turn history-layer invariants and entertainment metrics into deterministic, explainable audio instructions, never raw horror content. [file:10][file:11]

The system:

- Operates on **contracts**, not ad-hoc code: JSON schemas define audio styles and seeds, and Rust/Lua/Godot act as interpreters of those contracts.
- Reads from the shared invariant spine (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI) and entertainment metrics (UEC, EMD, STCI, CDL, ARR). [file:10]
- Produces time-segmented, engine-agnostic audio commands that Godot can execute without making its own high-level horror decisions. [file:10]

The Hellscape Mixer sits beside the existing core modules:

- `src/spectrallibrary.rs` – invariant API and Spectral layer. [file:10]
- `src/pcg_generator.rs` – history-aware map generation. [file:10]
- `src/audio_automation.rs` – invariant-driven audio foundations. [file:11]

This blueprint specifies a metric-adaptive audio layer that stands on those foundations and integrates with the cross-tier VM-constellation doctrine. [file:10][file:11]

---

## 2. Contract-First Audio: Schemas and Style Governance

### 2.1 Audio Style Schema: `audiolandscapestylev1.json`

An audio style is a public, GitHub-safe contract that defines how a family of horror soundscapes behaves under different invariant and metric conditions, without referencing any raw audio. [file:10]

**Filename**

- `schemas/audiolandscapestylev1.json`

**Conceptual intent**

- Encodes the “grammar” for a style: where it is allowed (invariant ranges), what it is trying to do psychologically (metric deltas), which safety tier it belongs to, and how seed bytes map to parameters. [file:10][file:11]

**Key sections**

1. **Governance**

   - `id`: Stable style ID, e.g., `HELLSCAPE.MARSH.OPACITY.V1`.
   - `version`: Semantic version, e.g., `v1.0`.
   - `safetytier`: `standard | mature | research`. [file:11]
   - `allowedbuilds`: Array of build profiles (`standard`, `mature`, `research`) that can route into this style, aligned with `Cargo.toml` feature flags. [file:11]
   - `detcap`: Maximum effective DET the style is allowed to push toward for any region/session. [file:10][file:11]
   - `intensityband`: Nominal perceived intensity band, e.g., `low`, `medium`, `high`, `escalation`. [file:10]

2. **Invariant bindings**

   - `invariantbindings.min`: Minimum invariant levels for the style to be considered.

     - Example fields:

       - `CIC`, `AOS`, `RRM`, `FCF`, `SPR`, `RWF`, `DET`, `HVF`, `LSG`, `SHCI` in `[0.0, 1.0]`. [file:10]

   - `invariantbindings.recommended`: Hints for the router; float values in `[0.0, 1.0]` representing *ideal* conditions where the style is most effective.

   These bindings explicitly state, for example, that a style is only valid in high-AOS marsh regions with strong ritual residue and high SHCI, making it a natural candidate for echoing ritual experiments and archival gaps. [file:10]

3. **Metric expectations**

   - `implicationrules.metric_deltas`:

     - `deltaUEC`: Expected change in Uncertainty Engagement Coefficient.
     - `deltaEMD`: Expected change in Evidential Mystery Density.
     - `deltaSTCI`, `deltaCDL`, `deltaARR`: Expected shifts for safe-threat contrast, cognitive dissonance, and ambiguity. [file:10][file:11]

   - These are *targets*, not guarantees; they form the basis for telemetry validation and future tuning. [file:10][file:11]

4. **Distraction and pattern structure**

   - `distraction_types`: Enumerated, typed distraction modes, e.g.:

     - `peripheral_rattle`, `distant_mechanism`, `threshold_whisper`, `negative_space_pulse`. [file:11]

   - `pattern_structures`:

     - Formal description of pattern classes: intermittent motifs, rising/falling clusters, liminal spikes at LSG discontinuities. [file:10][file:11]

   These fields are used by Rust to build pattern templates from seeds rather than improvised logic.

5. **Seed byte mapping**

   - `seed_byte_mapping`: A formally defined interpretation of seed bytes, e.g.:

     - Byte 0 → `primary_band` (low, mid, high).
     - Byte 1 → `spatial_motion_mode` (static, orbit, drift, approach).
     - Byte 2 → `density_cluster` index.
     - Byte 3 → `transition_profile` (sharp, easing, stuttering). [file:10]

   - Each mapping entry includes:

     - `byte_index`
     - `parameter_name`
     - `value_table` or `value_function` descriptor (e.g., modulo mapping). [file:10]

The schema itself is pure structure and ranges, with no asset IDs or explicit content, aligning with Tier 1 constraints. [file:10][file:11]

---

### 2.2 Typed Audio Seed Schema: `audiotypedseedv1.json`

Typed seeds instantiate styles as measurable, metric-aware agents. [file:10]

**Filename**

- `schemas/audiotypedseedv1.json`

**Conceptual responsibilities**

- Bind a concrete seed string or hash to:

  - A parent style.
  - Narrowed invariant ranges.
  - More specific metric delta goals.
  - Optional runtime identifiers for Spectral Library lookups. [file:10][file:11]

**Key fields**

- `id`: Seed ID, e.g., `SEED.HELLSCAPE.SWAMP.01`.
- `style_id`: Reference to `audiolandscapestylev1.json` contract. [file:10]
- `seed_string`: Opaque hex/base64 seed or human-readable phrase; Rust will hash this deterministically.
- `invariantwindow`: Context where this seed is valid:

  - Ranges for `CIC`, `AOS`, `RRM`, `SPR`, `SHCI`, etc., often narrower than the parent style. [file:10]

- `metric_targets`:

  - Expected local deltas or envelopes per metric; e.g.,

    - `UEC: { min_delta: 0.05, max_delta: 0.15 }`
    - `EMD: { min_delta: 0.1, max_delta: 0.25 }`. [file:11]

- `telemetry_tag`: Optional label used to correlate telemetry (UEC, EMD, etc.) back to this seed in Tier 2/3. [file:10][file:11]

Typed seeds become traceable units in the Dead-Ledger and Spectral Foundry registries: each run of a seed produces metric telemetry tied back to this contract. [file:10][file:11]

---

## 3. Metric- and Invariant-Aware Audio Logic in Rust

### 3.1 Rust Module: `src/hellscape_mixer.rs`

The Rust module is the performance-critical core of the Hellscape Mixer. It is stateless and deterministic with respect to input contracts and state. [file:10][file:11]

**Filename**

- `src/hellscape_mixer.rs`

**Core function**

```text
fn build_mix(
    style: &AudioLandscapeStyle,
    seed: &AudioTypedSeed,
    invariant_state: &InvariantState,
    metric_state: &MetricState,
) -> Vec<SegmentCommand>
```

**Inputs**

- `AudioLandscapeStyle`: Rust struct derived from `audiolandscapestylev1.json`. [file:10]
- `AudioTypedSeed`: Struct from `audiotypedseedv1.json`. [file:10]
- `InvariantState`:

  - Numeric snapshot of region invariants (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI) for the region/tile. [file:10]

- `MetricState`:

  - Current UEC, EMD, STCI, CDL, ARR for the player or session. [file:11]

**Outputs**

- `Vec<SegmentCommand>` – a time-ordered list of self-contained audio commands. [file:10]

### 3.2 SegmentCommand Contract

`SegmentCommand` is the bridge between deterministic logic and engine-specific execution. [file:10]

**Fields**

- `sound_id`: Abstract identifier referencing a spectral audio object in the Spectral Library registry, not a direct file path. [file:10][file:11]
- `start_time`: Time offset in seconds from the seed mix start.
- `duration`: Segment length in seconds.
- `rtpc_params`: List of `(rtpc_name, value)` pairs, such as:

  - `("CIC_RUMBLE_INTENSITY", 0.7)`
  - `("AOS_DISTORTION_LEVEL", 0.4)`
  - `("RRM_CHANT_DENSITY", 0.5)`
  - `("UEC_TENSION_SCALE", 0.6)` [file:10][file:11]

- `routing_tags`: Optional tags for bus routing, e.g., `["MARSH", "LOW_BAND", "THRESHOLD_EDGE"]`. [file:11]

### 3.3 Internal Logic Contract

Inside `build_mix`, the Rust module:

1. **Validates preconditions**

   - Checks that current invariants satisfy `style.invariantbindings.min` and `seed.invariantwindow` before generating any segments. [file:10]
   - Ensures `safetytier` and `detcap` are respected; if DET is already above the cap, the mix may downshift intensity. [file:11]

2. **Derives parameter tape**

   - Hashes `seed.seed_string` using a stable hash (e.g., Blake2b) to produce a byte array. [file:10]
   - Applies `style.seed_byte_mapping` to interpret bytes into discrete parameters:

     - Spectral band selections, spatial motion modes, density patterns, onset offsets. [file:10]

3. **Queries invariants and metrics**

   - Uses invariant values (CIC, AOS, RRM, HVF, LSG, SHCI) to bias:

     - Where in time high-intensity clusters appear (e.g., near LSG spikes).
     - Which distraction types are more likely (e.g., threshold whispers in high-LSG). [file:10]

   - Uses metrics (UEC, EMD, STCI, CDL, ARR) to decide:

     - Whether to increase uncertainty (raising UEC) via subtle, ambiguous cues.
     - Whether to stabilize or spike CDL by introducing dissonant or aligning patterns. [file:11]

4. **Generates segment plan**

   - Produces a series of segments with:

     - Start times arranged according to style’s pattern and seed-derived randomness.
     - Durations constrained by style rules and detcap.
     - RTPC values tuned to gently push metrics toward `style.implicationrules.metric_deltas` and `seed.metric_targets`, respecting global safety bounds. [file:10][file:11]

5. **Returns declarative plan**

   - Outputs `Vec<SegmentCommand>` without asset details or engine-specific routing. Asset selection is performed later via registries and Godot. [file:10][file:11]

---

## 4. Lua Orchestration Layer: History and Metrics Query

### 4.1 Lua Facade: `engine/audio/hellscape_audio_map.lua`

Lua acts as the orchestration layer that gathers context, enforces sovereign APIs, and calls into Rust. [file:10][file:11]

**Filename**

- `engine/audio/hellscape_audio_map.lua`

**Canonical API**

```lua
HellscapeAudio = {}

function HellscapeAudio.build_for_region(region_id, style_id, seed)
    -- 1. Query history layer invariants
    local invariants = H.sample_all(region_id)
    local det       = H.det(region_id)

    -- 2. Query entertainment metrics
    local metrics   = Metrics.current()

    -- 3. Build InvariantState and MetricState objects
    local invariant_state = {
        CIC  = invariants.CIC,
        MDI  = invariants.MDI,
        AOS  = invariants.AOS,
        RRM  = invariants.RRM,
        FCF  = invariants.FCF,
        SPR  = invariants.SPR,
        RWF  = invariants.RWF,
        DET  = det,
        HVF  = invariants.HVF,
        LSG  = invariants.LSG,
        SHCI = invariants.SHCI,
    }

    local metric_state = {
        UEC  = metrics.UEC,
        EMD  = metrics.EMD,
        STCI = metrics.STCI,
        CDL  = metrics.CDL,
        ARR  = metrics.ARR,
    }

    -- 4. Load style and seed contracts from registries
    local style_contract = Styles.get_style(style_id)
    local seed_contract  = Styles.get_audio_seed(style_id, seed)

    -- 5. Call Rust mixer through FFI bridge
    local segment_commands = HellscapeMixer.build_mix(
        style_contract,
        seed_contract,
        invariant_state,
        metric_state
    )

    return segment_commands
end
```

**Responsibilities**

- **QueryHistoryLayer**: All calls go through `H.*` APIs; Lua never bypasses invariants. [file:10]
- **Metrics snapshot**: Uses `Metrics.current()` or equivalent Telemetry interface, not ad-hoc metric storage. [file:10][file:11]
- **Contract loading**: Uses style and seed registries, e.g., `registrystyles.json`, future `registry_audiostyles.json`, not raw paths. [file:10]
- **No decision-making**: Lua does not decide *what* horror to deliver; it only coordinates inputs for Rust. [file:10][file:11]

---

## 5. Godot Runtime Execution: Seed Clock and Bus Routing

### 5.1 Region Audio Root Scene

Godot executes the audio plan using a dedicated region-level scene. [file:10]

**Conceptual node structure**

- `HellscapeRegionAudioRoot` (Node):

  - Owns a `SeedClock` child and a reference to a `HellscapeBusController`.
  - On region enter, it calls `HellscapeAudio.build_for_region(region_id, style_id, seed)` via Lua/GDScript bridge. [file:10]

- `SeedClock` (Node/Timer):

  - Maintains an internal clock starting at `t=0` when a seed mix is activated.
  - Schedules segment dispatch based on `SegmentCommand.start_time`. [file:10]

- `HellscapeBusController` (Node):

  - Receives each `SegmentCommand` at its scheduled time.
  - Resolves `sound_id` into a specific `AudioStreamPlayer` or bus assignment.
  - Applies RTPC values by setting parameters on buses, filters, and effect chains. [file:10][file:11]

### 5.2 Godot Event Flow

1. `HellscapeRegionAudioRoot` receives `segment_commands` from Lua.
2. It passes the list to `SeedClock`.
3. `SeedClock`:

   - Sorts commands by `start_time`.
   - Uses a timer to call back into `HellscapeBusController` when each segment should start. [file:10]

4. `HellscapeBusController`:

   - Looks up `sound_id` in a local registry that maps IDs to `AudioStreamPlayer` nodes, banks, or buses.
   - Sets RTPC parameters using Godot’s audio API (volume, filter cutoff, sends, etc.).
   - Starts/stops playback as directed by the segment. [file:10][file:11]

The runtime never infers new horror logic; it simply honors the declarative plan from Rust. This enforces the sovereignty doctrine: Godot is an executor, not an author. [file:10][file:11]

---

## 6. Invariants, Metrics, and Audio Behavior

### 6.1 Invariants Driving Audio Decisions

The Hellscape Mixer uses invariants to decide *what* types of audio manifestations are permitted and where intensity can safely rise. [file:10][file:11]

**Examples**

- **High CIC, high HVF**:

  - Favors low-frequency rumble, metal strain, distant structural groans aligned with haunt-vector direction. [file:10]

- **High AOS, high RWF**:

  - Increases archival and glitch-like audio (radio static, cut-out voices) with contradictory patterns, supporting information-ambiguity. [file:10]

- **High RRM, high LSG**:

  - Biases toward ritual motifs near thresholds: doorframes, ridgelines, shorelines where liminal transitions occur. [file:10]

- **High SHCI**:

  - Requires spectral audio motifs to replay patterns tightly tied to local history (e.g., test procedures, evacuation sirens) rather than generic scares. [file:10]

### 6.2 Metrics Steering Mix Adaptation

Metrics modulate the style’s behavior over time. [file:11]

**Targets**

- **UEC (Uncertainty Engagement Coefficient)**:

  - Audio manipulates subtle cues, directional ambiguity, and negative space to maintain UEC within style-defined bands (e.g., 0.6–0.8). [file:11]

- **EMD (Evidential Mystery Density)**:

  - Layers evidence-like sounds (archival clicks, distant writing, murmurs) without resolving the source, raising EMD carefully. [file:11]

- **STCI (Safe-Threat Contrast Index)**:

  - Alternates calm ambience with ambiguous threat hints to reinforce safe/threat oscillation without overwhelming the player. [file:11]

- **CDL (Cognitive Dissonance Load)**:

  - Uses incongruent audio hints (e.g., sound suggesting a presence where visuals disagree) to increase CDL, but style contracts cap how far it can go. [file:11]

- **ARR (Ambiguous Resolution Ratio)**:

  - Avoids explicit confirmatory audio (e.g., clear dialogue resolving a mystery). Audio remains suggestive so ARR stays high. [file:11]

The Rust core uses current metric values and style/seed metric envelopes to choose which pattern structures and RTPC values to emphasize per segment. [file:10][file:11]

---

## 7. History-Coupled Audio Entities and SHCI

The Hellscape Mixer treats spectral audio phenomena as query results over the history layer, not as assets with independent agency. [file:10]

**Spectral-History Coupling Index (SHCI)**

- High SHCI requires that audio patterns:

  - Reenact specific historical patterns (e.g., timings of sirens, machine cycles) derived from CIC, AOS, RRM, and FCF. [file:10]
  - Align with HVF and LSG to anchor where in the region the strongest manifestations occur. [file:10]

The mixer uses:

- `CIC + RRM` to model which historical trauma/ritual is being echoed.
- `AOS + SPR + RWF` to decide whether the echo is clear, distorted, or rumored-only (e.g., distant, barely-audible hints). [file:10]
- `HVF + LSG + DET` to decide when and where to place high-intensity segments, guarding against exposure that exceeds DET caps. [file:10]

This ensures every audio phenomenon can be explained as a function of invariants and metrics, making it auditable and explainable. [file:10][file:11]

---

## 8. Telemetry, Evolution, and VM Circulation

The Hellscape Mixer participates in the broader telemetry-driven evolution loop across tiers. [file:10][file:11]

**Telemetry hooks**

- Each mix run logs:

  - `style_id`, `seed_id`.
  - Invariant snapshot.
  - Metric deltas (UEC, EMD, STCI, CDL, ARR) over the mix duration. [file:10][file:11]

- Telemetry is aggregated in Tier 3 (e.g., Neural-Resonance-Lab, Redacted-Chronicles) and exported as signed, anonymized summaries. [file:10][file:11]

**Feedback loop**

- Tier 2 vaults (e.g., Spectral-Foundry) use this telemetry to:

  - Evolve new seeds and style variants.
  - Rank seeds by entertainment efficacy and invariant fidelity. [file:10][file:11]

- Tier 1 updates style and seed contracts (via registries and schemas) to reflect successful patterns, keeping the public repository purely structural. [file:10]

The Hellscape Mixer thus becomes a circulatory organ: it reads history and state, emits audio instructions, and feeds back evidence about how those instructions affect player metrics. [file:10][file:11]

---

## 9. Implementation Checklist

To integrate the Hellscape Mixer into the Horror.Place constellation, the following steps are required:

1. **Tier 1: Schema and contract integration**

   - Add `schemas/audiolandscapestylev1.json`.
   - Add `schemas/audiotypedseedv1.json`.
   - Extend `registrystyles.json` (or introduce `registry_audiostyles.json`) to include style IDs and references to audio landscape style contracts and typed seeds. [file:10]

2. **Tier 1: Rust and Lua modules**

   - Implement `src/hellscape_mixer.rs` with `build_mix` respecting invariant and metric envelopes, `detcap`, and safety tiers. [file:10][file:11]
   - Implement `engine/audio/hellscape_audio_map.lua` as the canonical orchestration API, wired to `H.*` and `Metrics.*`. [file:10]

3. **Tier 1: Godot-facing spec**

   - Document `HellscapeRegionAudioRoot`, `SeedClock`, and `HellscapeBusController` in a Godot-facing spec file (e.g., `docs/hellscape_mixer_godot_integration.md`), detailing node responsibilities and the mapping from `sound_id` to audio graph. [file:10]

4. **Tier 2/3: Spectral Library alignment**

   - Ensure audio palettes in underground repos reference style/seed IDs and RTPC names defined in Tier 1 contracts, not hardcoded behaviors. [file:10][file:11]

5. **CI and validation**

   - Add schema validation for `audiolandscapestylev1.json` and `audiotypedseedv1.json` to existing CI scripts.
   - Extend telemetry pipelines to capture mix-level metric deltas keyed by `style_id` and `seed_id`. [file:10][file:11]

With these pieces in place, the Hellscape Mixer becomes a metric-adaptive, history-coupled audio engine that is consistent with Horror.Place’s doctrine: horror as machine-checkable implication, never unstructured, engine-local spookiness. [file:10][file:11]
