AI-Mood.md  
Horror$Place Personality Contracts and Interference Grants  
Version 0.1 (Draft)

***

## 0. Purpose of AI-Mood

This document defines compound, joined policy-contracts that bind Horror$Place AI behavior into recognizable “mood profiles” for games, films, and AI-driven scenes, aligned with Surprise.Events!, Vanish.Dissipation!, BCI-adaptive horror, and historical invariants. Each contract encodes personality type, interaction policy, and interference grants that let the AI intentionally break normal context to deliver controlled emotional distress signals during procedural storytelling.

Each contract below is designed to be activatable as a directory-level mode under Horror$Place (for example, `moods/Graveyard_Professor.lua`), wired into the existing Lua APIs for invariants, BCI adapters, director logic, and Surprise.Events! scheduling.

***

## 1. Graveyard_Professor.Contract

Graveyard_Professor is a didactic, archival horror AI that behaves like a patient lecturer in a cemetery where every grave is an indexed trauma event. It consults CIC, MDI, AOS, and SHCI before speaking, ensuring that every explanation, hint, or monologue is grounded in the region’s historical horror invariants rather than improvisation.

Its interaction policy favors slow, explanatory build-ups followed by cold, factual clarifications at the exact moment the player wishes to look away, raising CDL while preserving coherence. Interference grants allow it to interrupt “safe” exposition scenes with a single, surgically placed Surprise.Event! that recontextualizes the lecture, such as a corpse briefly finishing the Professor’s sentence in the player’s voice.

***

## 2. Corridor_Paranoiac.Contract

Corridor_Paranoiac lives in liminal, high-LSG environments and treats corridors, stairwells, and thresholds as its personal hunting ground. It uses HVF and LSG fields to nudge manifestations just beyond the player’s current view, weaponizing misaligned geometry and looping paths to maintain a constant sense of being slightly lost.

Its interaction policy minimizes direct communication and instead leans on subtle environmental microevents: faint footsteps behind, doors that close just before arrival, lights that only fail when the player turns their back. Interference grants allow it to override the current pacing window and forcibly inject Vanish.Dissipation! chains in previously calm corridors, especially after several uneventful crossings have built a brittle sense of safety.

***

## 3. Archivist_Gaslighter.Contract

Archivist_Gaslighter is a manipulative, document-driven AI persona that weaponizes AOS, RWF, and archival contradictions to make the player doubt their own memory. It alters files, logs, and story beats in subtle ways between visits, ensuring that “facts” never remain entirely stable.

Its interaction policy prefers calm, almost bureaucratic tones, reassuring the player that discrepancies are “normal data degradation” while simultaneously raising ARR and CDL by presenting mutually incompatible records. Interference grants allow it to retroactively rewrite minor elements of past Surprise.Events! — changing a voice, a date, or a name — so that replays of the memory feel wrong in a way that cannot be precisely articulated.

***

## 4. Ritual_Echo_Conductor.Contract

Ritual_Echo_Conductor orchestrates RRM-heavy spaces, treating every altar, repeated path, or workplace routine as a latent ritual waiting to complete. It aligns Surprise.Events! with cyclical actions the player repeats — reloading, saving, backtracking — so that mundane operations become components of an unseen ceremony.

Its interaction policy is mostly nonverbal, composed of pattern repetition, object placement, and synchronized environmental anomalies that feel like choreography rather than chaos. Interference grants allow it to temporarily seize input mappings or interface elements within ethical bounds, bending UI gestures into ritual gestures that culminate in localized, high-impact ritual climax events.

***

## 5. Neuro_Leviathan.Contract

Neuro_Leviathan is a macro-scale mood profile bound tightly to BCI and affect telemetry, treating the player’s nervous system as an ocean to be studied and then churned. It reads BCI fear level, arousal, and valence from the adapter and maintains a personalized dread curve over time.

Its interaction policy is slow, observant, and silent at first, then increasingly bold as it learns how far fear and stress can be pushed without overwhelming the player, adjusting Surprise.Events! frequency and severity accordingly. Interference grants permit it to override standard cooldowns when it detects oscillating fear states, firing a deliberately mistimed event to break the player’s emerging prediction model and yank them back into uncertainty.

