# Style Router Module Specification
### Horror$Place Dynamic Aesthetic Engine v1.0

> *"The world changes not because you walk, but because you remember."*

***

## 1. Module Overview

The **Style Router** is the central decision-making engine that dynamically selects and blends art styles based on the player's current location, historical context, and psychological state. It ensures that visual expression never drifts from the **Geo-Historical Invariant Layer** (File 2) or the **Entertainment Metrics** (File 1).

Inspired by the biome transitions in *Darkwood* (Dry Meadow → Swamp → Forest) and the stress-induced visual distortions in *Pathologic*, the Router treats style not as a static setting but as a **living response to history**.

### Core Responsibilities
1.  **Invariant Querying:** Polls `src/spectral_library.rs` for local historical data (CIC, AOS, LSG, etc.).
2.  **Metric Monitoring:** Tracks real-time entertainment metrics (UEC, EMD, STCI) to adjust style intensity.
3.  **Style Selection:** Chooses the active style contract (e.g., `spectral_engraving_dark_sublime`).
4.  **Transition Management:** Blends styles smoothly to avoid immersion-breaking jumps.
5.  **Charter Compliance:** Validates all style switches against the `Rivers of Blood Charter` (File 3).

***

## 2. Input Data Schema

The Router consumes two primary data streams. All inputs must be typed and validated before processing.

### 2.1 Historical Invariant Profile (From Spectral Library)

| Field | Type | Source | Usage |
|-------|------|--------|-------|
| `CIC` | float (0-1) | `profile.cic` | Drives decay density, rust, structural collapse. |
| `AOS` | float (0-1) | `profile.aos` | Drives visual noise, glitches, archival opacity. |
| `RRM` | float (0-1) | `profile.rrm` | Triggers ritualistic/biomech style elements. |
| `LSG` | float (0-1) | `profile.lsg` | Controls lighting contrast at thresholds. |
| `DET` | float (0-1) | `profile.det` | Adjusts vignette intensity and hallucination frequency. |

### 2.2 Entertainment Metrics (From Telemetry)

| Field | Type | Source | Usage |
|-------|------|--------|-------|
| `UEC` | float (0-1) | `metrics.uec` | If low, increase visual ambiguity (raise EMD). |
| `STCI` | float (0-1) | `metrics.stci` | If high, reduce visual noise to allow "safe" recovery. |
| `ARR` | float (0-1) | `metrics.arr` | If low, introduce more contradictory visual cues. |

***

## 3. Routing Logic & Decision Tree

The Router operates on a weighted scoring system. Each available style contract submits a "bid" based on the current invariants. The highest bidder wins, subject to safety constraints.

### 3.1 Style Contracts Available

| Style ID | Description | Primary Invariant Driver |
|----------|-------------|--------------------------|
| `spectral_engraving_dark_sublime` | Monochrome cosmic horror, top-down, restricted FOV. | **CIC** (Catastrophe), **AOS** (Opacity) |
| `machine_canyon_biomech_bci` | Industrial biomech, haptic-integrated, visceral machinery. | **RRM** (Ritual), **FCF** (Convergence) |
| `liminal_safe_haven` | Reduced contrast, warmer tones (relative), lower noise. | **Low CIC**, **Low DET** (Safe Zones) |

### 3.2 Scoring Algorithm (Pseudo-Code)

```rust
// Conceptual logic for src/style_router.rs

fn calculate_style_score(style_id: &str, profile: &HistoricalInvariantProfile) -> f32 {
    let mut score = 0.0;

    match style_id {
        "spectral_engraving_dark_sublime" => {
            // High Catastrophe + High Opacity = Engraving Style
            score += profile.cic.0 * 0.6; 
            score += profile.aos.0 * 0.4;
        },
        "machine_canyon_biomech_bci" => {
            // High Ritual + High Convergence = Biomech Style
            score += profile.rrm.0 * 0.7;
            score += profile.fcf.0 * 0.3;
        },
        "liminal_safe_haven" => {
            // Low Trauma = Safe Style
            score += (1.0 - profile.cic.0) * 0.8;
            score += (1.0 - profile.det.0) * 0.2;
        },
        _ => return 0.0,
    }

    return score;
}

fn select_style(profile: &HistoricalInvariantProfile) -> String {
    let styles = ["spectral_engraving_dark_sublime", "machine_canyon_biomech_bci", "liminal_safe_haven"];
    let mut best_style = "spectral_engraving_dark_sublime";
    let mut highest_score = 0.0;

    for style in styles {
        let score = calculate_style_score(style, profile);
        
        // Charter Safety Check: Never switch to "Safe" style in High CIC zone
        if style == "liminal_safe_haven" && profile.cic.0 > 0.5 {
            continue; // Violates Pillar 1 (Historical Grounding)
        }

        if score > highest_score {
            highest_score = score;
            best_style = style;
        }
    }

    return best_style.to_string();
}
```

