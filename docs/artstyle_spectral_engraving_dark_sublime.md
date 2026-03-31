# Art Style Specification: Spectral Engraving (Dark Sublime)
### Horror$Place Visual Contract v1.0

> *"The eye sees only what the mind is prepared to comprehend."*

***

## 1. Style Overview

**Spectral Engraving** is the foundational visual language of Horror$Place. It is a **monochrome cosmic horror** aesthetic designed to maximize **Uncertainty Engagement (UEC)** and **Evidential Mystery Density (EMD)** by obscuring detail rather than revealing it.

Inspired by the top-down atmospheric dread of *Darkwood* and the surreal bleakness of *Pathologic*, this style treats visibility as a resource and darkness as a canvas. It is not merely "dark"; it is **historically weighted**. Every shadow, texture, and lighting effect must correlate to the **Geo-Historical Invariant Layer** (CIC, AOS, MDI, etc.).

### Core Philosophy
1.  **Obscurity over Clarity:** Players should never see the monster clearly; they see its shadow, its effect on the environment, or its trace.
2.  **Monochrome Sublime:** Color is reserved for danger or supernatural anomalies. The world is grey, rust, and black.
3.  **Invariant-Driven Rendering:** Visual parameters (noise, contrast, fog) are dynamically adjusted based on historical trauma data (CIC, AOS).

***

## 2. Visual Invariant Mapping

This style contract defines how the **10 History-Horror Attribution Terms** (from `src/spectral_library.rs`) directly influence visual rendering. The engine queries these invariants to adjust the "Spectral Engraving" parameters in real-time.

| Invariant | Visual Parameter | Behavior Rule |
|-----------|------------------|---------------|
| **CIC** (Catastrophic Imprint) | **Decay Density** | High CIC (>0.8) increases rust textures, structural collapse, and debris particle count. |
| **AOS** (Archival Opacity) | **Visual Noise** | High AOS (>0.7) introduces film grain, chromatic aberration, and "missing texture" glitches to simulate unreliable reality. |
| **MDI** (Mythic Density) | **Ambient Particles** | High MDI triggers floating dust motes, ash, or "spectral snow" even indoors. |
| **LSG** (Liminal Stress) | **Lighting Contrast** | High LSG zones enforce hard shadows at thresholds (doorways, tree lines) with 90% light reduction. |
| **SPR** (Spectral Plausibility) | **Entity Opacity** | Low SPR entities are semi-transparent or distorted; High SPR entities appear solid but obscured by fog. |
| **RRM** (Ritual Residue) | **Symbolic Markings** | High RRM areas procedurally generate faint sigils on walls/floors (visible only under specific light angles). |
| **FCF** (Folkloric Convergence) | **Architectural Anomaly** | High FCF zones feature impossible geometry (stairs to nowhere, doors opening into walls). |
| **RWF** (Reliability Weight) | **Texture Fidelity** | Low RWF areas use lower-resolution textures or blurred assets to simulate "fading memory." |
| **DET** (Dread Exposure) | **Vignette Intensity** | As player time in zone increases, screen vignette darkens and peripheral vision narrows. |
| **HVF** (Haunt Vector) | **Fog Direction** | Volumetric fog flows along the HVF vector, subtly pushing player movement against the "pressure." |

***

## 3. Color Palette & Lighting

### 3.1 The Dark Sublime Palette

Color is strictly controlled to maintain the "Implication Layer" (Charter Pillar 2).

| Color Role | Hex Code | Usage |
|------------|----------|-------|
| **Void Black** | `#0A0A0A` | Deep shadows, unexplored areas. |
| **Bone Grey** | `#C8C8C8` | Primary surfaces (walls, ground, skin). |
| **Rust Red** | `#5C2A2A` | **ONLY** for bloodstains (dried), rust, or danger indicators. |
| **Sickly Green** | `#2F4F2F` | **ONLY** for toxic zones, biological experiments (Aral Sea influence). |
| **Static White** | `#F0F0F0` | **ONLY** for supernatural flashes, camera flashes, or spectral entities. |

**Rule:** No saturated colors allowed. All colors must be desaturated by at least 40% unless triggered by a high-CIC event.

### 3.2 Lighting Mechanics

Inspired by *Darkwood's* day/night cycle and flashlight mechanics:

1.  **Restricted Field of View (FOV):** Player vision is limited to a cone (default 90 degrees). Everything outside is rendered as pure black or vague silhouettes.
2.  **Dynamic Shadow Casting:** All light sources (flashlight, fires) cast hard, dynamic shadows. Entities hiding in shadows are rendered as **shadow-only** (no texture).
3.  **Occlusion Fog:** Distance fog is not uniform; it clusters around high-CIC coordinates to block line-of-sight to atrocities.
4.  **Night Event Protocol:** During "Night" phases (high DET), all ambient light is reduced by 50%. Only player-held light sources function.

***

## 4. Composition & Camera Rules

### 4.1 Perspective

-   **Top-Down Isometric:** Fixed camera angle (45 degrees) to restrict spatial awareness.
-   **No Rotation:** Player cannot rotate the camera; they must rotate their character to see behind them (increases vulnerability/UEC).
-   **Depth Layers:** Foreground objects (trees, walls) obscure the player character when moving "below" them, creating moments of total blindness.

### 4.2 Framing the Horror

