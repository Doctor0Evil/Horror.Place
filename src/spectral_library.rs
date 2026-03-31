//! # Horror$Place Spectral Library
//!
//! The core API for querying the Geo-Historical Invariant Layer.
//! This module defines the structural relationship between historical evidence
//! and procedural horror generation, ensuring all terror is grounded in
//! verifiable data (CIC, MDI, AOS) rather than arbitrary spookiness.
//!
//! ## Directional Flow
//! 1. **History Layer** (Real-world data, folklore, disasters)
//! 2. **Invariants** (CIC, MDI, AOS, etc. - The "Truth" of the location)
//! 3. **Expression** (Art, Audio, AI - The "Echo" of the truth)
//! 4. **Metrics** (UEC, EMD, ARR, etc. - The "Entertainment" validation)
//!
//! ## Safety Compliance
//! All queries must adhere to the `RiversOfBloodCharter`.
//! Explicit violence is forbidden; only evidence/implication is permitted.

use serde::{Deserialize, Serialize};
use std::fmt::Debug;

// ============================================================================
// SECTION 1: HISTORY-HORROR ATTRIBUTION TERMS (The Input Layer)
// ============================================================================
// These 10 terms serve as machine-readable tags bridging historical fact
// and horror-system design. They are the "Truth" the engine reads.

/// **Catastrophic Imprint Coefficient (CIC)**
/// Quantifies how heavily a location is stamped by major disasters (wars, spills, plagues).
/// Range: 0.0 (None) to 1.0 (Ground Zero)
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct CatastrophicImprintCoefficient(pub f32);

/// **Mythic Density Index (MDI)**
/// Measures concentration of rumors/myths normalized by population/time.
/// High MDI drives audio anomalies and reality glitches.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct MythicDensityIndex(pub f32);

/// **Archival Opacity Score (AOS)**
/// Captures how incomplete/contradictory historical records are.
/// High AOS biases hidden dungeons and sanity breaks.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct ArchivalOpacityScore(pub f32);

/// **Liminal Stress Gradient (LSG)**
/// Describes sharp transitions between states (land-water, living-abandoned).
/// High LSG lines are perfect for thresholds/stalker spawns.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct LiminalStressGradient(pub f32);

/// **Spectral Plausibility Rating (SPR)**
/// Computed likelihood that a legend could be "true" within world rules.
/// Keeps horror grounded (Low SPR = ambient text, High SPR = systemic enemies).
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct SpectralPlausibilityRating(pub f32);

/// **Ritual Residue Map (RRM)**
/// Spatial layer marking repeated structured human behavior (cults, experiments).
/// Drives occult mechanics boot-up speed.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct RitualResidueMap(pub f32);

/// **Folkloric Convergence Factor (FCF)**
/// Measures how many independent storylines point to the same area.
/// High FCF sites are natural boss zones.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct FolkloricConvergenceFactor(pub f32);

/// **Reliability Weighting Factor (RWF)**
/// Rates each source contributing to a region's story (Official vs. Drunk Tale).
/// Low RWF + High CIC = Uncanny side-events.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct ReliabilityWeightingFactor(pub f32);

/// **Dread Exposure Threshold (DET)**
/// Time limit before psychological effects occur in this area.
/// Drives sanity systems and hallucination triggers.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct DreadExposureThreshold(pub f32);

/// **Haunt Vector Field (HVF)**
/// Directional "flow" of uncanny pressure across the map.
/// Biases movement, weather, and ambient sound migration.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct HauntVectorField {
    pub x: f32,
    pub y: f32,
    pub magnitude: f32,
}

/// Aggregated Historical Invariant Profile for a specific Coordinate/Tile.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoricalInvariantProfile {
    pub cic: CatastrophicImprintCoefficient,
    pub mdi: MythicDensityIndex,
    pub aos: ArchivalOpacityScore,
    pub lsg: LiminalStressGradient,
    pub spr: SpectralPlausibilityRating,
    pub rrm: RitualResidueMap,
    pub fcf: FolkloricConvergenceFactor,
    pub rwf: ReliabilityWeightingFactor,
    pub det: DreadExposureThreshold,
    pub hvf: HauntVectorField,
}

// ============================================================================
// SECTION 2: ENTERTAINMENT METRICS (The Validation Layer)
// ============================================================================
// These 5 terms measure player experience to ensure horror is entertaining.
// Linked to `schemas/entertainment_metrics_v1.json`.

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct EntertainmentMetrics {
    /// Uncertainty Engagement Coefficient (Target: 0.55 - 0.85)
    pub uec: f32,
    /// Evidential Mystery Density (Target: 0.60 - 0.90)
    pub emd: f32,
    /// Safe-Threat Contrast Index (Target: 0.40 - 0.70)
    pub stci: f32,
    /// Cognitive Dissonance Load (Target: 0.70 - 0.95)
    pub cdl: f32,
    /// Ambiguous Resolution Ratio (Target: 0.70 - 1.0)
    pub arr: f32,
}

