# H.Audio Mood Spine API

This document describes how engine audio code and Directors use the `HorroraudioMoods` helper to drive invariant‑ and BCI‑aware RTPCs from mood contracts, and how this composes with the shared audio mapping spine.

## 1. Position in the Spine

`horroraudio_moods.lua` is a thin, engine‑local helper that sits between three layers:

- **Contracts:** `moodcontractv1` JSON instances (e.g., `mood.subdued_dread.v1`, `mood.constant_pressure.v1`, `mood.combat_nightmare.v1`) authored in HorrorPlace‑Constellation‑Contracts.
- **Audio Spine:** Hex‑coded RTPC mapping families (`audiortpc-mapping-family-v1.json`) and per‑frame telemetry schemas defined in HorrorPlace‑Constellation‑Contracts and implemented in Rust/Kotlin backends.
- **Engine Audio:** The `H.Audio` Lua facade and engine‑specific adapters (e.g., `HorrorAudioDirector` in C/C++) that actually own RTPCs and audio events.

The mood API never encodes invariants, BCI math, or audio curves directly. Instead, it:

1. Loads mood contracts as data.
2. Reads RTPC band constraints from those contracts.
3. Snaps requested mood targets into those bands.
4. Calls the canonical `H.Audio` RTPC setters, which in turn are fed into Rust mapping engines and lab telemetry pipelines.

This keeps Horror.Place gameplay and Director code declarative with respect to mood and avoids per‑scene ad‑hoc audio logic.

## 2. Core Lua Surfaces

### 2.1 Module and Initialization

The helper lives at:

```text
lua/engine/horroraudio_moods.lua
```

and returns the `HorroraudioMoods` table. During engine startup, `horroraudio.lua` (or an equivalent bootstrap module) should:

```lua
local HorroraudioMoods = require("engine.horroraudio_moods")

-- Point this at the local checkout path that mirrors Constellation-Contracts schemas/mood.
HorroraudioMoods.preload_defaults("schemas/mood/")
```

`preload_defaults` expects the three canonical moods to be present:

- `schemas/mood/moodcontract.subdued_dread.v1.json`
- `schemas/mood/moodcontract.constant_pressure.v1.json`
- `schemas/mood/moodcontract.combat_nightmare.v1.json`

If any contract fails to load, the helper logs a warning and continues. CI in HorrorPlace‑Constellation‑Contracts should ensure these files always exist and validate.

### 2.2 Mood Application API

The module exposes a generic application function plus three convenience wrappers:

```lua
-- Generic:
HorroraudioMoods.apply_mood(mood_id, overrides?)

-- Canonical moods:
HorroraudioMoods.apply_subdued_dread(overrides?)
HorroraudioMoods.apply_constant_pressure(overrides?)
HorroraudioMoods.apply_combat_nightmare(overrides?)
```

The optional `overrides` table lets Directors nudge RTPC targets within the contract bands:

```lua
HorroraudioMoods.apply_constant_pressure({
    pressure       = 0.65,  -- target within [min,max] from the contract
    whisperDensity = 0.40
})
```

If no override is given for a channel, the helper uses the band midpoint `(min + max) / 2`.

Under the hood:

1. The helper looks up the mood contract in its cache by `moodId`.
2. It reads `rtpcBands` (e.g., `pressure`, `whisperDensity`, `hissLevel`, `archivalVoices`, `ritualMotif`).
3. For each band:
   - It chooses a target value (override or midpoint).
   - It clamps the value into `[band.min, band.max]`.
   - It calls `H.Audio` with that value.

The helper supports two `H.Audio` shapes:

- `H.Audio.set_rtpc(rtpc_name, value)` (preferred).
- `H.Audio[rtpc_name](value)` for engines that expose per‑channel functions like `H.Audio.pressure(value)`.

Engine code must ensure one of these surfaces is present and stable.

### 2.3 Optional Smoothing

The helper includes a small internal smoother that enforces per‑second velocity caps (if you want to do this in Lua instead of only in Rust):

```lua
HorroraudioMoods.smooth_and_apply(rtpc_name, target_value, max_delta_per_second, dt_seconds)
```

