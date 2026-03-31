***

# Spectral Engraving Dark Sublime  
*Artstyle Logic & Label Specification for Horror$Place*  
`docs/artstyle_spectral_engraving_dark_sublime.md`

***

## 1. Purpose

This document defines a **codified artstyle dimension** for Horror$Place: the **Spectral Engraving Dark Sublime** mode. It translates a specific visual tradition—monochrome, high-contrast, engraved cosmic horror with human‑mass divinities and lone observers—into **labels, parameters, and logic contracts** that AI tools must follow when generating visual prompts, narrative descriptions, or engine-side presentation. [facebook](https://www.facebook.com/groups/259412529766772/posts/973696791671672/)

The goal is to allow the repository to:

- Reference this artstyle as a **stable, machine-usable profile**.  
- Enforce formal constraints so generated horror is **consistent, coherent, and historically grounded**.  
- Give AI authors a vocabulary and schema to extend this style across entities, scenes, and documents.

***

## 2. Conceptual Definition

### 2.1 High-Level Style Identity

**Artstyle ID:** `SPECTRAL_ENGRAVING_DARK_SUBLIME`

**Core identity:**  
A monochrome, engraving-like horror mode where **divine-scale entities constructed from human forms** confront a **lone, insignificantly small witness** under **violent shafts of celestial light** in an otherwise engulfing darkness. Awe and terror are indistinguishable; the scene feels like a sacrament performed in a void.

### 2.2 Thematic Axes

This artstyle lives at the intersection of:

- **Cosmic insignificance:** tiny figure vs. monumental entity.  
- **Human-mass divinity:** gods literally built from people (aggregated bodies, heads, limbs).  
- **Dark sublime:** beauty and horror fused; devotional lighting on abominable forms.  
- **Engraved eternity:** the scene feels etched into stone or metal, timeless and archival. [facebook](https://www.facebook.com/bondanisty/posts/ww3nanobananadark-monochrome-illustration-style-detailed-engraving-line-art-vint/10163425818664404/)

***

## 3. Label Taxonomy

All AI tools and generation scripts must use this **controlled vocabulary** when referring to the style. These labels should be surfaced in prompt metadata, asset tags, and content configuration files.

### 3.1 Global Artstyle Labels

```json
{
  "artstyle_id": "SPECTRAL_ENGRAVING_DARK_SUBLIME",
  "visual_mode": [
    "monochrome_grayscale",
    "high_contrast_chiaroscuro",
    "engraving_like_linework",
    "halo_backlighting",
    "dark_romantic_composition"
  ],
  "thematic_mode": [
    "cosmic_insignificance",
    "human_mass_divinity",
    "sacramental_terror",
    "dark_sublime",
    "body_as_architecture"
  ]
}
```

### 3.2 Sub-Labels by Dimension

- **Composition:**
  - `composition_radial_divine_core`
  - `composition_vertical_axis_beam`
  - `composition_lone_figure_scale_anchor`
  - `composition_mandala_of_suffering`

- **Lighting:**
  - `lighting_backlit_celestial_shaft`
  - `lighting_halo_corona_edges`
  - `lighting_volumetric_atmosphere`
  - `lighting_sacramental_spot_on_observer`
  - `lighting_deep_cavernous_shadows`

- **Palette / Tonal:**
  - `palette_monochrome_only`
  - `contrast_extreme_light_dark`
  - `tones_silver_highlights`
  - `tones_charcoal_shadows`
  - `texture_stone_ivory_flesh`

- **Subject / Iconography:**
  - `subject_human_body_cluster_entity`
  - `subject_radial_flower_of_bodies`
  - `subject_aggregated_heads_core`
  - `subject_lone_cloaked_observer`
  - `subject_barren_rock_threshold`

- **Mood / Tone:**
  - `mood_cosmic_dread`
  - `mood_devotional_horror`
  - `mood_rapture_torment_ambiguity`
  - `mood_apotheosis_through_absorption`

Any content tagged with `artstyle_id = SPECTRAL_ENGRAVING_DARK_SUBLIME` must also select at least:

- 1 composition label  
- 1 lighting label  
- 1 palette label  
- 1 subject label  
- 1 mood label  

This enforces **minimum style coherence**.

***

## 4. Invariant Binding

This artstyle is not just a look; it is a **visual expression of invariants** in the Horror$Place history layer.

### 4.1 Required Invariant Conditions

This mode should be **eligible** only when:

- \( CIC \geq 0.75 \): high catastrophic imprint.  
- \( MDI \geq 0.7 \): strong mythic density.  
- \( AOS \geq 0.6 \): partially opaque archives, gaps in records.  
- \( SPR \geq 0.7 \): manifestations feel plausible in-world.  
- \( SHCI \geq 0.8 \): strong coupling between events and entities.  

Recommended:

- \( LSG \geq 0.7 \): strong stress at thresholds, caverns, or borders.  
- \( RRM \geq 0.5 \): presence of ritual residue, especially sacrificial or devotional.

### 4.2 Metric Mapping (Player Experience)

When this style is active:

- **UEC (Uncertainty Engagement):** target 0.6–0.8  
  - The scene should **raise questions**, not fully answer them.  
- **EMD (Evidential Mystery Density):** target 0.7–0.9  
  - Scenes reveal **partial evidence** (human forms, ritual posture, scale) but conceal origin.  
- **STCI (Safe-Threat Contrast):** mid 0.5–0.7  
  - There is space to observe before danger; the threat feels imminent but not immediate.  
- **CDL (Cognitive Dissonance Load):** high 0.7–0.9  
  - It should be hard to decide whether the entity is offering salvation or annihilation.  
- **ARR (Ambiguous Resolution Ratio):** ≥ 0.75  
  - Encounters rarely resolve with a clear “it was X”; they lean into unresolved symbolism.

***

## 5. Engine-Facing Artstyle Profile

### 5.1 Lua Artstyle Profile (Pseudocode)

```lua
-- File: artstyles/spectral_engraving_dark_sublime.lua

local SpectralStyle = {}

SpectralStyle.id = "SPECTRAL_ENGRAVING_DARK_SUBLIME"

SpectralStyle.invariant_requirements = function(inv)
    return inv.cic  >= 0.75 and
           inv.mdi  >= 0.70 and
           inv.aos  >= 0.60 and
           inv.spr  >= 0.70 and
           inv.shci >= 0.80
end

SpectralStyle.metric_targets = {
    UEC  = { min = 0.60, max = 0.80 },
    EMD  = { min = 0.70, max = 0.90 },
    STCI = { min = 0.50, max = 0.70 },
    CDL  = { min = 0.70, max = 0.90 },
    ARR  = { min = 0.75, max = 1.00 }
}

SpectralStyle.visual_flags = {
    monochrome_only         = true,
    allow_color_temperature = false,
    high_contrast_required  = true,
    volumetric_light        = true,
    halo_backlighting       = true
}

SpectralStyle.semantic_tags = {
    "cosmic_insignificance",
    "human_mass_divinity",
    "sacramental_terror",
    "dark_sublime",
    "body_as_architecture"
}

return SpectralStyle
```

Any generation pipeline that requests this artstyle must load this module and validate `invariant_requirements` before proceeding.

***

## 6. Composition & Camera Logic

### 6.1 Radial Divine Core + Vertical Axis

The core compositional rule is:

- The main entity is arranged in a **radial pattern** (flower, wheel, mandala), composed of **aggregated human forms**.  
- The camera framing emphasizes a **vertical axis**: light descends from above, passing through the entity and terminating on the observer below.

Key composition constraints:

- **Entity coverage:** 40–70% of frame height.  
- **Observer height:** 3–10% of frame height at bottom center or slightly off-center.  
- **Negative space:** at least 15% of frame reserved for unoccupied darkness or cloud.

### 6.2 Lone Observer as Scale Anchor

- Exactly **one primary human-scale figure** in the foreground.  
- Pose: standing, slightly bowed or craned upward; cloaked or shrouded for anonymity.  
- Rule: no secondary crowd; if additional humans exist, they must be **part of the entity**, not separate witnesses.

### 6.3 Engine Parameters for Camera

```lua
function SpectralStyle.apply_camera(scene, inv, metrics)
    local cam = scene.camera

    cam.mode = "god_beam_witness"

    cam.entity_frame_ratio = 0.55   -- entity occupies majority of height
    cam.observer_height_ratio = 0.06
    cam.vertical_bias = 0.15        -- push framing upward to emphasize heavens
    cam.fov = 45                     -- narrower, more monumental feel

    cam.enforce_monumentality = true
end
```

***

## 7. Lighting & Tonal Logic

### 7.1 Light Origin and Behavior

- Primary light source: **above/behind entity**.  
- Shape: **shaft or cone** of light with volumetric scattering.  
- Behavior: creates a **halo** around entity edges; central mass remains partly obscured.

### 7.2 Monochrome Enforcement

- **Color disabled**: all hues map to grayscale; only value and texture vary.  
- Highlights: near-white with subtle “silver” impression.  
- Mid-tones: sculpted, smooth, statue-like flesh or stone.  
- Shadows: deep, near-black where information disappears.

### 7.3 Engine Lighting Parameters (Pseudo)

```lua
function SpectralStyle.apply_lighting(scene, inv, metrics)
    local L = scene.lighting

    L.palette_mode = "monochrome"
    L.enable_color = false

    L.key_light.source = "above_entity"
    L.key_light.type = "shaft"
    L.key_light.intensity = 1.0
    L.key_light.angle = 15  -- narrow cone

    L.halo.enabled = true
    L.halo.width = 0.1
    L.halo.intensity = 0.9

    L.shadows.depth = 0.95  -- very deep
    L.shadows.softness = 0.3

    L.volumetrics.enabled = true
    L.volumetrics.density = 0.7
end
```

***

## 8. Subject Logic: Entities and Environment

### 8.1 Aggregated Human Entity Schema

The central entity is **constructed**, not merely large. Its structure:

```lua
AggregatedEntity = {
    type = "human_mass_divinity",
    composition = {
        core_cluster = {
            component = "heads_torsos",
            packing_density = 0.85,
            visibility = "partial_faces",
            expression_range = {"rapture", "torment", "neutral_abyss"}
        },
        radial_limbs = {
            component = "full_bodies",
            arrangement = "sunflower_petals",
            count = "dozens",
            posture = "outstretched",
            motion_hint = "centrifugal_bloom"
        }
    },
    scale = "colossal",
    silhouette = "floral_mandala",
    hover_state = "suspended_in_void",
    awareness = "implied_by_light_contact"
}
```

Rules:

- **No non-human appendages** in this profile; horror comes from human forms reconfigured into divinity.  
- Faces should show **mixed affect**: ecstasy, agony, blankness.

### 8.2 Environment Schema

- Terrain: barren, rocky, jagged; minimal vegetation.  
- Setting: cavern, chasm, or void-like plain.  
- Sky: turbulent or cloud-sheathed, mostly consumed by darkness and the light shaft.

***

## 9. Prompt & Tooling Contracts

### 9.1 Prompt Metadata Contract

Any AI visual or narrative generator targeting this style must emit metadata similar to:

```json
{
  "target_artstyle": "SPECTRAL_ENGRAVING_DARK_SUBLIME",
  "composition_tags": [
    "composition_radial_divine_core",
    "composition_lone_figure_scale_anchor"
  ],
  "lighting_tags": [
    "lighting_backlit_celestial_shaft",
    "lighting_halo_corona_edges"
  ],
  "palette_tags": [
    "palette_monochrome_only",
    "contrast_extreme_light_dark"
  ],
  "subject_tags": [
    "subject_human_body_cluster_entity",
    "subject_lone_cloaked_observer"
  ],
  "mood_tags": [
    "mood_cosmic_dread",
    "mood_devotional_horror"
  ]
}
```

### 9.2 Text/Narrative Generators

Narrative outputs using this artstyle must:

- Emphasize **scale contrast** (tiny observer vs. vast entity).  
- Describe **light as almost religious** but focused on something abominable.  
- Avoid color terms; rely on **value and texture language** (silver, charcoal, pale, shadowed).  
- Reinforce the **fusion of worship and terror**.

***

## 10. Validation Rules

To keep Horror$Place exceptionally structured, any scripted or generated asset claiming this style must pass these checks:

1. **Invariant Gate:**  
   - Validate `invariant_requirements(inv)` before rendering or labeling.

2. **Composition Check:**  
   - Ensure a radial or centralized entity and a lone witness anchor exist.  
   - Reject layouts with multiple independent observers or scattered focal points.

3. **Palette Check:**  
   - Reject use of explicit color channels or color names in metadata or text.

4. **Lighting Check:**  
   - Require backlit/hard-light configuration and halo/volumetric parameters.

5. **Semantic Check:**  
   - Demand presence of at least one of:
     - `human_mass_divinity`
     - `cosmic_insignificance`
     - `sacramental_terror`

***

## 11. Mermaid Diagram Filename

The **Spectral Library architecture diagram** from the prior response should be saved as:

- `docs/diagrams/spectral_library_architecture.mmd`

This current artstyle spec does not need a new diagram, but future expansions could add:

- `docs/diagrams/artstyle_spectral_engraving_dark_sublime_flow.mmd`  

to visualize how style selection flows from invariants and metrics through rendering and narrative layers.

***
