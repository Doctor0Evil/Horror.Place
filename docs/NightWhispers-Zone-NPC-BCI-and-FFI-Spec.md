NightWhispers Zone, NPC, BCI, Rumor, and FFI Spec
==================================================

0. Purpose and Scope
--------------------

This document anchors the NightWhispers subsystem in the Horror.Place VM‑constellation. It describes:

- JSON shapes for Zones and Major NPCs that work across Unreal, Unity, and BCI/EEG labs.
- UrbanLegendMetaQuest behavior and tests as a machine‑checkable contract.
- RumorPool ticking rules that map directly to horror metrics and manifestation logic.
- Debug snapshot shapes for NightWhispers world state.
- FFI function signatures and C#/Unreal usage to keep NightWhispers consistent across engines.
- Concrete next research and implementation steps for Horror.Place repos.

All patterns follow the core constellation doctrine:

- History and invariants first (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI).
- Entertainment metrics second (UEC, EMD, STCI, CDL, ARR).
- Engines and tools sit on top as interchangeable skins.
- NightWhispers is treated as the urban legend / rumor layer for the constellation, not a standalone toy system.

1. Zone and MajorNpc JSON Schemas (Engine + BCI)
------------------------------------------------

### 1.1 Design Goals

Zone and MajorNpc records must:

- Be consumable as data assets in Unreal (DataTables, primary assets) and Unity (ScriptableObjects fed from JSON).
- Bind directly to horror invariants and telemetry targets via mood channels and BCI calibration fields.
- Support parametric horror tuning across multiple engines, not encode lore directly.

Critically, these records are **view layers** over the canonical history layer: they present convenient, engine‑friendly projections of invariant bundles and Seed contracts, but they are not a second source of truth. The engine must always resolve back to invariant bundles and Seed contracts when deciding if, how, and where any manifestation, spectral event, or NightWhispers‑driven scene actually occurs.

### 1.2 Zone JSON shape

Per‑record example (schematic contract, not formal JSON Schema):

```json
{
  "id": "LanternAlley",
  "display_name": "Lantern Alley",
  "mood_channels": {
    "fog": 0.8,
    "rain": 0.7,
    "light": 0.2,
    "rumor_intensity": 0.9
  },
  "default_weather": "rain",
  "default_threat_level": "High",
  "rumor_bias_tags": ["widow", "children", "blackout"],
  "bci_calibration": {
    "target_arousal": 0.7,
    "target_valence": 0.3,
    "artifact_sensitivity": 0.6
  }
}
```

```json
{
  "id": "ClockworkStation",
  "display_name": "Clockwork Station",
  "mood_channels": {
    "fog": 0.3,
    "rain": 0.5,
    "light": 0.1,
    "rumor_intensity": 0.8
  },
  "default_weather": "oil_rain",
  "default_threat_level": "VeryHigh",
  "rumor_bias_tags": ["time_loop", "platform_shift", "memory"],
  "bci_calibration": {
    "target_arousal": 0.85,
    "target_valence": 0.25,
    "artifact_sensitivity": 0.7
  }
}
```

### 1.2.1 Field semantics

- `id`: stable identifier for cross‑repo use; should align with ZoneId enum / registry IDs.
- `display_name`: UI string; engines may localize based on this key.

- `mood_channels`:
  - `fog`, `rain`, `light`, `rumor_intensity` are float bands in `[0,1]`.
  - These are local mood drivers, not raw CIC/MDI/AOS; they feed into the invariant and SFX systems and into BCI targets.

- `default_weather`: label that maps to engine weather kits (`rain`, `ashfall`, `oil_rain`, etc.).
- `default_threat_level`: coarse band (`Low`, `Medium`, `High`, `VeryHigh`); used for quick difficulty shaping and DET caps.
- `rumor_bias_tags`: tags that bias RumorPool seeding and scene selection; they also serve as hooks for AI authoring.

- `bci_calibration`:
  - `target_arousal`: intended arousal band for this zone when “on target”.
  - `target_valence`: how pleasant/unpleasant the baseline should feel.
  - `artifact_sensitivity`: how strongly the system should weight EEG artifacts when mapping BCI → game adjustments for this zone.