A typical pattern inside `horroraudio.lua`’s per‑frame tick is:

```lua
local dt = H.Time.delta_seconds()

-- Suppose a Director computed a raw target from invariants or game state:
local raw_pressure_target = 0.9

-- Enforce a stable rise capped at 0.6 per second:
HorroraudioMoods.smooth_and_apply("pressure", raw_pressure_target, 0.6, dt)
```

For now, smoothing is optional and independent of the per‑family `maxDeltaPerSecond` fields encoded in `audiortpc-mapping-family-v1.json`. Those Rust‑side safety envelopes still apply; Lua smoothing just avoids visibly harsh jumps in the engine RTPCs.

## 3. Calling Patterns from Directors

### 3.1 State Machines and Mood Selection

Directors should treat moods as discrete states in their behavior machines, not as free‑floating numeric tweaks. A simple pattern:

```lua
local current_mood = "subdued_dread"

local function update_region_mood(region, player_state, invariants)
    -- Example heuristic: escalate or de‑escalate based on scripted beats and invariants.
    if region:is_combat_hotspot() or invariants.DET > 0.50 then
        current_mood = "combat_nightmare"
    elseif invariants.CIC > 0.45 or invariants.AOS > 0.50 then
        current_mood = "constant_pressure"
    else
        current_mood = "subdued_dread"
    end
end

local function apply_current_mood()
    if current_mood == "subdued_dread" then
        HorroraudioMoods.apply_subdued_dread()
    elseif current_mood == "constant_pressure" then
        HorroraudioMoods.apply_constant_pressure()
    elseif current_mood == "combat_nightmare" then
        HorroraudioMoods.apply_combat_nightmare()
    end
end
```

`horroraudio.lua` typically:

1. Reads invariants and metrics via `H.Invariants` and `H.Metrics`.
2. Lets Directors compute the desired mood state and any overrides.
3. Delegates all RTPC band enforcement to `HorroraudioMoods`.

### 3.2 Overrides from Invariants and BCI

Directors should avoid bypassing the contracts; they should only modulate *within* bands. For example, to bias pressure by DET and BCI states:

```lua
local bci = H.BCI.snapshot(sessionId)
local inv = H.Invariants.snapshot()

local function compute_pressure_override()
    local base = 0.5
    local det_term = inv.DET * 0.3
    local fear_term = (bci and bci.fearBand == "HIGH") and 0.2 or 0.0
    return base + det_term + fear_term
end

local function apply_pressure_with_bci()
    local p = compute_pressure_override()
    HorroraudioMoods.apply_constant_pressure({ pressure = p })
end
```

The helper clamps to the contract’s `rtpcBands.pressure.[min,max]`. You do not need to, and should not, encode hard limits in Director code.

## 4. Composition with the Invariant‑Driven Audio Spine

### 4.1 Data Flow

At runtime, the intended flow for pressure‑like channels is:

1. **Invariants and Metrics:** `H.Invariants` and `H.Metrics` expose CIC/MDI/AOS/RRM/HVF/LSG/SHCI/DET and UEC/EMD/STCI/CDL/ARR snapshots.
2. **BCI State:** `H.BCI` exposes a discrete intensity mode and normalized BCI features (`bcifearindex`, `bciattentionfocus`, etc.) derived from the canonical EEG/BCI pipelines.
3. **Directors:** Use invariants, metrics, and BCI state to choose mood states and overrides.
4. **Mood Helper:** `HorroraudioMoods` snaps any requested RTPC values into the bands declared in `moodcontractv1` and calls `H.Audio`.
5. **Rust Mapping Engine:** Engine adapters pass RTPC inputs and BCI/invariant features into the hex‑coded mapping families (`0xPKLIN`, `0xPKSIG`, `0xPKHYS`, `0xPKOSC`) defined by `audiortpc-mapping-family-v1.json`, which enforce safety envelopes and compute final RTPC outputs.
6. **Telemetry:** Every frame’s invariants, BCI inputs, mapping family, RTPC outputs, and metric deltas are logged under the audio mapping telemetry schemas, feeding Neural‑Resonance‑Lab and Orchestrator analyses.