### 3.3 Transition Rules (The "Darkwood" Flow)

Inspired by *Darkwood's* day/night cycle and biome shifts, style transitions must be gradual to maintain **Uncertainty Engagement (UEC)**.

| Transition Type | Duration | Effect |
|-----------------|----------|--------|
| **Biome Shift** | 5–10 seconds | Gradual color grade shift, fog density change. |
| **Night Event** | 2–5 seconds | Rapid contrast increase, saturation drop, vignette expand. |
| **Ritual Trigger** | 1–3 seconds | Glitch intensity spike, geometry warp (RRM > 0.8). |
| **Safe Zone** | 10–15 seconds | Slow fade to warmer tones, noise reduction. |

**Rule:** No instant cuts unless triggered by a **Catastrophic Imprint (CIC > 0.9)** event (e.g., structural collapse).

***

## 4. Entertainment Metric Adaptation

The Router does not just select styles; it tunes them based on real-time telemetry to maintain **Effective Mystery** (UEC > 0.55, ARR > 0.70).

### 4.1 UEC Correction (Boredom Prevention)

If `metrics.uec < 0.55`:
1.  **Increase Visual Noise:** Boost `AOS`-driven grain by 15%.
2.  **Reduce Lighting Radius:** Narrow player FOV by 5 degrees.
3.  **Trigger Ambiguity:** Spawn environmental trace (decals, shadows) without source.

### 4.2 STCI Correction (Overwhelm Prevention)

If `metrics.stci > 0.85`:
1.  **Reduce Contrast:** Soften shadows slightly to allow visual recovery.
2.  **Pause Audio-Visual Sync:** Stop flickering lights for 30 seconds.
3.  **Maintain Dread:** Do **not** switch to `liminal_safe_haven` unless CIC < 0.3 (Charter Compliance).

### 4.3 ARR Preservation (Mystery Maintenance)

If `metrics.arr < 0.70` (Too much resolution):
1.  **Introduce Contradiction:** Swap texture variants to mismatch previous clues (e.g., blood type change).
2.  **Obscure Landmarks:** Increase fog density along HVF (Haunt Vector Field) lines.
3.  **Glitch Geometry:** Shift wall alignment slightly (AOS > 0.7 required).

***

## 5. Safety & Charter Compliance

All routing decisions must pass the `Rivers of Blood Charter` validation gate (File 3).

### 5.1 Forbidden Transitions

| Transition | Reason | Charter Violation |
|------------|--------|-------------------|
| **High CIC → Bright Color** | Trivializes trauma | Pillar 1 (Historical Grounding) |
| **Low AOS → High Glitch** | Unearned confusion | Pillar 3 (Entertainment Validation) |
| **Safe Zone → Explicit Gore** | Violates implication rule | Pillar 2 (Spectral Expression) |

### 5.2 Validation Hook

```rust
// src/style_router.rs

fn validate_transition(from: &str, to: &str, profile: &HistoricalInvariantProfile) -> bool {
    // Check Rivers of Blood Charter
    if to == "explicit_gore_style" {
        return false; // Always forbidden
    }

    // Check Historical Grounding
    if profile.cic.0 > 0.8 && to == "liminal_safe_haven" {
        return false; // Cannot feel safe in a massacre site
    }

    // Check Entertainment Metrics
    if profile.aos.0 < 0.3 && to == "machine_canyon_biomech_bci" {
        return false; // Biomech requires Ritual Residue (RRM)
    }

    return true;
}
```

***

## 6. Configuration Schema (JSON)

The Router is configurable via `style_router_config.json` to allow tuning without code changes.