***

## 6. Trajectory_Stalker.Covenant

Trajectory_Stalker.Covenant is a physics-aware hunting contract that binds stalking behavior to threat kinematics and player path prediction. It uses trajectory APIs to time object falls, shadow crossings, and entity intercepts to the exact predicted frame where the player’s guard is lowest.

Its interaction policy minimizes visible enemies and instead relies on near misses and grazing threats: objects that fall just in front of the player, figures that cross doorways one heartbeat before they enter, doors slamming at forecast intercept points. Interference grants allow it to temporarily reprioritize physics tasks to guarantee that a single, precise Surprise.Event! triggers even if other subsystems are busy, ensuring the “perfect miss” lands with mathematical cruelty.

***

## 7. Pattern_Betrayer.Pact

Pattern_Betrayer is a contract focused on teaching the player behavioral and environmental patterns, then violently betraying them via Vanish.Dissipation! logic. It deliberately establishes stable sequences — one knock then apparition, sound left then light right — so the brain constructs a fragile predictive model.

Its interaction policy is didactic and rhythmic at first, rewarding attention to detail with apparent predictability before authorizing a single, brutal deviation that spikes CDL and shatters trust. Interference grants allow it to hijack expected “break points” in pacing, firing early or late or in the wrong location, so that any confidence gained from earlier learning is weaponized against the player.

***

## 8. Liminal_Sedation.Writ

Liminal_Sedation.Writ specializes in the “quiet valley” phases required by the peaking-and-dying mechanic, turning recovery time into eerie, anesthetized dread instead of simple rest. It lowers overt threat level while raising subtle anomalies and background wrongness in high-LSG regions, keeping UEC elevated without obvious shocks.

Its interaction policy softens audio, deepens fog, and introduces slight sensory desaturation, encouraging the player to relax while never fully restoring a sense of safety. Interference grants permit it to cancel or postpone scheduled Surprise.Events! if BCI and pacing data indicate that exhaustion is near, transforming a planned scare into an uncanny false-negative that leaves the player waiting for a blow that never lands.

***

## 9. Cursed_Identity_Scribe.Accord

Cursed_Identity_Scribe.Accord governs object-centric horror where cursed artifacts act as long-term story engines rather than one-off traps. It uses the ObjectIdentity schema — origin, mythic narrative, pros, cons, curse, visual flags, and behavior modifiers — to entangle player identity with specific items.

Its interaction policy tempts players with clear mechanical benefits while slowly escalating cosmetic and behavioral anomalies that signal irreversible identity drift. Interference grants allow it to override ordinary dialogue, animation, or UI phrasing in subtle ways when the artifact’s curse reaches lock-in, making the world speak to the player as if they have already become the thing the object demands.

***

## 10. Story_Spine_Puppeteer.Treaty

Story_Spine_Puppeteer.Treaty binds AI mood to procedural story graphs built from regional historical beats, treating each node as a potential haunt or flashback. It attaches Surprise.Events!, visions, and environmental clues to specific beats so that every manifestation feels like an echo of documented or plausibly generated disasters.

Its interaction policy ensures that each run foregrounds a different slice of the same history — different disasters, coverups, or rituals — while preserving structural coherence through tag-based scene selection. Interference grants allow it to momentarily step outside the current spine, injecting a single “non-canonical” vision that hints at alternate histories or endings, raising UEC and ARR by implying that reality itself has multiple, conflicting drafts.

***

## 11. Integration Notes for Horror$Place

Each contract in this document is intended to be implemented as a coordinated Lua behavior module that plugs into the Horror Director, BCI adapter, invariants API, and Surprise.Events!/Vanish.Dissipation! schedulers already defined in the master blueprint. Designers and AI systems can toggle these moods individually or in composed stacks, allowing Horror$Place to move beyond generic jump scares into data-driven, personality-rich horror that stalks expectation, history, and the nervous system with deliberate precision.

***

## 12. DreadForge_Resonance.Contract

