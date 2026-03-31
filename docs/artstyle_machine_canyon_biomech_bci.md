# Art Style Specification: Machine Canyon (Biomech BCI)
### Horror$Place Industrial Horror Contract v1.0

> *"The machine does not hate you. It simply requires fuel."*

***

## 1. Style Overview

**Machine Canyon** is the secondary visual language of Horror$Place, triggered in regions of high **Ritual Residue (RRM)** and **Folkloric Convergence (FCF)**. It represents the industrialization of horror: where machinery consumes biology not out of malice, but out of function.

Inspired by the abandoned industrial sites of the Aral Sea (Darkwood 2), the surreal biology of *Pathologic*, and the claustrophobic machinery of *Event[0]*, this style treats the environment as a living, breathing engine. The player is not a hero; they are potential fuel.

### Core Philosophy
1.  **Functional Horror:** Machines operate logically but consume illogically (e.g., pistons pumping blood instead of oil).
2.  **Claustrophobic Navigation:** Paths are narrow, confusing, and shift subtly (non-Euclidean hints) to induce disorientation.
3.  **BCI Resonance:** Experimental integration where machine rhythms sync with player physiological stress (Tier 3 Research).
4.  **Implied Consumption:** Biology is never shown being destroyed; it is shown as *input* (hair in gears, respiratory sounds in vents).

***

## 2. Visual Invariant Mapping

This style contract defines how the **Geo-Historical Invariants** drive the biomech aesthetic. The engine queries these invariants to adjust the "Machine Canyon" parameters in real-time.

| Invariant | Visual Parameter | Behavior Rule |
|-----------|------------------|---------------|
| **RRM** (Ritual Residue) | **Machine Activity** | High RRM (>0.8) activates idle machinery (pistons, conveyor belts) without power sources. |
| **FCF** (Folkloric Convergence) | **Geometry Shift** | High FCF (>0.7) causes corridors to lengthen or doors to relocate when unobserved. |
| **CIC** (Catastrophic Imprint) | **Decay Type** | High CIC (>0.9) shifts decay from rust to "organic corrosion" (fleshy rust, weeping metal). |
| **DET** (Dread Exposure) | **Lighting Failure** | As DET increases, lights flicker in rhythm with player heartbeat (if BCI active). |
| **AOS** (Archival Opacity) | **Label Legibility** | High AOS blurs machine warning labels, making them unreadable or contradictory. |
| **HVF** (Haunt Vector) | **Airflow Direction** | Vent airflow particles move against HVF, suggesting suction toward "consumption zones." |

***

## 3. Color Palette & Lighting

### 3.1 The Industrial Void Palette

Color is used to signify function and danger. The world is dark, metallic, and occasionally visceral.

| Color Role | Hex Code | Usage |
|------------|----------|-------|
| **Oil Black** | `#050505` | Deep shadows, machine interiors, unlit corridors. |
| **Oxidized Copper** | `#3B4D4D` | Primary metal surfaces (pipes, walls, machinery). |
| **Bioluminescent Amber** | `#FFBF00` | **ONLY** for machine status lights, warning beacons. |
| **Dried Blood Rust** | `#4A2C2A` | **ONLY** for stains on machinery, filters, intake vents. |
| **Sterile White** | `#E0E0E0` | **ONLY** for laboratory zones, surgical tools (cold, unfeeling). |

**Rule:** No natural light sources (sun, moon). All light is artificial (bulbs, LEDs, sparks). Shadows are hard and mechanical.

### 3.2 Lighting Mechanics

1.  **Strobe Effect:** Lights flicker at irregular intervals (2–5 seconds) to disrupt player vision timing.
2.  **Shadow Occlusion:** Machinery casts dense shadows that obscure pathways. Players must move through shadows to progress.
3.  **Emergency Lighting:** In high-CIC zones, only red emergency lights function, reducing visibility radius by 40%.
4.  **BCI Sync (Tier 3):** If BCI hardware is detected, light flicker frequency matches player HRV (Heart Rate Variability) to create subconscious resonance.

***

## 4. Geometry & Navigation

### 4.1 The Canyon Structure

-   **Narrow Corridors:** Pathways are barely wide enough for the player character (shoulder-grazing).
-   **Verticality:** Multi-level catwalks, ladders, and pits. Falling is instant death or severe injury.
-   **Looping Paths:** Corridors may loop back on themselves (FCF > 0.8) to induce disorientation.
-   **Dead Ends:** Many paths terminate in machinery intakes or sealed bulkheads.

### 4.2 The Living Machine

-   **Breathing Walls:** Metal surfaces expand/contract slightly (scale 1.0 → 1.02) to simulate respiration.
-   **Fluid Leaks:** Pipes leak viscous fluids (oil/blood ambiguity) that pool on floors.
-   **Intake Vents:** Large grates emit suction sounds and pull debris (papers, cloth) inward. **Never show what lies beyond.**

***

## 5. Asset Validation & Forbidden Elements

All assets must pass `StyleLint` validation against this contract before merging.

### 5.1 Allowed Evidence Types

| Asset Type | Description | Invariant Link |
|------------|-------------|----------------|
| **Biomech Decals** | Hair caught in gears, blood smears on levers, fingerprints on glass. | CIC, RRM |
| **Machine Logs** | Printouts showing "Fuel Efficiency" spikes correlated with missing persons. | AOS, FCF |
| **Respiratory Audio** | Hissing vents that sound like wheezing breathing. | DET, HVF |
| **Structural Shifts** | Doors that lock/unlock based on player stress (BCI). | FCF, DET |