```json
{
  "router_version": "1.0.0",
  "default_style": "spectral_engraving_dark_sublime",
  "transition_defaults": {
    "biome_shift_duration_sec": 5.0,
    "night_event_duration_sec": 2.0,
    "safe_zone_duration_sec": 10.0
  },
  "invariant_weights": {
    "CIC": {
      "spectral_engraving": 0.6,
      "machine_canyon": 0.2,
      "liminal_safe": -0.8
    },
    "RRM": {
      "spectral_engraving": 0.3,
      "machine_canyon": 0.7,
      "liminal_safe": -0.5
    },
    "AOS": {
      "spectral_engraving": 0.4,
      "machine_canyon": 0.3,
      "liminal_safe": -0.6
    }
  },
  "metric_thresholds": {
    "uec_boredom_trigger": 0.55,
    "stci_overwhelm_trigger": 0.85,
    "arr_mystery_loss_trigger": 0.70
  },
  "charter_safety_locks": {
    "forbidden_styles": ["explicit_gore_style", "cartoon_style"],
    "high_cic_safe_zone_block": true,
    "low_aos_glitch_block": true
  }
}
```

***

## 7. Integration with PCG & AI

The Router communicates bidirectionally with other core modules.

### 7.1 PCG Generator (`src/pcg_generator.rs`)
- **Input:** Router tells PCG which style is active.
- **Output:** PCG places assets that match the style (e.g., `machine_canyon` → biomech props).
- **Constraint:** PCG cannot place `liminal_safe` assets in `high_cic` zones even if Router lags.

### 7.2 AI Personalities (`scripts/ai_chat_templates.lua`)
- **Input:** Router tells AI the current visual mood.
- **Output:** Archivist adjusts tone (e.g., `machine_canyon` → clinical/cold language; `spectral_engraving` → fragmented/poetic).
- **Sync:** AI dialogue triggers style glitches (e.g., Witness testimony → screen noise spike).

### 7.3 Audio Automation (`src/audio_automation.rs`)
- **Input:** Router style ID.
- **Output:** Audio mixer selects appropriate reverb/filter presets (e.g., `machine_canyon` → metallic reverb; `spectral_engraving` → dampened/underwater).

***

## 8. Testing & Validation Plan

### 8.1 Unit Tests
- **Test:** `test_router_high_cic_safe_zone_block`
  - **Input:** CIC = 0.9, Request = `liminal_safe_haven`
  - **Expected:** Return `spectral_engraving_dark_sublime`
- **Test:** `test_router_uec_correction`
  - **Input:** UEC = 0.40, Style = `spectral_engraving`
  - **Expected:** Visual noise parameter increased by 15%

### 8.2 Playtest Metrics
- **Goal:** Verify style transitions do not cause motion sickness (STCI spike).
- **Goal:** Verify style changes correlate with increased UEC (not confusion).
- **Method:** A/B testing transition durations (2s vs 10s) during night events.

***

## 9. Reference Cases (Darkwood & Pathologic)

| Feature | Darkwood Implementation | Horror$Place Router Adaptation |
|---------|-------------------------|--------------------------------|
| **Day/Night** | Static shift at 6 PM. | Dynamic shift based on DET (Dread Exposure) + Time. |
| **Biome** | Fixed map zones. | Fluid zones based on CIC/RRM heatmaps. |
| **Sanity** | Hallucinations at low sanity. | Style glitches at high AOS + Low ARR. |
| **Stress** | Screen shake/red tint. | STCI-driven contrast reduction (recovery) vs. increase (stress). |

***

## 10. Compliance Checklist

Before merging changes to the Style Router:

- [ ] **Invariant Check:** Does the router query `spectral_library.rs` for all decisions?
- [ ] **Charter Check:** Are forbidden styles blocked in `validate_transition()`?
- [ ] **Metric Check:** Does the router respond to UEC/STCI thresholds?
- [ ] **Transition Check:** Are all style shifts blended (no instant cuts unless CIC > 0.9)?
- [ ] **Config Check:** Is `style_router_config.json` updated for new weights?

***

**Document Status:** Active  
**Last Updated:** 2026-01-01  
**Maintainer:** Horror$Place Engine Team  
**Related Files:** `src/spectral_library.rs`, `docs/artstyle_spectral_engraving_dark_sublime.md`, `docs/rivers_of_blood_charter.md`