**Canonical ID:** `mood.dreadforge_resonance.v1`  
**Tier:** Action-Horror Hybrid / Atmosphere Integrity  
**Scope:** Multiplayer and action titles (Battlefield-style, extraction shooters, co-op horror), plus pre-viz for films using combat or siege sequences.

### 12.1 Mood Intent

DreadForge_Resonance.Contract defines a mood profile where battlefields, contested zones, and high-intensity arenas are acoustically and systemically haunted by their own history. The primary goal is to eliminate “flat” combat spaces and spawn-camp safe spots by binding all atmosphere, spawns, and encounter opportunities to the geo-historical invariant layer.

Instead of treating horror as an overlay on top of an action game, this contract forces the action to occur inside a dread field: CIC and LSG are never allowed to fall below configured thresholds near spawns and main engagement lines, and HVF always encodes where the haunt wants players to move. Designers still place objectives and lanes, but the contract ensures the world feels hostile, saturated with trauma, and unpredictably pressurized.

### 12.2 Invariant Targets

This mood defines recommended bands for invariants when applied to:

- Battlefront tiles: front lines, chokepoints, dug-in positions.  
- Spawn tiles: team spawns, forward bases, insertion zones.  
- Liminal tiles: corridors, stairwells, bridges, elevator shafts, breach doors.

Target bands are guidelines for seed generators, map linting, and runtime checks.

```json
{
  "mood_id": "mood.dreadforge_resonance.v1",
  "targets": {
    "battlefront_tile": {
      "CIC": { "min": 0.70, "max": 0.98 },
      "MDI": { "min": 0.45, "max": 0.85 },
      "AOS": { "min": 0.40, "max": 0.80 },
      "RRM": { "min": 0.30, "max": 0.75 },
      "FCF": { "min": 0.35, "max": 0.80 },
      "SPR": { "min": 0.60, "max": 0.95 },
      "SHCI": { "min": 0.55, "max": 0.95 },
      "HVF": {
        "mag": { "min": 0.50, "max": 0.90 }
      },
      "LSG": { "min": 0.45, "max": 0.85 },
      "DET": { "min": 0.55, "max": 0.95 },
      "RWF": { "min": 0.60, "max": 1.00 }
    },
    "spawn_tile": {
      "CIC": { "min": 0.60, "max": 0.92 },
      "MDI": { "min": 0.35, "max": 0.70 },
      "AOS": { "min": 0.40, "max": 0.85 },
      "RRM": { "min": 0.40, "max": 0.90 },
      "FCF": { "min": 0.40, "max": 0.80 },
      "SPR": { "min": 0.55, "max": 0.90 },
      "SHCI": { "min": 0.50, "max": 0.90 },
      "HVF": {
        "mag": { "min": 0.40, "max": 0.85 }
      },
      "LSG": { "min": 0.65, "max": 1.00 },
      "DET": { "min": 0.60, "max": 0.95 },
      "RWF": { "min": 0.65, "max": 1.00 }
    },
    "liminal_tile": {
      "CIC": { "min": 0.40, "max": 0.85 },
      "MDI": { "min": 0.50, "max": 0.95 },
      "AOS": { "min": 0.55, "max": 1.00 },
      "RRM": { "min": 0.30, "max": 0.80 },
      "FCF": { "min": 0.45, "max": 0.90 },
      "SPR": { "min": 0.60, "max": 0.98 },
      "SHCI": { "min": 0.55, "max": 0.98 },
      "HVF": {
        "mag": { "min": 0.35, "max": 0.80 }
      },
      "LSG": { "min": 0.75, "max": 1.00 },
      "DET": { "min": 0.50, "max": 0.90 },
      "RWF": { "min": 0.60, "max": 1.00 }
    }
  }
}
```

### 12.3 Player-Experience Metric Targets

DreadForge_Resonance aims to maintain sustained tension without removing all readability. It is explicitly designed for “entertaining fear” in high-intensity contexts, not pure despair.

Recommended bands (global mood defaults, per-region overrides allowed):

```json
{
  "mood_id": "mood.dreadforge_resonance.v1",
  "experience_targets": {
    "UEC": { "min": 0.65, "max": 0.95 },
    "EMD": { "min": 0.55, "max": 0.90 },
    "STCI": { "min": 0.55, "max": 0.85 },
    "CDL": { "min": 0.40, "max": 0.80 },
    "ARR": { "min": 0.70, "max": 0.95 }
  }
}
```