These fields are intentionally minimal—they are meant to be inputs to invariant and metric computation, not a second invariant layer.

### 1.3 MajorNpc JSON shape

Per‑record examples:

```json
{
  "id": "CandleEyedWidow",
  "name": "Candle-Eyed Widow",
  "zone_id": "LanternAlley",
  "legend_id": "CandleEyedWidow",
  "role_tags": ["questgiver", "antagonist", "tragic"],
  "personality_base": {
    "trust": 0.2,
    "fear": 0.6,
    "intrigue": 0.9,
    "horror": 0.8
  },
  "rumor_tags": ["widow", "children", "backwards_midnight_walk"],
  "bci_calibration": {
    "social_threat": 0.9,
    "uncanny_factor": 0.8,
    "recommended_eeg_band_focus": ["theta", "gamma"]
  }
}
```

```json
{
  "id": "WhisperingBarber",
  "name": "Whispering Barber",
  "zone_id": "ForgottenArcade",
  "legend_id": "WhisperingBarber",
  "role_tags": ["questgiver", "predator"],
  "personality_base": {
    "trust": 0.1,
    "fear": 0.7,
    "intrigue": 0.7,
    "horror": 0.9
  },
  "rumor_tags": ["hair", "tongue", "mirror"],
  "bci_calibration": {
    "social_threat": 0.8,
    "uncanny_factor": 0.9,
    "recommended_eeg_band_focus": ["beta", "gamma"]
  }
}
```

### 1.3.1 Field semantics

- `id`: stable MajorNpc identifier; should align with NpcId or equivalent.
- `name`: display name.
- `zone_id`: primary zone association; used for routing presence and rumors.
- `legend_id`: link into the legend/UrbanLegendMetaQuest system; allows persistent state to drive NPC behavior.
- `role_tags`: coarse semantic roles (`questgiver`, `predator`, `antagonist`, `tragic`, etc.) that downstream systems can map onto personality modes.

- `personality_base`:
  - `trust`, `fear`, `intrigue`, `horror` ∈ `[0,1]`.
  - Seeds NPC behavior vectors and influences initial UEC/EMD/STCI contributions from interactions.

- `rumor_tags`: tags the NPC can seed, respond to, or resolve.

- `bci_calibration`:
  - `social_threat`: how threatening this NPC should feel socially.
  - `uncanny_factor`: how “wrong” the NPC should be; used to tune uncanny valley / CDL spikes.
  - `recommended_eeg_band_focus`: bands labs should attend to for this NPC (e.g., theta, beta, gamma) when validating designs.

### 1.4 Engine usage

- **Unreal**: Use as JSON‑backed primary assets or DataTable rows; blueprint or C++ code maps them into runtime structs and then into invariants.
- **Unity**: Import JSON, store as ScriptableObjects; NightWhispersBridge and other runtime systems reference them by `id`.
- **BCI/EEG labs**: Use `bci_calibration` as initial targets; adjust over time based on real telemetry, then push updated values back into the JSON registry.

2. UrbanLegendMetaQuest State Contract and Unit Tests
-----------------------------------------------------

### 2.1 Conceptual behavior

UrbanLegendMetaQuest represents an abstract urban legend and its activation state in the NightWhispers city model. It must:

- Respond deterministically to `apply_player_action_to_legend(meta, action_tag, intensity)`.
- Adjust status along the finite state machine:

  - `Asleep` → `Awakening` → `Active` → `Fulfilled` or `Broken`.

- Adjust `hazard_delta` in a predictable way; this value flows into threat levels and DET caps at legend scope.
- Clamp `intensity` internally to a safe range (e.g., `[0,1]`).

### 2.2 Intended transition rules

Normal transitions:

- `Asleep` + `"spread_rumor"` at low intensity:
  - Moves to `Awakening`.
  - `hazard_delta` becomes positive.

- `Awakening` + `"spread_rumor"` at high intensity:
  - Moves to `Active`.
  - `hazard_delta` increases; recommended minimum positive threshold (e.g., ≥ `0.25`).

