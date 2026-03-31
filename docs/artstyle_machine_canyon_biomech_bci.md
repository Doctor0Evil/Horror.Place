***

# Artstyle: Machine Canyon Biomech + BCI Haptic Horror  
``

***

## 1. Purpose

This document defines a **machine-enforceable artstyle profile** for Horror$Place based on an industrial, canyon-like megastructure filled with obsessive linework, organic-metal surfaces, and a lone human within an indifferent mechanism. It also codifies how this style integrates with **BCI + haptic feedback** to produce synchronized, data-driven scares.

The profile is intended to:

- Serve as a **strict contract** for AI code and content generation.  
- Bind visual and narrative motifs to **history invariants** and **player metrics**.  
- Define how BCI signals and haptic systems are wired into horror delivery.

***

## 2. Style Identity

### 2.1 Artstyle ID and Scope

**Artstyle ID:** `MACHINE_CANYON_BIOMECH_BCI`

**Scope:**

- Visual: industrial canyon, infinite machinery, fine-line drafting + muted washes.  
- Narrative: existential processing of life by mechanism.  
- Haptics/BCI: low-frequency dread, mechanical tension, sensation of being inside a system that does not care.

### 2.2 Conceptual Axes

This style expresses:

- **Industrial Infinity:** the world is a machine corridor with no discernible end.  
- **Biomechanical Warmth:** metal surfaces feel **fleshed, stained, and lived-in**, not sterile.  
- **Human Negligibility:** a single figure inside a machine that neither notices nor needs them.  
- **Subtractive Divinity:** no explicit deity, only process; worship is replaced by throughput.  

***

## 3. Label Taxonomy

All AI generation and engine modules must use the following **controlled labels**.

### 3.1 Global Artstyle Labels

```json
{
  "artstyle_id": "MACHINE_CANYON_BIOMECH_BCI",
  "visual_mode": [
    "industrial_megastructure",
    "fine_line_hatching",
    "muted_biomech_wash"
  ],
  "thematic_mode": [
    "mechanism_over_organism",
    "human_as_process_input",
    "infinite_corridor",
    "indifferent_system"
  ]
}
```

### 3.2 Detailed Dimension Labels

- **Composition:**
  - `composition_canyon_corridor`
  - `composition_machine_walls_left_right`
  - `composition_lone_figure_bottom_center`
  - `composition_converging_depth_glow`
  - `composition_cable_web_crossing_void`

- **Lighting & Palette:**
  - `lighting_internal_furnace_glow`
  - `lighting_diffuse_sickly_core`
  - `lighting_env_foggy_smoke`
  - `palette_desaturated_bone_iron`
  - `palette_sickly_warm_highlights`
  - `palette_rust_blood_stains`
  - `palette_no_vibrant_color`

- **Surface & Detail:**
  - `detail_dense_hatching`
  - `detail_crosshatched_shadow`
  - `detail_cable_bundles`
  - `detail_riveted_panels`
  - `detail_chain_suspension`
  - `detail_vertebra_pipes`

- **Mood & Theme:**
  - `mood_existential_mechanical_dread`
  - `mood_processed_flesh`
  - `mood_unseen_heart_of_machine`
  - `mood_lost_in_megastructure`

- **BCI/Haptic:**
  - `bci_channel_heartbeat_resonance`
  - `bci_channel_breath_constraint`
  - `haptic_channel_floor_vibration`
  - `haptic_channel_cable_tension`
  - `haptic_pattern_conveyor_pulse`

Any use of this style must select:

- ≥ 1 composition label  
- ≥ 1 lighting label  
- ≥ 1 palette/surface label  
- ≥ 1 mood label  
- ≥ 1 BCI/haptic label  

***

## 4. Invariant and Metric Binding

### 4.1 Required Invariants

This style activates only when local history supports **industrialized, process-based horror**.

Minimum conditions:

- \( CIC \geq 0.6 \): history of large-scale systemic harm (e.g., exploitation, accidents).  
- \( MDI \geq 0.5 \): myths of “the machine” or anonymous forces.  
- \( AOS \geq 0.7 \): opaque records, missing workers, unexplained disappearances.  
- \( FCF \geq 0.6 \): folklore converging around industrial corridors, furnaces, or mines.  
- \( SPR \geq 0.65 \): machine-linked manifestations feel believable in-world.  
- \( SHCI \geq 0.7 \): spectral activity tightly constrained to industrial events.

Recommended:

- \( RRM \geq 0.5 \): rituals of productivity, sacrifice to systems, or process worship.  
- \( LSG \geq 0.6 \): liminal stress in walkways, catwalks, loading docks.

### 4.2 Player-Experience Targets

When active, style aims for:

