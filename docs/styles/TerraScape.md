# TerraScape Artstyle Specification

> **Repository:** `Horror.Place` (Public)  
> **Schema Version:** `v1.2.0`  
> **Last Validated:** `2026-01-22`  
> **Status:** `Canonical` | `Production-Ready`

---

## Concept Overview

**TerraScape** is a cosmic-folkloric horror artstyle for AI-chat and image generation, centered on a sentient, god-like tree presiding over a half-destroyed earth-like planet. The mood is mythic dread: a living archive of condemned time, where worried fruits hang from wrathful branches, and the planet's crumbling underside drips glass-sand sap into an endless void.

### Core Themes
- **Cosmic Archivist Horror**: The tree is not a monster but a failed steward, bound to watch the world erode while judging each "year" (fruit) that tries to escape.
- **Folkloric Mystery**: No explicit exposition; viewers infer the myth through visual cues (expressions, gestures, environmental storytelling).
- **Decay as Ritual**: The planet's destruction is not random but a slow, deliberate unmaking, with each falling fruit representing a lost century.
- **Witnessed Judgment**: The jaundiced moon acts as silent oracle, recording but never intervening.

### Similar Style Anchors
- Zdzisław Beksiński's dystopian surrealism (architectural decay, biomorphic forms)
- Junji Ito's cosmic body horror (melting, transformation, expressive dread)
- Dark fantasy concept art (epic scale, cinematic lighting, mythic subjects)

---

## Canonical Color Palette

| Role | Hex Code | Description | Usage Context |
|------|----------|-------------|--------------|
| `background_base` | `#1A1E26` | Deep Asphalt Blue | Sky, void, distant space |
| `mid_tone_wash` | `#2C313C` | Shadowed Concrete Grey | Planet crust, rock formations |
| `highlight` | `#FFD700` | Jaundiced Moon Yellow | Moon glow, oracle clouds, sap highlights |
| `accent_glow` | `#FF3E00` | Toxic Neon Orange | Dripping sap streams, fruit capillaries |
| `skin_wax_tone` | `#F4E3B9` | Pale Candle Flesh | Tree bark highlights, fruit surfaces |
| `shadow_depth` | `#050910` | Void Black | Abyss, deepest cracks, negative space |

**Fallback Text Descriptions** (for platforms without hex support):
- `background_base`: "deep asphalt blue, star-mist green"
- `highlight`: "jaundiced moon yellow, sickly oracle glow"
- `accent_glow`: "toxic neon orange, glass-sand luminescence"

---

## Paint Medium & Texture Language

### Surface Descriptors
- **Bark**: "vein-scarred, scabbed with dried sap, lichen like infected skin"
- **Crust**: "gnawed rock, fibrous soil dangling like exposed nerves, ash halos"
- **Fruits**: "translucent skin with capillary lines, fermenting bubbles, damp gloss"
- **Sap Streams**: "glass-sand hybrid: granular yet glossy, molten fiber appearance"
- **Pond**: "oil-water-sap mixture, rainbow-slick sheens, frozen ripple reflections"

### Prompt Texture Tags
```
hand-painted mixed-media, visible brushstrokes, grunge cartoon surface, 
wax-drip textures, neon mold glow, soft fuzzy outlines, melting silhouettes, 
wet asphalt reflection, ash-dusted edges, fibrous soil details
```

---

## Camera & Composition Rules

### Canonical Orientations
| Mode | Lens (mm) | FOV | Angle | Use Case |
|------|-----------|-----|-------|----------|
| `cinematic_wide` | 35-40 | 60° | Slightly low | Title screens, key art, establishing shots |
| `fixed_side_orbit` | 50-70 | 45° | Side orbit | Fixed-camera horror, helpless observation |
| `low_ground_up` | 24-28 | 75° | Ground low up | Encounter scenes, tree-as-character focus |
| `top_down_oracle` | 35 | 70° | Top down | Strategy/sim UI, ritual board-game framing |
| `void_gaze_inversion` | 16-20 | 85° | From below | Cutscenes, abyss emphasis, falling sequences |