- `Active` + `"perform_ritual_success"`:
  - Moves to `Fulfilled`.
  - `hazard_delta` becomes negative (legend pacified, risk reduced).

- `Awakening` or `Active` + `"disprove_legend"`:
  - Moves to `Broken`.
  - `hazard_delta` becomes negative.

- Any non‑Fulfilled/non‑Broken + `"perform_ritual_failure"`:
  - Moves to or stays at `Active`.
  - `hazard_delta` becomes positive.

Edge cases:

- `intensity == 0.0`:
  - No status change, no hazard change.

- `intensity > 1.0`:
  - Clamped internally; behavior matches `intensity == 1.0` branch.

- `"disprove_legend"` applied to `Fulfilled`:
  - Behavior is a design choice:
    - Option A: stays `Fulfilled` (legend remains resolved).
    - Option B: moves to `Broken` (legend is shattered by later proof).
  - Implementation must pick one and tests must fix the behavior.

- Repeated `"spread_rumor"` on `Active`:
  - Must not move out of `Active`.
  - `hazard_delta` should either saturate at a cap or increase with diminishing returns.

- Unknown `action_tag`:
  - No status or hazard change.

### 2.3 Rust test outline (contract)

The following test module describes the required behavior. Implementation details may vary, but tests should pass:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use crate::nightwhispers_city::LegendStatus;

    fn meta_with(status: LegendStatus) -> UrbanLegendMetaQuest {
        UrbanLegendMetaQuest {
            id: "MonsterSnail".into(),
            origin_sources: vec!["rumor".into()],
            status,
            ritual_paths: vec!["food_denial".into()],
            hazard_delta: 0.0,
            linked_legends: vec![],
        }
    }

    #[test]
    fn asleep_spread_rumor_low_intensity_awakens() {
        let mut meta = meta_with(LegendStatus::Asleep);
        apply_player_action_to_legend(&mut meta, "spread_rumor", 0.3);
        assert_eq!(meta.status, LegendStatus::Awakening);
        assert!(meta.hazard_delta > 0.0);
    }

    #[test]
    fn awakening_spread_rumor_high_intensity_activates() {
        let mut meta = meta_with(LegendStatus::Awakening);
        apply_player_action_to_legend(&mut meta, "spread_rumor", 0.95);
        assert_eq!(meta.status, LegendStatus::Active);
        assert!(meta.hazard_delta >= 0.25);
    }

    #[test]
    fn active_successful_ritual_fulfills_and_reduces_hazard() {
        let mut meta = meta_with(LegendStatus::Active);
        apply_player_action_to_legend(&mut meta, "perform_ritual_success", 0.8);
        assert_eq!(meta.status, LegendStatus::Fulfilled);
        assert!(meta.hazard_delta < 0.0);
    }

    #[test]
    fn awakening_failed_ritual_reactivates_and_increases_hazard() {
        let mut meta = meta_with(LegendStatus::Awakening);
        apply_player_action_to_legend(&mut meta, "perform_ritual_failure", 0.7);
        assert_eq!(meta.status, LegendStatus::Active);
        assert!(meta.hazard_delta > 0.0);
    }

    #[test]
    fn active_disproving_breaks_and_reduces_hazard() {
        let mut meta = meta_with(LegendStatus::Active);
        apply_player_action_to_legend(&mut meta, "disprove_legend", 0.6);
        assert_eq!(meta.status, LegendStatus::Broken);
        assert!(meta.hazard_delta < 0.0);
    }

    #[test]
    fn zero_intensity_does_nothing() {
        let mut meta = meta_with(LegendStatus::Awakening);
        apply_player_action_to_legend(&mut meta, "spread_rumor", 0.0);
        assert_eq!(meta.status, LegendStatus::Awakening);
        assert_eq!(meta.hazard_delta, 0.0);
    }

    #[test]
    fn intensity_above_one_is_clamped() {
        let mut meta = meta_with(LegendStatus::Asleep);
        apply_player_action_to_legend(&mut meta, "spread_rumor", 1.5);
        // Expect same result as intensity 1.0; the exact status is implementation-dependent
        assert!(matches!(meta.status, LegendStatus::Awakening | LegendStatus::Active));
    }

    #[test]
    fn unknown_action_no_change() {
        let mut meta = meta_with(LegendStatus::Active);
        apply_player_action_to_legend(&mut meta, "unknown_action", 0.9);
        assert_eq!(meta.status, LegendStatus::Active);
        assert_eq!(meta.hazard_delta, 0.0);
    }
}
```

This test set turns the legend state machine into a stable, regression‑checked contract.

3. RumorPool Tick Pseudocode (Priority, Decay, Spawn Caps)
----------------------------------------------------------

### 3.1 Design intent

The RumorPool is the city’s “nervous system”:

- Rumors gain or lose weight based on location, belief, and time.
- Heavier, more truthful rumors near the player spawn first.
- Spawn frequency is capped; spawns are also gated by player mental state.

### 3.2 Pseudocode behavior

Language‑agnostic pseudocode:

```text
function tick_rumors(pool, dt_minutes, player_loc, player_state):
    base_decay = pool.decay_per_minute * dt_minutes

    // 1) Apply decay and small reinforcement
    for rumor in pool.active_rumors:
        // spatial decay
        if rumor.district == player_loc:
            // slower decay near the player
            rumor.weight -= base_decay * 0.4
        else:
            rumor.weight -= base_decay

        // belief feedback: truthiness helps maintain weight
        belief = rumor.truthiness * 0.3 + rumor.embellishment * 0.2
        rumor.weight += belief * 0.05 * dt_minutes

        // clamp to [0,1]
        if rumor.weight < 0.0:
            rumor.weight = 0.0
        if rumor.weight > 1.0:
            rumor.weight = 1.0

    // 2) Sort by priority (higher effective_priority first)
    // effective_priority = weight * (0.5 + rumor.truthiness * 0.3 + rumor.embellishment * 0.2)
    sorted_rumors = sort_desc(pool.active_rumors, key = effective_priority)

    // 3) Attempt spawns up to max_events_per_tick
    max_events = 3
    events_spawned = 0

    for rumor in sorted_rumors:
        if events_spawned >= max_events:
            break

        if rumor.district != player_loc:
            continue

        effective_priority = rumor.weight * (0.5 + rumor.truthiness * 0.3 + rumor.embellishment * 0.2)

        // gating by player mental state
        sensitivity = max(player_state.insight, 0.2)   // high insight → more likely
        threshold = 0.5 - 0.2 * (player_state.sanity < 0.4 ? 1.0 : 0.0)

        if effective_priority * sensitivity > threshold:
            spawn_world_event(rumor.spawned_event_tag, rumor.district)
            events_spawned += 1
            // reduce weight post-spawn to avoid immediate re-trigger
            rumor.weight *= 0.4

    // 4) Cull low-weight rumors
    pool.active_rumors = filter(sorted_rumors, r => r.weight > 0.05)