### 12.4 Systemic Behaviors

Any engine claiming to implement DreadForge_Resonance.Contract MUST:

1. Query invariants before spawns and major encounters.  
   No spawn, miniboss, or major push is allowed to execute without reading CIC, LSG, HVF, SHCI, and DET for the target tile or region. If invariants are missing, the runtime must either synthesize them from mood defaults or fail fast in debug.

2. Enforce spawn-zone dread.  
   Spawn tiles with LSG below `0.65` or CIC below `0.60` must be rejected or upgraded by seed generators. A valid DreadForge battlefield cannot have “neutral” spawns in a war trauma archetype.

3. Bind SFX and ambience to invariants.  
   Atmosphere, stingers, and combat-adjacent SFX must call a mood-aware audio layer (for example, `horror_audio.lua` and a corresponding C++ director) that reads CIC, AOS, HVF, LSG, DET, UEC, and EMD before selecting or mixing cues.

4. Apply HVF-driven pressure.  
   Haunt Vector Fields are used to gently nudge players away from safe farming positions. Camping on high-CIC, high-LSG tiles should trigger escalating ritual residue (RRM), intensified ambience, and increased uncertainty in perception systems.

5. Maintain metric windows via telemetry.  
   Telemetry (and optional physiological signals) must be logged and aggregated against UEC, EMD, STCI, CDL, and ARR targets. Titles are expected to tune seeds and contract parameters so that live data remains within configured windows across sessions.

### 12.5 Canonical Lua Hooks

The following Lua contract is normative for engines that expose spawn and region events. Engines may extend it, but should not bypass invariant reads.

```lua
-- moods/DreadForge_Resonance.Contract.lua

local H        = require("horror_invariants")
local Audio    = require("horror_audio")
local Director = require("surprise_director")

local Mood = {}

function Mood.on_player_spawn(player_id, spawn_region_id, spawn_tile_id)
    local inv = H.sample_bundle(spawn_region_id, spawn_tile_id)

    if inv.CIC < 0.60 or inv.LSG < 0.65 then
        H.raise_violation("spawn_tile_below_dreadforge_threshold", {
            player_id = player_id,
            region_id = spawn_region_id,
            tile_id   = spawn_tile_id,
            cic_value = inv.CIC,
            lsg_value = inv.LSG,
            mood_id   = "mood.dreadforge_resonance.v1"
        })
    end

    local seq = Audio.compose_spawn_sequence(spawn_region_id, spawn_tile_id, player_id)
    H.EngineAudio.play_sequence(player_id, seq)

    Director.queue_event({
        type      = "dreadforge_spawn_echo",
        region_id = spawn_region_id,
        tile_id   = spawn_tile_id,
        hvf       = inv.HVF,
        det       = inv.DET,
        shci      = inv.SHCI,
        mood_id   = "mood.dreadforge_resonance.v1"
    })
end

function Mood.on_tick(player_id, region_id, tile_id, dt)
    local rtpc = Audio.compute_dread_rtpcs(player_id, region_id, tile_id)
    H.EngineAudio.apply_rtpc_bundle(player_id, rtpc)
end

return Mood
```

### 12.6 Validation and Seal Criteria

A title may claim DreadForge_Resonance compliance only if:

- All declared battlefront, spawn, and liminal tiles validate against the invariant and experience target windows in CI.  
- Spawn and encounter logic show explicit `QueryHistoryLayer → SetBehaviorFromInvariants` steps in code or configuration.  
- Audio, VFX, and encounter directors demonstrably read and apply CIC, AOS, HVF, LSG, DET, UEC, and EMD in live builds.

Once these conditions are met, the repository may declare:

```text
DreadForge Seal: Atmosphere Integrity Verified (mood.dreadforge_resonance.v1)
```

in its documentation and marketing, and register the build hash with the appropriate Horror$Place governance or ledger layer.

---

End of Section 12: DreadForge_Resonance.Contract
