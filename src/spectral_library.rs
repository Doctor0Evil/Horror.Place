// src/spectral_library.rs
//
// The Spectral Library module provides the authoritative backend for Horror$Place invariants.
// It manages a database of regions and their associated invariant values (CIC, MDI, AOS, etc.).
// It exposes functions for querying these values and evaluating preconditions against them.
// This module is designed to be safe for FFI (Foreign Function Interface) binding to Lua.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::error::Error;
use std::fmt;

// --- Data Structures ---

/// Unique identifier for a region or location.
pub type RegionId = String; // e.g., "aral_sea_basin", "soviet_factory_block_17"

/// Enum to represent the type of threshold for an invariant.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum InvariantThreshold {
    Min(f64),
    Max(f64),
}

/// Struct holding all 11 core invariant values.
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

impl HorrorInvariants {
    /// Creates a new instance with default values (0.0).
    pub fn new() -> Self {
        HorrorInvariants {
            CIC: 0.0,
            MDI: 0.0,
            AOS: 0.0,
            RRM: 0.0,
            FCF: 0.0,
            SPR: 0.0,
            RWF: 0.0,
            DET: 0.0,
            HVF: 0.0,
            LSG: 0.0,
            SHCI: 0.0,
        }
    }
}

/// Type alias for a set of preconditions.
pub type Precondition = HashMap<String, InvariantThreshold>;

// --- Error Handling ---

#[derive(Debug)]
pub enum SpectralLibraryError {
    RegionNotFound(String),
    IoError(std::io::Error),
    JsonError(serde_json::Error),
}

impl fmt::Display for SpectralLibraryError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            SpectralLibraryError::RegionNotFound(id) => write!(f, "Region not found: {}", id),
            SpectralLibraryError::IoError(e) => write!(f, "IO Error: {}", e),
            SpectralLibraryError::JsonError(e) => write!(f, "JSON Error: {}", e),
        }
    }
}

impl Error for SpectralLibraryError {}

impl From<std::io::Error> for SpectralLibraryError {
    fn from(error: std::io::Error) -> Self {
        SpectralLibraryError::IoError(error)
    }
}

impl From<serde_json::Error> for SpectralLibraryError {
    fn from(error: serde_json::Error) -> Self {
        SpectralLibraryError::JsonError(error)
    }
}

// --- Main Module ---

/// The core Spectral Library struct.
pub struct SpectralLibrary {
    regions: HashMap<RegionId, HorrorInvariants>,
}

impl SpectralLibrary {
    /// Creates a new, empty Spectral Library.
    pub fn new() -> Self {
        SpectralLibrary {
            regions: HashMap::new(),
        }
    }

    /// Adds or updates a region's invariants.
    pub fn add_region(&mut self, id: RegionId, invariants: HorrorInvariants) {
        self.regions.insert(id, invariants);
    }

    /// Retrieves the invariants for a given region.
    pub fn get_region_invariants(&self, region_id: &RegionId) -> Result<&HorrorInvariants, SpectralLibraryError> {
        self.regions.get(region_id)
            .ok_or_else(|| SpectralLibraryError::RegionNotFound(region_id.clone()))
    }

    /// Evaluates a set of preconditions against a given set of invariants.
    pub fn evaluate_preconditions(context_invariants: &HorrorInvariants, preconditions: &Precondition) -> bool {
        for (invariant_name, threshold) in preconditions {
            let value = match invariant_name.as_str() {
                "CIC" => context_invariants.CIC,
                "MDI" => context_invariants.MDI,
                "AOS" => context_invariants.AOS,
                "RRM" => context_invariants.RRM,
                "FCF" => context_invariants.FCF,
                "SPR" => context_invariants.SPR,
                "RWF" => context_invariants.RWF,
                "DET" => context_invariants.DET,
                "HVF" => context_invariants.HVF,
                "LSG" => context_invariants.LSG,
                "SHCI" => context_invariants.SHCI,
                _ => return false, // Unknown invariant name
            };

            match threshold {
                InvariantThreshold::Min(min_val) => {
                    if value < *min_val {
                        return false;
                    }
                }
                InvariantThreshold::Max(max_val) => {
                    if value > *max_val {
                        return false;
                    }
                }
            }
        }
        true
    }

    // Optional: Load initial data from a JSON file path (referenced via registry).
    // pub fn load_from_file(&mut self, path: &str) -> Result<(), SpectralLibraryError> {
    //     let contents = std::fs::read_to_string(path)?;
    //     let new_regions: HashMap<RegionId, HorrorInvariants> = serde_json::from_str(&contents)?;
    //     self.regions.extend(new_regions);
    //     Ok(())
    // }
}

// --- Example Usage ---
/*
fn main() {
    let mut lib = SpectralLibrary::new();

    let mut aral_basin_inv = HorrorInvariants::new();
    aral_basin_inv.CIC = 0.85;
    aral_basin_inv.AOS = 0.92;
    aral_basin_inv.SPR = 0.78;
    lib.add_region("aral_sea_basin".to_string(), aral_basin_inv);

    match lib.get_region_invariants(&"aral_sea_basin".to_string()) {
        Ok(invariants) => println!("CIC for Aral Sea: {}", invariants.CIC),
        Err(e) => println!("Error: {}", e),
    }

    let mut event_precondition = Precondition::new();
    event_precondition.insert("CIC".to_string(), InvariantThreshold::Min(0.8));
    event_precondition.insert("SPR".to_string(), InvariantThreshold::Min(0.7));

    let context_inv = lib.get_region_invariants(&"aral_sea_basin".to_string()).unwrap(); // Assume it exists
    let is_triggered = SpectralLibrary::evaluate_preconditions(context_inv, &event_precondition);
    println!("Event triggers: {}", is_triggered);
}
*/