```

### 3.3 Mapping to invariants and metrics

Rumor spawning can be used to drive:

- Local UEC, EMD, and ARR (uncertainty and mystery).
- Local DET if spawned events are threatening.

District/zone selection should be informed by:

- Zone `rumor_bias_tags` from the JSON schemas.
- Underlying invariant profiles (e.g., high CIC and SPR zones should host more plausible legends).

Implementations should integrate this function with `NightWhispersWorldState` and the legend system, not run it standalone.

4. DebugConsoleState JSON Snapshot
----------------------------------

### 4.1 Purpose

DebugConsoleState is a lightweight view of the current NightWhispers world state, meant for:

- In‑engine debug overlays.
- Lab tooling.
- Unity/Unreal debug UIs via the FFI bridge.

### 4.2 Example snapshot

Seed: `"rain-lantern-ghosts"`.

```json
{
  "world_seed": "rain-lantern-ghosts",
  "active_legends": [
    "Candle-Eyed Widow",
    "Monster Snail",
    "Chimney Twin"
  ],
  "player_reputation_label": "Fading Rumor",
  "current_district": "Barrow Heights",
  "weather": "ashfall",
  "threat_level": "High",
  "npc_trust_debug": [
    ["Ragpicker Queen", 0.41, 0.65, 0.80, 0.32]
  ],
  "minor_npc_events": [
    "Pawn Seller seeded event: Plague Coins"
  ],
  "recent_world_events": [
    {
      "timestamp": "01:13",
      "zone": "Barrow Heights",
      "type": "RumorSpawn",
      "tag": "PlagueCoins"
    },
    {
      "timestamp": "01:16",
      "zone": "Forgotten Arcade",
      "type": "ZoneLock",
      "tag": "PowerSurge"
    }
  ],
  "player_afflictions": [
    "Fungal Lung"
  ],
  "sanity": 72.0,
  "insight": 4.0,
  "recent_legend_alteration": "Monster Snail rumor escalated by 2, now manifest regardless of food-offering",
  "zone_locks": [
    "Forgotten Arcade (power surge event triggered by rumor propagation)"
  ],
  "available_rituals": [
    "Salt Circle, Broken Mirror"
  ],
  "ending_paths_unlocked": [
    "Consumed",
    "Dispelled"
  ],
  "system_integrity": "OK"
}
```

### 4.3 Notes

- All strings are debug‑oriented; production UIs should map them through style layers.
- `npc_trust_debug` shape is intentionally opaque for now; engine code can format a nicer view.
- `recent_world_events` provides an at‑a‑glance history of NightWhispers‑driven events.

5. FFI Surface for NightWhispers (C and C#)
-------------------------------------------

### 5.1 Goals

The FFI must:

- Provide a minimal, stable ABI for engines (Unity, Unreal, custom).
- Return either plain POD structs or JSON blobs, not arbitrary internal types.
- Keep all heavy logic in the Rust/C++ NightWhispers core.

### 5.2 C‑side structs

Representative C header (generated from Rust `extern "C"`):

```c
typedef struct {
    const char* world_seed;
    const char** active_legends;
    uint32_t active_legends_len;
    const char* player_reputation_label;
    const char* current_district;
    const char* weather;
    const char* threat_level;
    const char** npc_trust_debug;
    uint32_t npc_trust_debug_len;
    const char** minor_npc_events;
    uint32_t minor_npc_events_len;
    const char** player_afflictions;
    uint32_t player_afflictions_len;
    float sanity;
    float insight;
    const char* recent_legend_alteration;
    const char** zone_locks;
    uint32_t zone_locks_len;
    const char** available_rituals;
    uint32_t available_rituals_len;
    const char** ending_paths_unlocked;
    uint32_t ending_paths_unlocked_len;
    const char* system_integrity;
} DebugConsoleStateFFI;

