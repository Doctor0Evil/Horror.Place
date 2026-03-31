# Spectral Library Specification

## Version: 1.0
## Effective Date: 2026-04-01

### 1. Introduction

The Spectral Library is the core Rust module (`src/spectral_library.rs`) responsible for managing and querying the horror invariants (CIC, MDI, AOS, etc.) associated with different regions and contexts within the Horror$Place universe. It acts as the authoritative backend for the `H.` Lua API, ensuring that all content generation and event triggering adheres to the quantified rules of historical and spectral coherence defined by the Horror$Place History and Entertainment Framework (HPEF).

### 2. Core Responsibilities

- **Invariant Storage**: Maintain a structured database of regions and their associated invariant values (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI).
- **Invariant Querying**: Provide fast, reliable lookup functions for invariant values based on region identifiers or other context keys.
- **Precondition Validation**: Evaluate whether a set of preconditions (typically a list of invariant thresholds) are met for a given context. This is crucial for triggering `Surprise.Events!` or activating specific persona behaviors.
- **API Abstraction**: Offer a clean, well-defined Rust API that can be safely wrapped and exposed to other parts of the engine, particularly via the `H.` Lua API.
- **Registry Integration**: Optionally, load initial invariant data from a structured file (e.g., referenced via `registry/regions.json` in the public core, pointing to private data) to allow for dynamic updates without recompilation.

### 3. Core Data Structures

#### 3.1. `RegionId`
A unique identifier for a geographical, historical, or thematic region within the simulation.
```rust
pub type RegionId = String; // e.g., "aral_sea_basin", "soviet_factory_block_17"
```

#### 3.2. `HorrorInvariants`
A struct holding all 11 core invariant values for a given context.
```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HorrorInvariants {
    pub CIC: f64, // Catastrophic Imprint Coefficient
    pub MDI: f64, // Mythic Density Index
    pub AOS: f64, // Archival Opacity Score
    pub RRM: f64, // Ritual Residue Map
    pub FCF: f64, // Folkloric Convergence Factor
    pub SPR: f64, // Spectral Plausibility Rating
    pub RWF: f64, // Reliability Weighting Factor
    pub DET: f64, // Dread Exposure Threshold
    pub HVF: f64, // Historical Veracity Factor
    pub LSG: f64, // Liminal Stress Gradient
    pub SHCI: f64, // Spectral-Historical Coherence Index
}
```

#### 3.3. `Precondition`
A condition that specifies a minimum (or maximum) required value for an invariant.
```rust
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum InvariantThreshold {
    Min(f64),
    Max(f64),
}

pub type Precondition = HashMap<String, InvariantThreshold>; // e.g., {"CIC": Min(0.8), "SPR": Min(0.6)}
```

### 4. Core API Functions

The following functions constitute the public interface of the Spectral Library module. The `H.` Lua API will provide wrappers for these.

#### 4.1. `get_region_invariants(region_id: &RegionId) -> Result<HorrorInvariants, Error>`
Retrieves the full set of invariants for a given `region_id`. Returns an error if the region is not found.

#### 4.2. `evaluate_preconditions(context_invariants: &HorrorInvariants, preconditions: &Precondition) -> bool`
Checks if the `context_invariants` satisfy all conditions specified in the `preconditions` map. Returns `true` if all are met, `false` otherwise.

#### 4.3. `get_regional_preconditions(region_id: &RegionId) -> Result<Option<Precondition>, Error>`
Fetches any default or ambient preconditions associated with a region, which might be used as baseline checks for any event or persona activation within that region.

#### 4.4. `load_from_registry(registry_path: &str) -> Result<SpectralLibrary, Error>` (Optional)
Initializes or updates the internal invariant store by loading data from a structured file, potentially referenced by the public `registry/regions.json`.

### 5. Integration

- **`H.` API (`engine/horrorinvariants.lua`)**: This module provides the Lua bindings for the Rust functions, allowing other Lua scripts (e.g., `surprisedirector.lua`, `trajectoryscare.lua`) to query invariants using a syntax like `H.CIC("aral_sea_basin")`.
- **PCG Generator (`src/pcg_generator.rs`)**: Uses `get_region_invariants` to seed procedural generation algorithms with context-appropriate parameters derived from the region's invariants (e.g., a high RRM might lead to more repetitive, maze-like structures).
- **Audio Automation (`src/audio_automation.rs`)**: Consults invariants to dynamically adjust audio palettes and ambience (e.g., high MDI might introduce more folklore-inspired musical motifs or whispered voices).
- **Event Contracts (`registry/events.json`)**: Events often have `trigger_conditions` which are `Precondition` objects that are evaluated by this library against the current context invariants.

This module is the quantitative heart of the Horror$Place system, ensuring that the generated horror is structurally consistent with the project's unique invariant-based framework.
**Preview:** This file defines the detailed specification for the `spectral_library.rs` module, the core Rust component responsible for managing the 11 horror invariants (CIC, MDI, AOS, etc.). It outlines the data structures (`HorrorInvariants`, `Precondition`), the core API functions for querying and evaluating invariants, and how it integrates with other engine components like the `H.` Lua API, PCG generator, and event system. This ensures a solid, well-defined backend for the invariant system.

**Files Remaining:** 17