-   **The Threshold Rule:** Every doorway, gate, or biome transition must be framed with high-contrast lighting (LSG invariant).
-   **The Empty Center:** Central areas of rooms should often be empty; horror elements are placed in corners or edges (peripheral dread).
-   **Environmental Traces:** Instead of bodies, show **disturbed earth**, **abandoned tools**, or **drag marks**. (Charter Compliance: Pillar 2).

***

## 5. Asset Validation & Forbidden Elements

All assets must pass `StyleLint` validation against this contract before merging.

### 5.1 Allowed Evidence Types

| Asset Type | Description | Invariant Link |
|------------|-------------|----------------|
| **Trace Decals** | Blood splatters (dried), mud footprints, scorch marks. | CIC, RRM |
| **Archival Props** | Redacted documents, torn photos, broken cameras. | AOS, RWF |
| **Structural Anomalies** | Doors leading to walls, windows showing wrong outdoors. | FCF, AOS |
| **Audio-Visual Sync** | Lights flickering in rhythm with distant chanting. | RRM, MDI |

### 5.2 Forbidden Depictions (Charter Violation)

| Forbidden Asset | Reason | Alternative |
|-----------------|--------|-------------|
| **Explicit Corpses** | Violates Pillar 2 (Implication). | Show body bags, outlines on ground, or personal effects. |
| **Gore Textures** | Violates Pillar 2 (Implication). | Use dark rust/red stains only. |
| **Clear Monster Models** | Reduces UEC (Uncertainty). | Use silhouettes, shadows, or partial renders (legs only). |
| **Bright Colors** | Breaks Dark Sublime palette. | Desaturate to grey/brown. |
| **UI Quest Markers** | Breaks "No Hand-Holding" (Darkwood principle). | Use environmental landmarks or HVF fog flow. |

***

## 6. Machine-Readable Style Contract

This JSON structure defines the enforceable rules for the `StyleLint` tool (File 7).

```json
{
  "style_id": "spectral_engraving_dark_sublime",
  "version": "1.0.0",
  "palette_constraints": {
    "max_saturation": 0.6,
    "allowed_accent_colors": ["#5C2A2A", "#2F4F2F", "#F0F0F0"],
    "base_palette": "monochrome_grey"
  },
  "camera_constraints": {
    "perspective": "top_down_isometric",
    "rotation_allowed": false,
    "fov_degrees": 90,
    "occlusion_enabled": true
  },
  "invariant_bindings": {
    "CIC": { "target": "decay_density", "min_threshold": 0.5, "max_effect": 1.0 },
    "AOS": { "target": "visual_noise", "min_threshold": 0.7, "max_effect": 0.8 },
    "LSG": { "target": "shadow_contrast", "min_threshold": 0.6, "max_effect": 0.9 }
  },
  "forbidden_tags": [
    "explicit_gore",
    "bright_color",
    "full_entity_reveal",
    "ui_quest_marker"
  ],
  "entertainment_targets": {
    "UEC": { "min": 0.55, "max": 0.85 },
    "EMD": { "min": 0.60, "max": 0.90 }
  }
}
```

***

## 7. Workflow Integration

### 7.1 Asset Generation Sprints

-   **Photogrammetry:** Scan real-world Soviet-era objects (gas masks, rusted machinery) but desaturate textures to match Dark Sublime palette.
-   **Modular Kits:** Create "decay kits" (walls, floors) that can be procedurally swapped based on CIC levels (low CIC = clean, high CIC = cracked/rusted).
-   **Spectral Anchors:** Place invisible "Spectral Anchor" objects in levels. When triggered, they activate local style overrides (e.g., increase AOS noise, shift fog color).

### 7.2 Runtime Validation

-   **Style Runtime Validator:** Monitors active camera and lighting settings. If a light source exceeds saturation limits or camera rotates illegally, it triggers a warning log.
-   **Invariant Sync:** Every frame, the renderer queries `SpectralLibrary` for the player's current tile invariants and adjusts post-processing volumes (fog, noise, vignette) accordingly.

***

## 8. Reference Cases (Darkwood & Pathologic)

| Feature | Darkwood Implementation | Horror$Place Adaptation |
|---------|-------------------------|-------------------------|
| **Vision** | Flashlight cone in darkness. | Dynamic cone based on DET (Dread Exposure). |
| **Night** | Hide or die loop. | High-CIC night events spawn spectral echoes, not just enemies. |
| **Map** | No minimap, rely on landmarks. | Use HVF (Haunt Vector) fog flow to guide intuition. |
| **Horror** | Body horror mutants. | Environmental mutations (walls breathing, floors softening). |
| **Sound** | Directional audio cues. | Audio-visual sync (lights flicker to sound节奏). |

***

## 9. Compliance Checklist

Before any visual asset is merged into the repository:

- [ ] **Palette Check:** Is saturation < 60%?
- [ ] **Implication Check:** Does this asset show evidence rather than explicit violence?
- [ ] **Invariant Check:** Is there a defined CIC/AOS binding for this asset?
- [ ] **Camera Check:** Does this asset work with top-down occlusion?
- [ ] **UI Check:** Does this asset avoid relying on UI markers for context?

***

**Document Status:** Active  
**Last Updated:** 2026-01-01  
**Maintainer:** Horror$Place Art Direction Team  
**Related Files:** `src/spectral_library.rs`, `schemas/entertainment_metrics_v1.json`, `docs/rivers_of_blood_charter.md`