impl EntertainmentMetrics {
    /// Validates if the current session meets "Effective Mystery" state.
    /// Logic: UEC > 0.55 AND ARR > 0.70
    pub fn is_effective_mystery(&self) -> bool {
        self.uec > 0.55 && self.arr > 0.70
    }

    /// Checks for player overwhelm (STCI > 0.85 OR UEC < 0.30)
    pub fn is_overwhelmed(&self) -> bool {
        self.stci > 0.85 || self.uec < 0.30
    }
}

// ============================================================================
// SECTION 3: THE SPECTRAL API (The Directional Bridge)
// ============================================================================

/// The core trait for querying the History Layer.
/// Implementations may load from JSON, SQLite, or Procedural Seeds.
pub trait SpectralLibrary {
    /// Query the historical invariant profile for a given coordinate.
    fn query_invariants(&self, x: f32, y: f32) -> HistoricalInvariantProfile;

    /// Calculate expected entertainment metrics based on invariants.
    /// This is the predictive model used by PCG to ensure fun before spawning.
    fn predict_metrics(&self, profile: &HistoricalInvariantProfile) -> EntertainmentMetrics;

    /// Validate that a proposed horror event complies with the Rivers of Blood Charter.
    /// Returns false if the event relies on explicit violence rather than evidence.
    fn validate_charter_compliance(&self, event_type: &str, profile: &HistoricalInvariantProfile) -> bool;
}

/// Example Implementation Logic (Pseudo-code for Direction)
/// This demonstrates how History drives Horror without explicit violence.
pub struct StandardSpectralLibrary;

impl SpectralLibrary for StandardSpectralLibrary {
    fn query_invariants(&self, x: f32, y: f32) -> HistoricalInvariantProfile {
        // In production, this queries the Geo-Historical Database.
        // For now, returns a seeded default to establish type safety.
        HistoricalInvariantProfile {
            cic: CatastrophicImprintCoefficient(0.0),
            mdi: MythicDensityIndex(0.0),
            aos: ArchivalOpacityScore(0.0),
            lsg: LiminalStressGradient(0.0),
            spr: SpectralPlausibilityRating(0.0),
            rrm: RitualResidueMap(0.0),
            fcf: FolkloricConvergenceFactor(0.0),
            rwf: ReliabilityWeightingFactor(0.0),
            det: DreadExposureThreshold(0.0),
            hvf: HauntVectorField { x: 0.0, y: 0.0, magnitude: 0.0 },
        }
    }

    fn predict_metrics(&self, profile: &HistoricalInvariantProfile) -> EntertainmentMetrics {
        // DIRECTIONAL LOGIC:
        // High AOS (Opacity) -> High EMD (Mystery Density)
        // High CIC (Catastrophe) -> High UEC (Uncertainty Engagement)
        // High LSG (Liminal) -> High STCI (Contrast)
        
        let emd = (profile.aos.0 * 0.8) + 0.2; 
        let uec = (profile.cic.0 * 0.7) + 0.3;
        
        EntertainmentMetrics {
            uec: uec.min(1.0),
            emd: emd.min(1.0),
            stci: profile.lsg.0,
            cdl: profile.fcf.0,
            arr: 1.0 - (profile.rwf.0 * 0.5), // High Reliability lowers Ambiguity
        }
    }

    fn validate_charter_compliance(&self, event_type: &str, profile: &HistoricalInvariantProfile) -> bool {
        // RIVERS OF BLOOD CHARTER CHECK
        // Forbidden: Explicit Gore, Jump Scares without Context, Gratuitous Violence.
        // Allowed: Environmental Evidence, Audio Echoes, Contradictory Records.
        
        let forbidden_events = ["explicit_gore", "gratuitous_violence", "random_jump_scare"];
        
        if forbidden_events.contains(&event_type) {
            return false;
        }

        // Safety: High CIC areas must use Evidence, not Violence.
        if profile.cic.0 > 0.8 && event_type == "violent_encounter" {
            return false; // Must be "disturbed earth" or "abandoned tools" instead
        }

        true
    }
}

// ============================================================================
// SECTION 4: ARCHIVIST PERSONALITY HOOKS
// ============================================================================
// Specific hooks for the Priority #1 AI Personality (The Archivist).
// These allow the AI to query history to generate contradictory records.

#[derive(Debug)]
pub struct ArchivistQuery {
    pub location_x: f32,
    pub location_y: f32,
    pub player_knowledge_level: f32, // 0.0 (Ignorant) to 1.0 (Aware)
}

impl ArchivistQuery {
    /// Determines if the Archivist should withhold or reveal information.
    /// Logic: High AOS + Low Player Knowledge = Withhold (Raise Mystery)
    pub fn should_withhold_truth(&self, profile: &HistoricalInvariantProfile) -> bool {
        profile.aos.0 > 0.7 && self.player_knowledge_level < 0.5
    }

    /// Determines if the Archivist should introduce a contradiction.
    /// Logic: High RWF (Reliability) + High FCF (Convergence) = Contradict Official Record
    pub fn should_contradict_record(&self, profile: &HistoricalInvariantProfile) -> bool {
        profile.rwf.0 > 0.8 && profile.fcf.0 > 0.6
    }
}