typedef struct {
    const char* id;
    const char* zone_id;
    const char* legend_id;   // nullable
    int quest_type;          // matches enum QuestType
} QuestTemplateFFI;

typedef struct {
    float sanity;
    float insight;
    float reputation_score;
} PlayerStateFFI;

typedef struct {
    int triggered;        // 0/1
    const char* scene_tag;
    uint32_t flags;       // bitmask
} SceneTriggerResultFFI;
```

Functions:

```c
#ifdef __cplusplus
extern "C" {
#endif

void nw_get_debug_snapshot(DebugConsoleStateFFI* out_snapshot);

uint32_t nw_get_current_quests(
    QuestTemplateFFI* out_quests,
    uint32_t max_quests
);

void nw_apply_player_action_to_legend(
    const char* action_tag,
    float intensity
);

void nw_horror_tick(
    const PlayerStateFFI* player,
    int zone_id, // ZoneId as int
    SceneTriggerResultFFI* out_result
);

#ifdef __cplusplus
}
#endif
```

### 5.3 Unity C# bridge types

```csharp
using System;
using System.Runtime.InteropServices;

[StructLayout(LayoutKind.Sequential)]
public struct DebugConsoleStateFFI {
    public IntPtr world_seed;
    public IntPtr active_legends;      // treat as serialized JSON or handle via extra APIs
    public uint active_legends_len;
    public IntPtr player_reputation_label;
    public IntPtr current_district;
    public IntPtr weather;
    public IntPtr threat_level;
    public IntPtr npc_trust_debug;
    public uint npc_trust_debug_len;
    public IntPtr minor_npc_events;
    public uint minor_npc_events_len;
    public IntPtr player_afflictions;
    public uint player_afflictions_len;
    public float sanity;
    public float insight;
    public IntPtr recent_legend_alteration;
    public IntPtr zone_locks;
    public uint zone_locks_len;
    public IntPtr available_rituals;
    public uint available_rituals_len;
    public IntPtr ending_paths_unlocked;
    public uint ending_paths_unlocked_len;
    public IntPtr system_integrity;
}