### Composition Guidelines
- **Central Vertical Band**: Reserve middle third for tree and primary narrative focus.
- **Side Margins**: Use left/right thirds for floating debris, galaxies, subtle clouds (safe for UI overlays).
- **Void Negative Space**: Treat abyss as flexible canvas for logos, text, or dynamic elements.
- **Pond as Diegetic Anchor**: Use reflective surface for in-world markers or ritual circles.

---

## Structured Prompt Template

```promptlang
A hand-painted dark horror landscape, {camera_description}, 
half-destroyed earth-like planet floating in black void, lower half crumbling 
with soil, rock, and glowing fragments falling off, 
at center a massive sentient tree with god-like furious face carved into 
diseased bark, branches like many-armed hands clutching worried fruits, 
each fruit with anxious expressions aware of their fate, 
dark green sky with distant galaxies and star-mist, jaundiced moon glaring 
from afar with glowing oracle clouds casting sickly yellow light, 
glass-sand sap dripping from fractures like hourglass into endless darkness, 
filthy layered textures: vein-scarred bark, gnawed crust, ash halos, 
bruised translucent fruit skin, oily pond reflecting tree and moon, 
hand-painted mixed-media style, visible brushstrokes, dark desaturated palette 
with deep greens, browns, charred earth tones, 
cinematic horror lighting, eerie, foreboding, otherworldly.
```

**Variable Placeholders**:
- `{camera_description}`: One of the canonical orientation descriptions from table above.
- `{intensity_modifiers}`: Optional phrases scaled by metric values (e.g., "severely fractured" for high CFL).

---

## Style Metrics & Routing Definitions

### Core Metrics (0.0–1.0 scale)
| Metric ID | Description | Canonical Range | Routing Influence |
|-----------|-------------|----------------|------------------|
| `TDI` | TerraDread Index: overall cosmic dread intensity | 0.7–0.9 | Drives void emphasis, moon glare strength |
| `FAF` | FruitAnxiety Factor: expressiveness of worried fruits | 0.8–1.0 | Controls fruit detail, facial expression clarity |
| `STG` | SapTime Gradient: viscosity and flow of dripping sap | 0.6–0.9 | Affects sap texture tokens, particle density |
| `OMP` | OracleMoon Presence: dominance of moon as witness | 0.7–0.85 | Adjusts moon glow weight, oracle cloud density |
| `VPS` | VoidProximity Score: perceived closeness to abyss | 0.8–1.0 | Drives negative space, void token weights |
| `PSR` | ParticleStillness Ratio: frozen vs. dynamic debris | 0.6–0.8 | Controls motion blur, particle animation hints |
| `FEC` | FolkloreEnigma Coefficient: mythic ambiguity level | 0.8–0.95 | Adjusts symbolic detail density, lore token inclusion |

### Extended Metrics (Section 2 Additions)
| Metric ID | Description | Use Case |
|-----------|-------------|----------|
| `BAV` | BranchAggression Vector: how many branches "attack" vs. rest | Camera selection: high BAV → low-angle confrontational shots |
| `FTD` | FruitTension Density: count and precariousness of worried fruits | Close-up triggers, fruit cluster emphasis |
| `CFL` | CrustFracture Load: structural integrity of planet crust | Composition chaos, "on verge of collapse" language |
| `VDR` | VoidDominance Ratio: frame proportion occupied by void | Negative space emphasis, vertigo-inducing angles |
| `OGA` | OracleGaze Alignment: moon's focus (fruits/tree/viewer) | Narrative framing, viewer implication strength |
| `LWI` | LoreWhisper Intensity: strength of implied mythology | Symbolic detail injection, sigil/carving density |
| `DOF` | DecayOrbit Function: rate of element "event horizon" crossing | Dynamic composition shifts, decay cycle pacing |
| `MSQ` | MythicSilence Quotient: reliance on stillness vs. motion | Static oppressive frames vs. storm-like dynamics |
| `WIM` | WitnessIsolation Metric: presence of secondary entities | Cosmic loneliness vs. tragic epic worldbuilding |