- **UEC:** 0.5–0.75 → player feels uncertain about the machine’s awareness.  
- **EMD:** 0.6–0.85 → scattered clues: graffiti, tags, bone fragments, abandoned tools. [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)
- **STCI:** 0.4–0.7 → alternating stretches of dead stillness and sudden mechanical activity.  
- **CDL:** 0.7–0.9 → mind struggles to decide if the machine is alive.  
- **ARR:** ≥ 0.7 → no simple “it’s evil/good”; mostly unresolved.

***

## 5. Style Profile Module

Filename:  
`artstyles/machine_canyon_biomech_bci.lua`

```lua
-- File: artstyles/machine_canyon_biomech_bci.lua

local Style = {}

Style.id = "MACHINE_CANYON_BIOMECH_BCI"

Style.invariant_requirements = function(inv)
    return inv.cic  >= 0.60 and
           inv.mdi  >= 0.50 and
           inv.aos  >= 0.70 and
           inv.fcf  >= 0.60 and
           inv.spr  >= 0.65 and
           inv.shci >= 0.70
end

Style.metric_targets = {
    UEC  = { min = 0.50, max = 0.75 },
    EMD  = { min = 0.60, max = 0.85 },
    STCI = { min = 0.40, max = 0.70 },
    CDL  = { min = 0.70, max = 0.90 },
    ARR  = { min = 0.70, max = 1.00 }
}

Style.visual_flags = {
    allow_color              = true,
    palette_desaturation     = 0.85, -- high desaturation
    max_saturation           = 0.2,
    use_muted_biomech_wash   = true,
    dense_hatching_required  = true,
    forbid_clean_metal       = true
}

Style.semantic_tags = {
    "mechanism_over_organism",
    "human_as_process_input",
    "industrial_megastructure",
    "existential_mechanical_dread"
}

Style.region_bias = 0.0

return Style
```

This style module is registered through `style_registry.lua` and consumed by the `StyleRouter`.

***

## 6. Composition, Camera, and Environment Logic

### 6.1 Corridor Composition

Rules:

- Left and right frame edges are **machine walls** forming a canyon.  
- One side emphasizes **cylindrical conduits, cables, vertical repetition**.  
- The other emphasizes **angled armor plates, chains, panel seams**.  
- Center depth converges on a **furnace glow**; full machine body is never seen.

### 6.2 Lone Figure Constraint

- Single human-scale figure at bottom-center or lower-third center, facing into the corridor.  
- No eye contact or explicit acknowledgment from the environment.  
- Pose must suggest **observation, not influence**.

### 6.3 Camera Parameters (Pseudo)

```lua
-- Called after StyleRouter selects this style
function Style.apply_camera(scene, inv, metrics)
    local cam = scene.camera

    cam.mode = "machine_canyon"
    cam.fov = 60
    cam.vertical_bias = 0.0       -- emphasize corridor depth more than sky
    cam.depth_vanish_point = { x = 0.5, y = 0.4 } -- slightly above center

    cam.observer_height_ratio = 0.05
    cam.enforce_canyon_framing = true
end
```

***

## 7. Lighting and Palette Rules

### 7.1 Furnace Glow Logic

- Central light is **sickly, internal, and partially occluded**.  
- Color: desaturated yellow-white or pale ochre, always low saturation.  
- Behavior: constant, low flicker; feels like a **deep, slow-burning core**.

### 7.2 Environmental Lighting

- Peripheral areas: dim, diffuse, with heavy shadow under cables and in recesses.  
- No clean spotlight on the figure; the human is lit by **ambient reflection** from the machine.  
- Fog and particulate emphasis: smoke, dust, or vapor.

### 7.3 Engine Parameters (Pseudo)

```lua
function Style.apply_lighting(scene, inv, metrics)
    local L = scene.lighting

    L.palette_mode = "muted_industrial"
    L.max_saturation = 0.2

    L.key_light.source = "deep_core"
    L.key_light.type = "diffuse_furnace"
    L.key_light.intensity = 0.8
    L.key_light.color = { r = 0.9, g = 0.8, b = 0.5 } -- before desaturation

    L.ambient.intensity = 0.3
    L.ambient.color = { r = 0.6, g = 0.55, b = 0.5 }

    L.fog.enabled = true
    L.fog.color = { r = 0.4, g = 0.38, b = 0.35 }
    L.fog.density = 0.6

    L.shadows.depth = 0.9
    L.shadows.softness = 0.4
end
```

***

## 8. Surface, Detail, and Object Logic

### 8.1 Detail Density

- Surfaces must be described with **dense fine lines**: hatching, crosshatching, etching-like marks.  
- No large, blank planes; any large surface must show scratches, rivets, stains, or seams.  
- Cables and chains must cross space in **diagonal or sagging arcs**, suggesting tension and weight.