[StructLayout(LayoutKind.Sequential)]
public struct QuestTemplateFFI {
    public IntPtr id;
    public IntPtr zone_id;
    public IntPtr legend_id;
    public int quest_type;
}

[StructLayout(LayoutKind.Sequential)]
public struct PlayerStateFFI {
    public float sanity;
    public float insight;
    public float reputation_score;
}

[StructLayout(LayoutKind.Sequential)]
public struct SceneTriggerResultFFI {
    public int triggered;
    public IntPtr scene_tag;
    public uint flags;
}

public static class NightWhispersBridge {
    private const string DllName = "engine_core";

    [DllImport(DllName, EntryPoint = "nw_get_debug_snapshot", CallingConvention = CallingConvention.Cdecl)]
    public static extern void nw_get_debug_snapshot(out DebugConsoleStateFFI snapshot);

    [DllImport(DllName, EntryPoint = "nw_get_current_quests", CallingConvention = CallingConvention.Cdecl)]
    public static extern uint nw_get_current_quests(
        [Out] QuestTemplateFFI[] quests,
        uint max_quests
    );

    [DllImport(DllName, EntryPoint = "nw_apply_player_action_to_legend", CallingConvention = CallingConvention.Cdecl)]
    public static extern void nw_apply_player_action_to_legend(
        [MarshalAs(UnmanagedType.LPStr)] string actionTag,
        float intensity
    );