### Routing Rule Examples (TOML fragment)
```toml
[TerraScape.routing.SDXL]
# High VoidProximity → emphasize void, suppress crowded elements
[[TerraScape.routing.SDXL.rules]]
metric_id = "VPS"
value_range = [0.8, 1.0]
positive_tokens = [
  { token = "endless dark void", weight_expr = "exponential", emphasize = true },
  { token = "cosmic emptiness", weight_expr = "linear", emphasize = false }
]
negative_tokens = [
  { token = "crowded city", weight_expr = "fixed", emphasize = true },
  { token = "detailed architecture", weight_expr = "fixed", emphasize = true }
]
renderer_controls = { cfg_scale = 8.0, guidance = "high" }
priority = 8

# High FruitAnxiety → emphasize facial expressions, translucent skin
[[TerraScape.routing.SDXL.rules]]
metric_id = "FAF"
value_range = [0.85, 1.0]
positive_tokens = [
  { token = "worried fruit expressions", weight_expr = "logistic", emphasize = true },
  { token = "translucent fruit skin with capillaries", weight_expr = "linear", emphasize = false }
]
renderer_controls = { steps = 45, detail_boost = true }
priority = 7
```

---

## PromptLang-Lua Integration

### TerraScapeScene Descriptor (Example)
```lua
-- Horror.Place/scripts/TerraScapeScene.lua
local TerraScapeScene = {
  id = "TerraScape",
  version = "v1.2.0",
  metrics = {
    TDI = 0.85, FAF = 0.92, STG = 0.78, OMP = 0.80,
    VPS = 0.90, PSR = 0.70, FEC = 0.90,
    BAV = 0.65, FTD = 0.88, CFL = 0.75,
    VDR = 0.82, OGA = 0.50, LWI = 0.90,
    DOF = 0.70, MSQ = 0.88, WIM = 1.00
  },
  palettes = {
    roles = {
      background_base = { hex = "#1A1E26", description = "Deep Asphalt Blue" },
      highlight = { hex = "#FFD700", description = "Jaundiced Moon Yellow" },
      accent_glow = { hex = "#FF3E00", description = "Toxic Neon Orange" }
    }
  },
  prompt_primitives = {
    style_line_string = "cosmic void, crumbling planet, jaundiced moon, sentient tree",
    style_line_tokens = { "cosmic void", "crumbling planet", "jaundiced moon", "sentient tree" },
    global_horror_tokens = { "eerie", "unsettling", "foreboding" },
    style_specific_tokens = { "cosmic void", "jaundiced moon", "glass-sand sap" }
  }
}

-- Camera selection logic (simplified)
function TerraScapeScene:chooseCamera()
  local m = self.metrics
  if m.CFL > 0.8 or m.VDR > 0.85 then
    return "void_gaze_inversion"
  elseif m.BAV > 0.7 or m.FAF > 0.85 then
    return "low_ground_up"
  elseif m.WIM >= 1.0 and m.MSQ > 0.85 then
    return "fixed_side_orbit"
  else
    return "cinematic_wide"
  end
end

return TerraScapeScene
```

---

## Validation & Testing Checklist

- [ ] Schema compliance: All required fields present, metric values in [0,1]
- [ ] Palette integrity: Hex codes valid, roles include `background_base` and `highlight`
- [ ] Security sanitization: No blocked tokens, safe Lua/ALN syntax
- [ ] Routing coverage: All metrics have at least one routing rule in default profile
- [ ] Cross-repo consistency: Public spec matches vault reference hashes (via Orchestrator)
- [ ] Interrogator alignment: CLIP captions of generated images include expected keywords
- [ ] Palette drift monitoring: Generated hex distributions within ±5% of canonical set

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| `v1.0.0` | 2025-11-15 | Initial specification, core metrics, basic palette |
| `v1.1.0` | 2025-12-20 | Added Section 2 extensions: lore hooks, camera variants, Lua integration |
| `v1.2.0` | 2026-01-22 | Added extended metrics (BAV, FTD, etc.), routing TOML examples, validation checklist |

---

## References & Further Reading

- [Horror.Place Style Schema (ALN)](../schemas/style_schema.aln)
- [Routing Profiles Configuration](../../configs/routing_profiles.toml)
- [PromptLang-Lua Specification](../promptlang-lua/spec.md)
- [Darkwood Wiki: Atmospheric Horror Design](https://darkwood.fandom.com) *(reference for top-down horror composition)*
- [Beksiński Retrospective: Decay as Beauty](https://example.com/beksinski) *(style anchor reference)*

> **Note**: This document is machine-readable. Tools may parse YAML/JSON frontmatter or Lua code blocks for automated style loading.