### 5.2 Forbidden Depictions (Charter Violation)

| Forbidden Asset | Reason | Alternative |
|-----------------|--------|-------------|
| **Visible Bodies in Machinery** | Violates Pillar 2 (Implication). | Show personal effects (wallets, IDs) near intakes. |
| **Explicit Gore/Disembowelment** | Violates Pillar 2 (Implication). | Use blood rust stains and fluid leaks only. |
| **Sentient Robots** | Breaks "Functional Horror" rule. | Machines are dumb engines; the horror is their purpose. |
| **Open Sky** | Breaks Claustrophobia rule. | Ceilings are always pipes, concrete, or metal plating. |
| **Natural Sounds** | Breaks Industrial Atmosphere. | Replace birds/wind with hums, clicks, hydraulics. |

***

## 6. BCI & Haptic Integration (Tier 3 Research)

This section defines experimental features gated behind `research` feature flags in `Cargo.toml`.

### 6.1 Physiological Mapping

| Physiological Signal | Machine Response | Purpose |
|----------------------|------------------|---------|
| **Heart Rate (HR)** | Pumping speed of hydraulic pistons. | Syncs environment to player anxiety. |
| **Electrodermal (EDA)** | Static charge on metal surfaces (spark frequency). | Visualizes player stress as electrical danger. |
| **Respiration** | Vent airflow intensity (whistling/hissing). | Makes the building feel like it's breathing with the player. |

### 6.2 Haptic Feedback

-   **Rumble Patterns:** Low-frequency rumble (20–40Hz) when near active machinery.
-   **Adaptive Triggers:** Controller triggers stiffen when interacting with jammed levers or heavy doors.
-   **Heartbeat Sync:** Haptic pulse matches player HR (if BCI active) to blur line between self and machine.

***

## 7. Machine-Readable Style Contract

This JSON structure defines the enforceable rules for the `StyleLint` tool (File 7).

```json
{
  "style_id": "machine_canyon_biomech_bci",
  "version": "1.0.0",
  "palette_constraints": {
    "max_saturation": 0.5,
    "allowed_accent_colors": ["#FFBF00", "#4A2C2A", "#E0E0E0"],
    "base_palette": "industrial_void"
  },
  "geometry_constraints": {
    "min_corridor_width_meters": 1.2,
    "max_visibility_range_meters": 15.0,
    "ceiling_type": "enclosed",
    "natural_light_allowed": false
  },
  "invariant_bindings": {
    "RRM": { "target": "machine_activity", "min_threshold": 0.6, "max_effect": 1.0 },
    "FCF": { "target": "geometry_shift", "min_threshold": 0.7, "max_effect": 0.8 },
    "CIC": { "target": "organic_corrosion", "min_threshold": 0.8, "max_effect": 0.9 }
  },
  "bci_features": {
    "enabled": false,
    "feature_flag": "research",
    "hr_sync_pumps": true,
    "eda_static_sparks": true,
    "respire_vents": true
  },
  "forbidden_tags": [
    "visible_corpse",
    "explicit_gore",
    "sentient_ai",
    "open_sky",
    "natural_sounds"
  ],
  "entertainment_targets": {
    "STCI": { "min": 0.60, "max": 0.80 },
    "CDL": { "min": 0.75, "max": 0.95 }
  }
}
```

***

## 8. Workflow Integration

### 8.1 Asset Generation Sprints

-   **Photogrammetry:** Scan real-world Soviet industrial sites (pumps, valves, control panels) but texture them with "organic corrosion" shaders.
-   **Modular Kits:** Create "Canyon Kits" (walls, floors, pipes) that snap together to form narrow, looping corridors.
-   **Audio-Visual Sync:** Link machine animation cycles to audio stems (piston slam = hydraulic hiss) for cohesive feedback.

### 8.2 Runtime Validation

-   **Style Runtime Validator:** Monitors lighting and geometry. If natural light enters the scene or corridors widen beyond 2.0 meters, it triggers a warning.
-   **Invariant Sync:** Every frame, the renderer queries `SpectralLibrary` for RRM/FCF levels and adjusts machine activity (idle → active) accordingly.

***

## 9. Reference Cases (Pathologic & Darkwood 2)

| Feature | Pathologic Implementation | Horror$Place Adaptation |
|---------|---------------------------|-------------------------|
| **Architecture** | Surreal, impossible structures. | Industrial impossible geometry (loops, shifts). |
| **Horror** | Plague as invisible enemy. | Machine consumption as invisible function. |
| **Setting** | Town as living organism. | Factory as living organism. |
| **Survival** | Time management, immunity. | Navigation management, stealth. |
| **Atmosphere** | Oppressive, philosophical. | Claustrophobic, functional dread. |

***

## 10. Compliance Checklist

Before any visual asset is merged into the repository:

- [ ] **Palette Check:** Is saturation < 50%? Are natural colors excluded?
- [ ] **Implication Check:** Does this asset show evidence of consumption rather than explicit bodies?
- [ ] **Invariant Check:** Is there a defined RRM/FCF binding for this asset?
- [ ] **Geometry Check:** Does this asset fit within narrow corridor constraints (width < 2.0m)?
- [ ] **BCI Check:** Are experimental features gated behind `research` flags?

***

**Document Status:** Active  
**Last Updated:** 2026-01-01  
**Maintainer:** Horror$Place Art Direction Team  
**Related Files:** `src/spectral_library.rs`, `docs/artstyle_spectral_engraving_dark_sublime.md`, `docs/style_router_module_spec.md`