    [DllImport(DllName, EntryPoint = "nw_horror_tick", CallingConvention = CallingConvention.Cdecl)]
    public static extern void nw_horror_tick(
        ref PlayerStateFFI player,
        int zone_id,
        out SceneTriggerResultFFI result
    );
}
```

### 5.4 JSON‑over‑FFI option

In practice, for complex data like DebugConsoleState or quest lists, it is often simpler to:

- Serialize structs to JSON in Rust.
- Export functions that return `*const c_char` with JSON payloads.
- Let C#/Unreal treat results as JSON strings and parse into higher‑level engine types.

This keeps the FFI surface thin and versionable.

6. Recommended Next Research and Implementation Steps
-----------------------------------------------------

This section focuses on near‑term, actionable work across the VM‑constellation.

### 6.1 Immediate implementation tasks (code level)

- **Integrate Zone and MajorNpc records with invariants**:
  - Map `mood_channels` and `bci_calibration` into canonical invariants and entertainment metrics.
  - Ensure the history/invariant layer can query Zone/NPC records via a narrow Lua API (e.g., `H.zone(id)`, `H.npc(id)`).
  - Preserve the principle that Zones, NPCs, and Legends are view layers; any manifestation logic must ultimately consult invariant bundles and Seed contracts as the authoritative history surface.

- **Finalize UrbanLegendMetaQuest implementation**:
  - Implement `apply_player_action_to_legend` with clamped intensity and the state rules described above.
  - Wire the FFI call `nw_apply_player_action_to_legend` to this helper (already conceptually done).
  - Ensure tests cover both “happy path” and edge cases.

- **Implement RumorPool tick in engine‑core**:
  - Port the pseudocode into `rumor_engine.rs`.
  - Expose hooks for:
    - Telemetry logging (rumor weight curves, spawn frequency).
    - Scene selection bias based on `rumor_tags` and Zone `rumor_bias_tags`.

- **Complete Unity marshalling**:
  - In `NightWhispersDebugMonoBehaviour`, finalize JSON parsing from FFI snapshots into C# POCOs or ScriptableObjects.
  - Add a simple in‑editor debug panel that shows:
    - Current district, active legends, rumor summary.
    - Legend statuses and hazard deltas.

- **Snapshot signing and DID integration**:
  - Replace mock SHAKE256 signature with:
    - A real DID key from `nightwhispers_identity.toml`.
    - A proper signing path in `engine-tools/nightwhispers_export.rs`.
  - Add CI jobs that:
    - Build the snapshot binary.
    - Generate a signed snapshot artifact for each NightWhispers test run.

### 6.2 Constellation‑level research directions

- **BCI calibration pipeline for Zones and NPCs**:
  - Use the `bci_calibration` fields as experimental priors.
  - Run lab sessions to:
    - Measure whether target arousal/valence bands are hit for each Zone.
    - Measure whether social threat and uncanny factors for NPCs match planned ranges.
  - Feed results back into JSON registry updates and adjust SFX/visual intensity mapping accordingly.

- **NightWhispers ↔ invariant layer integration**:
  - Define how Zone/NPC/Legend states are projected into invariants:
    - For example, high rumor intensity + many active legends in a zone should correlate with higher local CIC/SPR or at least with local DET caps.
  - Ensure that spectral entities spawned from NightWhispers always:
    - Query invariants (SHCI, CIC, RRM, AOS) first.
    - Choose behaviors constrained by local history instead of arbitrary “ghost” logic.
  - Keep the authoritative trauma and style profiles in invariant bundles and Seed contracts; treat NightWhispers records as lenses over those profiles.

- **Rumor and legend metrics mapping**:
  - Link rumor weight and legend status transitions to:
    - UEC (uncertainty), EMD (mystery), STCI (safe‑threat contrast), CDL (cognitive dissonance), ARR (ambiguity retention).
  - Define target bands per stage:
    - Early rumors: raise UEC/EMD gently, preserve high ARR.
    - Active legends: raise STCI and CDL.
    - Fulfilled/Broken: let CDL decay but keep ARR healthy (partial answers, not full closure).

- **Cross‑engine harness**:
  - Use the same `NightWhispersWorldState` and RumorPool logic in:
    - A minimal Unreal testbed.
    - The existing Unity stub.
  - Compare results:
    - Ensure identical seeds produce similar debug snapshots and rumor/legend evolutions.

- **NightWhispers as Seed‑like layer**:
  - Treat urban legends and rumors as a “city flavor” of Seeds:
    - Define a minimal, NightWhispers‑specific schema that parallels the Seed contract (legend id, invariant bands, metric targets).
  - Use NightWhispers to validate Seed‑layer concepts before full integration with Atrocity‑Seeds and Black‑Archivum.

- **Telemetry and metrics registry for NightWhispers**:
  - Set up a small, schematized telemetry log focused on:
    - Legend status transitions.
    - Rumor weight distributions.
    - Scene trigger results from `nw_horror_tick`.
  - Use these logs to:
    - Tune decay rates, thresholds, and spawn caps.
    - Identify oversaturated or underused legends/rumors.

7. Summary
----------

This spec binds together:

- Concrete data shapes (Zone, MajorNpc) for Unreal/Unity/BCI.
- A precise behavior contract for UrbanLegendMetaQuest.
- RumorPool ticking rules aligned with manifestation and player metrics.
- A debug snapshot shape for `NightWhispersWorldState`.
- A stable FFI surface for engine integration.
- A roadmap for BCI calibration and constellation‑wide research.

NightWhispers is a living laboratory for history‑bound, rumor‑driven horror inside the Horror.Place VM‑constellation. Zones, NPCs, and legend records are intentionally designed as view layers over invariant bundles and Seed contracts. All runtime decisions about manifestations must ultimately be made by querying those canonical history and Seed layers, with NightWhispers providing the city‑scale narrative, rumor, and debug vocabulary that makes those decisions legible to engines, tools, and human designers.