From this flow:

- Directors and `horroraudio_moods.lua` never choose curve shapes; they just select and target moods.
- Mapping families remain the only place where raw BCI/invariant → RTPC functions live.
- Mood contracts and the mood helper provide a declarative *what range* layer above the *how* implemented in mapping families.

### 4.2 Interactions with Mapping Families

Mood contracts include an `audioStyle` block with references such as:

- `styleContractId` (e.g., `audiolandscapestylev1`)
- `styleId` (e.g., `HELLSCAPE.constant_pressure.v1`)
- A list of `rtpcFamilies` providing `familyId` and `familyCode` for the recommended mapping curves.

Directors and `horroraudio_moods.lua` do not talk to these directly. Instead:

- Engine‑level configuration and Rust backends read `audioStyle` to bind RTPC channels to specific mapping families.
- The mood helper simply ensures that `H.Audio` RTPCs stay within the bands consistent with those families’ safety envelopes.

If a mood references a mapping family not available on the current platform, backends should fail fast in CI or fall back to a safe default profile, not silently reinterpret the mood.

## 5. BCI Mapping Profiles and Safety

### 5.1 BCI Profile Selection

Each mood contract also carries `bciMappingProfiles`, for example:

```json
"bciMappingProfiles": {
  "profileIds": ["bci.audio.profile.constant_pressure.v1"],
  "requiredIntensityModes": ["FOCUSED", "TENSE"],
  "disableOnOverload": true
}
```

Runtime policy around this is:

- The BCI layer and Rust mapping engines own which profile is active given the current BCI intensity mode.
- Directors **do not** flip mapping profiles directly; they only select moods and let the BCI layer choose appropriate families.
- If `disableOnOverload` is true and the BCI state enters an `OVERLOADED` band, Rust mapping engines should clamp outputs or switch to a conservative fallback profile automatically.

`HorroraudioMoods` is intentionally blind to the BCI profile mechanics; it only respects the RTPC bands.

### 5.2 Dead‑Ledger and High‑Intensity Moods

High‑intensity moods like `combat_nightmare` may require Dead‑Ledger attestation before activation. The mood contract can include governance metadata such as:

- `requiresDeadLedgerRef` boolean.
- `deadLedgerRef` optional attestation ID.

In practice:

1. Directors detect a candidate transition into `combat_nightmare`.
2. They assemble the appropriate BCI snapshot and context (region class, persona, BCI phase).
3. They call the Dead‑Ledger client (e.g., `Policy.DeadLedger.Audio.requestProfile(...)`) before committing to the mood.
4. Only on an allow decision do they actually call `HorroraudioMoods.apply_combat_nightmare`.

By keeping the Dead‑Ledger call separate from the mood helper, you preserve a single governance choke point and avoid burying attestation logic inside audio convenience APIs.

## 6. Integration Guidelines

To keep behavior predictable across the constellation:

- **Do not bypass the helper** for mood‑level audio changes. If you touch `H.Audio` RTPCs directly, you should do so only for non‑mood channels (e.g., diegetic SFX one‑shots) and keep those separate from the mood spine.
- **Do not encode hard caps in Directors.** All RTPC caps and safety envelopes should reside in contracts (`moodcontractv1`, mapping families) and Rust mapping engines. Directors may bias within the band but must not redefine it.
- **Keep `HorroraudioMoods` stateless with respect to invariants and BCI.** It should not query `H.Invariants` or `H.BCI` on its own; those sources belong to Director logic and mapping engines. The helper’s job is simply “take this mood and these suggested RTPC values, snap to band, call `H.Audio`”.
- **Align schemas and file paths with Constellation‑Contracts.** Engine builds should be wired so that `schemas/mood/` in Horror.Place mirrors the corresponding directory in HorrorPlace‑Constellation‑Contracts, and CI should fail if moods referenced in Directors are missing or invalid.

With these rules in place, mood selection becomes a stable, contract‑driven interface: Directors operate on `HorroraudioMoods.apply_*` APIs; Rust engines handle invariants, BCI, and curves; telemetry and Dead‑Ledger track the actual impact of audio mappings across the constellation.