### 8.2 Object Catalogue (Logical, Not IP-Bound)

Required motif classes:

- **Cylindrical stacks**: segmented like vertebrae or reinforced piping.  
- **Hull plates**: large planar forms with bolts, seams, and corrosion.  
- **Cable webs**: horizontal/diagonal arcs, some frayed or broken.  
- **Hanging chains**: thick links, partially visible, indicating larger unseen structures.  
- **Catwalks**: narrow, curved walkways with railings, grating, and wear.

***

## 9. BCI + Haptic Integration

### 9.1 BCI Channels

Assume the engine receives **normalized BCI data** per player (0–1):

- `bci_arousal` (general activation).  
- `bci_attention` (focus on stimulus).  
- `bci_anxiety` (inferred tightness / dread).  

### 9.2 Haptic Channels

Haptic system exposes:

- `haptic_floor_vibration` (0–1, low-frequency rumble).  
- `haptic_cable_tension` (0–1, sharp, high-tension pulls).  
- `haptic_breath_chest` (0–1, subtle chest-level pulses).  

### 9.3 Style-Specific Mapping

Filename:  
`src/bci_haptics/machine_canyon_mapping.lua`

```lua
-- File: src/bci_haptics/machine_canyon_mapping.lua

local MachineBCI = {}

function MachineBCI.apply_bci_haptics(style_decision, inv, metrics, bci_data)
    if style_decision.style_id ~= "MACHINE_CANYON_BIOMECH_BCI" then
        return
    end

    local arousal  = bci_data.arousal  or 0.5
    local anxiety  = bci_data.anxiety  or 0.5
    local attention = bci_data.attention or 0.5

    local base_rumble = inv.cic * 0.4 + inv.shci * 0.2
    local floor_vibration = base_rumble * (0.5 + anxiety * 0.5)

    local cable_tension = attention * 0.6 + anxiety * 0.3
    local breath_pulse = (1.0 - arousal) * 0.5 + anxiety * 0.5

    Haptics.set("haptic_floor_vibration", floor_vibration)
    Haptics.set("haptic_cable_tension",   cable_tension)
    Haptics.set("haptic_breath_chest",    breath_pulse)
end

return MachineBCI
```

Behavior:

- As anxiety rises, **floor rumble** increases, as if the machine is “responding” at a sub-perceptual level.  
- As attention narrows, **cable tension spikes**, synchronizing micro-jolts with visual cable motion.  
- When arousal dips but anxiety remains high, **chest pulses** emphasize suffocating dread.

***

## 10. Prompt & Code-Generation Contracts

### 10.1 Prompt Metadata

Any AI content generator that targets this style should emit metadata similar to:

```json
{
  "target_artstyle": "MACHINE_CANYON_BIOMECH_BCI",
  "composition_tags": [
    "composition_canyon_corridor",
    "composition_lone_figure_bottom_center"
  ],
  "lighting_tags": [
    "lighting_internal_furnace_glow",
    "lighting_env_foggy_smoke"
  ],
  "palette_tags": [
    "palette_desaturated_bone_iron",
    "palette_no_vibrant_color"
  ],
  "detail_tags": [
    "detail_dense_hatching",
    "detail_cable_bundles",
    "detail_riveted_panels"
  ],
  "mood_tags": [
    "mood_existential_mechanical_dread",
    "mood_lost_in_megastructure"
  ],
  "bci_haptic_tags": [
    "bci_channel_heartbeat_resonance",
    "haptic_channel_floor_vibration"
  ]
}
```

### 10.2 Machine-Enforced Rules for Generated Code

Any script claiming this style must:

1. Import the style profile:  
   `local MachineStyle = require("artstyles.machine_canyon_biomech_bci")`

2. Call invariant gate:  
   `MachineStyle.invariant_requirements(inv)` before applying visuals.

3. Respect palette and lighting constraints (no bright colors, furnace-based key light).

4. Use **BCI + haptic mapping** when available; otherwise fall back to neutral rumble patterns.

5. Log style and context into telemetry:

```lua
Telemetry.log_event("style_activation", {
    style_id = "MACHINE_CANYON_BIOMECH_BCI",
    region_id = region_id,
    tile_id = tile_id,
    invariants = inv,
    metrics = metrics
})
```

***

## 11. Validation and Linting

A future `style_lint.lua` module should:

- Reject assets or code that:  
  - Use vivid colors when `palette_no_vibrant_color` is implied.  
  - Omit canyon/wall composition while claiming this style.  
  - Spawn crowds of humans instead of a single observer.  
  - Fail to integrate BCI/haptic channels where hardware is available.

***
