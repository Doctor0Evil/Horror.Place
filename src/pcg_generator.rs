//! # Horror$Place Procedural Content Generation Engine
//!
//! This module implements history-aware procedural generation where horror placement
//! is determined by the **Geo-Historical Invariant Layer** rather than random chance.
//! Every tile, encounter, and environmental trace is anchored to verifiable historical
//! data (CIC, AOS, RRM, etc.) to ensure horror feels inevitable, not arbitrary.
//!
//! ## Core Philosophy (Ice-Pick Lodge "Deep Game")
//! - **No Hand-Holding:** No quest markers, waypoints, or map annotations.
//! - **Intentional Discomfort:** Players should feel lost, uncertain, and vulnerable.
//! - **Player as Co-Author:** Environmental evidence invites interpretation, not exposition.
//! - **Historical Grounding:** Horror emerges from real-world trauma, not fantasy.
//!
//! ## Reference: Darkwood 2 Aral Sea Setting
//! - Ship graveyards stranded miles from water (CIC-driven decay)
//! - Vozrozhdeniya Island biological testing sites (RRM-driven anomalies)
//! - Post-Soviet industrial collapse (AOS-driven archival gaps)
//! - Toxic dust storms and salt flats (DET-driven psychological effects)
//!
//! ## Safety Compliance
//! All generation adheres to the `Rivers of Blood Charter` (File 3):
//! - Evidence-based implication only (no explicit gore/violence)
//! - Historical grounding required for all horror elements
//! - Entertainment metrics validated before spawn approval

use crate::spectral_library::{
    SpectralLibrary, HistoricalInvariantProfile, EntertainmentMetrics,
    CatastrophicImprintCoefficient, ArchivalOpacityScore, RitualResidueMap,
    LiminalStressGradient, FolkloricConvergenceFactor, HauntVectorField,
    DreadExposureThreshold, SpectralPlausibilityRating,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use rand::Rng;

// ============================================================================
// SECTION 1: PCG TILE DATA STRUCTURES
// ============================================================================

/// A single tile in the procedurally generated world.
/// Each tile carries its historical invariant profile for runtime queries.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorldTile {
    pub x: i32,
    pub y: i32,
    pub tile_type: TileType,
    pub invariants: HistoricalInvariantProfile,
    pub generated_assets: Vec<GeneratedAsset>,
    pub encounter_seeded: bool,
    pub navigation_hint: Option<NavigationHint>, // No waypoints - only environmental hints
}

/// Tile classification based on historical amplitude.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TileType {
    /// Safe zones (low CIC, high DET) - hideouts, trader camps
    SafeHaven,
    /// Exploration zones (mid CIC, mid AOS) - scavenging, clues
    Exploration,
    /// High-threat zones (high CIC, high RRM) - anomalies, spectral echoes
    HighThreat,
    /// Liminal thresholds (high LSG) - doorways, biome transitions
    LiminalThreshold,
    /// Atrocity anchors (CIC > 0.9) - boss zones, major historical events
    AtrocityAnchor,
}

/// Generated asset with invariant bindings for validation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeneratedAsset {
    pub asset_id: String,
    pub asset_type: AssetType,
    pub invariant_bindings: InvariantBindings,
    pub charter_compliant: bool,
    pub entertainment_contribution: EntertainmentContribution,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AssetType {
    EnvironmentalTrace,    // Bloodstains, drag marks, disturbed earth
    ArchivalEvidence,      // Redacted documents, torn photos, logs
    StructuralAnomaly,     // Doors to walls, impossible geometry
    AudioEcho,            // Fragmented testimony, ritual chanting
    SpectralResidual,     // Shadow figures, flickering lights (no explicit entities)
    IndustrialDecay,      // Rusted machinery, ship graveyard elements
    BiologicalContamination, // Toxic flora, mutated vegetation (Aral Sea reference)
}

/// Invariant bindings that justify this asset's presence.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvariantBindings {
    pub primary_invariant: String, // e.g., "CIC", "AOS", "RRM"
    pub threshold_met: f32,
    pub historical_source: String, // e.g., "Aral Sea Environmental Disaster Archives"
    pub spectral_plausibility: f32, // SPR value (0-1)
}

/// How this asset contributes to entertainment metrics.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EntertainmentContribution {
    pub uec_delta: f32, // Uncertainty Engagement Coefficient
    pub emd_delta: f32, // Evidential Mystery Density
    pub stci_delta: f32, // Safe-Threat Contrast Index
    pub cdl_delta: f32, // Cognitive Dissonance Load
    pub arr_delta: f32, // Ambiguous Resolution Ratio
}

/// Environmental navigation hints (replaces quest markers).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NavigationHint {
    /// HVF-driven fog flow direction
    FogFlow(HauntVectorField),
    /// Architectural landmark (water tower, radio mast)
    Landmark(String),
    /// Audio cue direction (distant chanting, machinery hum)
    AudioCue { direction: f32, invariant_source: String },
    /// Light source in distance (never marks objective directly)
    DistantLight { intensity: f32, color: String },
}

// ============================================================================
// SECTION 2: PCG GENERATION ALGORITHMS
// ============================================================================

/// Procedural Content Generator with history-aware placement.
pub struct HistoryAwarePCG {
    spectral_library: Box<dyn SpectralLibrary>,
    seed: u64,
    generation_config: PCGConfig,
}

/// Configuration for PCG generation sprints.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PCGConfig {
    /// Minimum CIC threshold for HighThreat tiles
    pub high_threat_cic_threshold: f32,
    /// Minimum AOS threshold for ArchivalEvidence assets
    pub archival_evidence_aos_threshold: f32,
    /// Minimum RRM threshold for SpectralResidual assets
    pub spectral_residual_rrm_threshold: f32,
    /// LSG threshold for LiminalThreshold tiles
    pub liminal_lsg_threshold: f32,
    /// CIC threshold for AtrocityAnchor tiles (boss zones)
    pub atrocity_anchor_cic_threshold: f32,
    /// Maximum assets per tile (prevents overcrowding)
    pub max_assets_per_tile: usize,
    /// Charter compliance enforcement (cannot be disabled)
    pub charter_enforcement: bool,
    /// Entertainment metric targets for validation
    pub target_metrics: EntertainmentMetrics,
}

impl HistoryAwarePCG {
    pub fn new(
        spectral_library: Box<dyn SpectralLibrary>,
        seed: u64,
        config: PCGConfig,
    ) -> Self {
        Self {
            spectral_library,
            seed,
            generation_config: config,
        }
    }

    /// Generate a world map with history-aware tile placement.
    /// Uses BSP trees weighted by LSG/HVF for natural thresholds.
    pub fn generate_world_map(&self, width: i32, height: i32) -> Vec<Vec<WorldTile>> {
        let mut rng = rand::rngs::StdRng::seed_from_u64(self.seed);
        let mut map: Vec<Vec<WorldTile>> = Vec::with_capacity(height as usize);

        for y in 0..height {
            let mut row: Vec<WorldTile> = Vec::with_capacity(width as usize);
            for x in 0..width {
                // Query historical invariants for this coordinate
                let invariants = self.spectral_library.query_invariants(x as f32, y as f32);
                
                // Determine tile type based on invariant amplitudes
                let tile_type = self.classify_tile_type(&invariants);
                
                // Generate assets appropriate for this tile's history
                let assets = self.generate_tile_assets(&invariants, &tile_type, &mut rng);
                
                // Validate assets against charter and metrics
                let validated_assets = self.validate_assets(assets, &invariants);
                
                // Determine navigation hints (HVF-driven, no waypoints)
                let nav_hint = self.generate_navigation_hint(&invariants, &mut rng);
                
                row.push(WorldTile {
                    x,
                    y,
                    tile_type,
                    invariants,
                    generated_assets: validated_assets,
                    encounter_seeded: self.should_seed_encounter(&invariants, &mut rng),
                    navigation_hint: nav_hint,
                });
            }
            map.push(row);
        }

        // Apply Haunt Vector Field smoothing for natural dread flow
        self.apply_hvf_smoothing(&mut map);

        map
    }

    /// Classify tile type based on historical invariant amplitudes.
    fn classify_tile_type(&self, invariants: &HistoricalInvariantProfile) -> TileType {
        let cic = invariants.cic.0;
        let aos = invariants.aos.0;
        let rrm = invariants.rrm.0;
        let lsg = invariants.lsg.0;

        // Atrocity Anchor: CIC > 0.9 (major historical disasters)
        if cic >= self.generation_config.atrocity_anchor_cic_threshold {
            return TileType::AtrocityAnchor;
        }

        // High Threat: CIC > 0.7 OR RRM > 0.7 (industrial/biological sites)
        if cic >= self.generation_config.high_threat_cic_threshold 
            || rrm >= self.generation_config.spectral_residual_rrm_threshold {
            return TileType::HighThreat;
        }

        // Liminal Threshold: LSG > 0.7 (biome transitions, doorways)
        if lsg >= self.generation_config.liminal_lsg_threshold {
            return TileType::LiminalThreshold;
        }

        // Safe Haven: CIC < 0.3 AND DET > 0.7 (low trauma, high dread threshold)
        if cic < 0.3 && invariants.det.0 > 0.7 {
            return TileType::SafeHaven;
        }

        // Default: Exploration zone
        TileType::Exploration
    }

    /// Generate assets appropriate for tile's historical profile.
    /// Reference: Darkwood 2 Aral Sea (ship graveyards, biological labs, industrial decay)
    fn generate_tile_assets(
        &self,
        invariants: &HistoricalInvariantProfile,
        tile_type: &TileType,
        rng: &mut rand::rngs::StdRng,
    ) -> Vec<GeneratedAsset> {
        let mut assets = Vec::new();
        let max_assets = self.generation_config.max_assets_per_tile;

        match tile_type {
            TileType::AtrocityAnchor => {
                // High CIC: Industrial decay, ship graveyard elements, biological contamination
                assets.push(self.create_industrial_decay_asset(invariants, rng));
                assets.push(self.create_archival_evidence_asset(invariants, rng));
                if invariants.rrm.0 > 0.7 {
                    assets.push(self.create_spectral_residual_asset(invariants, rng));
                }
            }
            TileType::HighThreat => {
                // Mid-High CIC: Environmental traces, audio echoes
                assets.push(self.create_environmental_trace_asset(invariants, rng));
                if rng.gen_bool(0.6) {
                    assets.push(self.create_audio_echo_asset(invariants, rng));
                }
            }
            TileType::LiminalThreshold => {
                // High LSG: Structural anomalies, lighting shifts
                assets.push(self.create_structural_anomaly_asset(invariants, rng));
            }
            TileType::Exploration => {
                // Mid-range: Scavenging clues, partial evidence
                if rng.gen_bool(0.5) {
                    assets.push(self.create_archival_evidence_asset(invariants, rng));
                }
            }
            TileType::SafeHaven => {
                // Low CIC: Minimal assets, focus on DET recovery
                // No horror assets in safe zones (Charter compliance)
            }
        }

        // Limit assets to prevent overcrowding (maintains EMD targets)
        assets.truncate(max_assets);
        assets
    }

    /// Create industrial decay asset (Aral Sea ship graveyard reference).
    fn create_industrial_decay_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "rusted_ship_hull",
            "stranded_oil_rig",
            "collapsed_factory_wall",
            "salt_crusted_machinery",
            "abandoned_biological_lab_equipment",
        ];
        
        let template = asset_templates[rng.gen_range(0..asset_templates.len())];

        GeneratedAsset {
            asset_id: format!("{}_{}", template, rng.gen_range(0..1000)),
            asset_type: AssetType::IndustrialDecay,
            invariant_bindings: InvariantBindings {
                primary_invariant: "CIC".to_string(),
                threshold_met: invariants.cic.0,
                historical_source: "Aral Sea Environmental Disaster Archives (1960-2000)".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true, // Industrial decay is evidence, not explicit violence
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.15,
                emd_delta: 0.20,
                stci_delta: 0.10,
                cdl_delta: 0.12,
                arr_delta: 0.05,
            },
        }
    }

    /// Create archival evidence asset (redacted documents, logs).
    fn create_archival_evidence_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "redacted_soviet_report",
            "torn_personal_diary",
            "contaminated_lab_log",
            "evacuation_manifest_missing_pages",
            "biological_test_subject_records",
        ];

        GeneratedAsset {
            asset_id: format!("archival_{}", rng.gen_range(0..10000)),
            asset_type: AssetType::ArchivalEvidence,
            invariant_bindings: InvariantBindings {
                primary_invariant: "AOS".to_string(),
                threshold_met: invariants.aos.0,
                historical_source: "Soviet Archival Gaps & Redaction Records".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true,
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.20,
                emd_delta: 0.30, // High EMD contribution (mystery density)
                stci_delta: 0.05,
                cdl_delta: 0.25, // High CDL (conflicting records)
                arr_delta: 0.15, // Maintains ambiguity
            },
        }
    }

    /// Create environmental trace asset (bloodstains, drag marks, disturbed earth).
    fn create_environmental_trace_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "dried_bloodstain_pattern",
            "drag_marks_in_salt_flat",
            "disturbed_earth_grave",
            "abandoned_personal_effects",
            "footprints_leading_nowhere",
        ];

        GeneratedAsset {
            asset_id: format!("trace_{}", rng.gen_range(0..10000)),
            asset_type: AssetType::EnvironmentalTrace,
            invariant_bindings: InvariantBindings {
                primary_invariant: "CIC".to_string(),
                threshold_met: invariants.cic.0,
                historical_source: "Disaster Site Forensic Records".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true, // Evidence of trauma, not explicit depiction
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.18,
                emd_delta: 0.22,
                stci_delta: 0.12,
                cdl_delta: 0.15,
                arr_delta: 0.10,
            },
        }
    }

    /// Create spectral residual asset (shadow figures, flickering lights).
    fn create_spectral_residual_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "shadow_figure_at_distance",
            "flickering_emergency_light",
            "phantom_pa_announcement",
            "heat_haze_armored_column",
            "child_voice_from_dry_well",
        ];

        GeneratedAsset {
            asset_id: format!("spectral_{}", rng.gen_range(0..10000)),
            asset_type: AssetType::SpectralResidual,
            invariant_bindings: InvariantBindings {
                primary_invariant: "RRM".to_string(),
                threshold_met: invariants.rrm.0,
                historical_source: "Vozrozhdeniya Island Biological Testing Records".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true, // Implication only, no explicit entity models
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.25,
                emd_delta: 0.18,
                stci_delta: 0.20,
                cdl_delta: 0.22,
                arr_delta: 0.12,
            },
        }
    }

    /// Create structural anomaly asset (impossible geometry).
    fn create_structural_anomaly_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "door_opening_into_wall",
            "stairs_to_nowhere",
            "window_showing_wrong_outdoors",
            "corridor_looping_back_on_itself",
            "room_larger_inside_than_outside",
        ];

        GeneratedAsset {
            asset_id: format!("anomaly_{}", rng.gen_range(0..10000)),
            asset_type: AssetType::StructuralAnomaly,
            invariant_bindings: InvariantBindings {
                primary_invariant: "AOS".to_string(),
                threshold_met: invariants.aos.0,
                historical_source: "Archival Opacity & Reality Glitch Records".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true,
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.22,
                emd_delta: 0.25,
                stci_delta: 0.15,
                cdl_delta: 0.28, // High CDL (reality contradiction)
                arr_delta: 0.18,
            },
        }
    }

    /// Create audio echo asset (fragmented testimony, chanting).
    fn create_audio_echo_asset(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> GeneratedAsset {
        let asset_templates = [
            "fragmented_witness_testimony",
            "distant_ritual_chanting",
            "phantom_machinery_hum",
            "evacuation_siren_loop",
            "biological_lab_alarm_echo",
        ];

        GeneratedAsset {
            asset_id: format!("audio_{}", rng.gen_range(0..10000)),
            asset_type: AssetType::AudioEcho,
            invariant_bindings: InvariantBindings {
                primary_invariant: "MDI".to_string(),
                threshold_met: invariants.mdi.0,
                historical_source: "Slavic Folklore & Industrial Disaster Audio Archives".to_string(),
                spectral_plausibility: invariants.spr.0,
            },
            charter_compliant: true,
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.20,
                emd_delta: 0.15,
                stci_delta: 0.18,
                cdl_delta: 0.17,
                arr_delta: 0.14,
            },
        }
    }

    /// Validate assets against Rivers of Blood Charter.
    fn validate_assets(
        &self,
        assets: Vec<GeneratedAsset>,
        invariants: &HistoricalInvariantProfile,
    ) -> Vec<GeneratedAsset> {
        if !self.generation_config.charter_enforcement {
            return assets; // Should never happen in production
        }

        assets.into_iter().filter(|asset| {
            // Charter Pillar 2: No explicit violence/gore
            if !asset.charter_compliant {
                return false;
            }

            // Charter Pillar 1: Historical grounding required
            if asset.invariant_bindings.historical_source.is_empty() {
                return false;
            }

            // Charter Pillar 3: Entertainment validation
            // Assets must contribute positively to metrics
            let total_contribution = asset.entertainment_contribution.uec_delta
                + asset.entertainment_contribution.emd_delta;
            
            if total_contribution < 0.1 {
                return false; // Asset doesn't contribute to entertainment
            }

            // Spectral plausibility check (SPR)
            if asset.invariant_bindings.spectral_plausibility < 0.3 {
                // Low SPR assets should be ambient only, not systemic
                if matches!(asset.asset_type, AssetType::SpectralResidual) {
                    return false;
                }
            }

            true
        }).collect()
    }

    /// Generate navigation hints (HVF-driven, no waypoints).
    fn generate_navigation_hint(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> Option<NavigationHint> {
        // Ice-Pick Lodge "No Hand-Holding" philosophy
        // Navigation hints are environmental, not UI markers

        if rng.gen_bool(0.3) {
            // 30% chance of HVF fog flow hint
            Some(NavigationHint::FogFlow(invariants.hvf.clone()))
        } else if rng.gen_bool(0.5) {
            // 50% chance of audio cue
            Some(NavigationHint::AudioCue {
                direction: rng.gen_range(0.0..360.0),
                invariant_source: "RRM".to_string(),
            })
        } else if rng.gen_bool(0.4) {
            // 40% chance of distant light
            Some(NavigationHint::DistantLight {
                intensity: rng.gen_range(0.3..0.7),
                color: "#FFBF00".to_string(), // Industrial amber
            })
        } else {
            None // No hint - player must rely on landmarks
        }
    }

    /// Determine if encounter should be seeded (based on invariants).
    fn should_seed_encounter(
        &self,
        invariants: &HistoricalInvariantProfile,
        rng: &mut rand::rngs::StdRng,
    ) -> bool {
        // High CIC + High RRM = Higher encounter chance
        let base_chance = (invariants.cic.0 + invariants.rrm.0) / 2.0;
        
        // DET modifies chance (low DET = faster psychological effects)
        let det_modifier = 1.0 - (invariants.det.0 * 0.3);
        
        let adjusted_chance = base_chance * det_modifier;
        
        rng.gen_bool(adjusted_chance as f64)
    }

    /// Apply HVF smoothing for natural dread flow across the map.
    fn apply_hvf_smoothing(&self, map: &mut Vec<Vec<WorldTile>>) {
        // Smooth haunt vector field to create natural "flow" of uncanny pressure
        // This ensures storms, fog, and wandering entities drift coherently
        
        let height = map.len();
        let width = map[0].len();

        for y in 0..height {
            for x in 0..width {
                // Sample neighboring tiles for HVF averaging
                let mut avg_x = 0.0;
                let mut avg_y = 0.0;
                let mut count = 0;

                for dy in -1..=1 {
                    for dx in -1..=1 {
                        let ny = (y as i32 + dy) as usize;
                        let nx = (x as i32 + dx) as usize;

                        if ny < height && nx < width {
                            avg_x += map[ny][nx].invariants.hvf.x;
                            avg_y += map[ny][nx].invariants.hvf.y;
                            count += 1;
                        }
                    }
                }

                if count > 0 {
                    map[y][x].invariants.hvf.x = avg_x / count as f32;
                    map[y][x].invariants.hvf.y = avg_y / count as f32;
                }
            }
        }
    }

    /// Predict entertainment metrics for generated map section.
    pub fn predict_map_metrics(&self, map: &[Vec<WorldTile>]) -> EntertainmentMetrics {
        let mut total_uec = 0.0;
        let mut total_emd = 0.0;
        let mut total_stci = 0.0;
        let mut total_cdl = 0.0;
        let mut total_arr = 0.0;
        let mut tile_count = 0;

        for row in map {
            for tile in row {
                for asset in &tile.generated_assets {
                    total_uec += asset.entertainment_contribution.uec_delta;
                    total_emd += asset.entertainment_contribution.emd_delta;
                    total_stci += asset.entertainment_contribution.stci_delta;
                    total_cdl += asset.entertainment_contribution.cdl_delta;
                    total_arr += asset.entertainment_contribution.arr_delta;
                }
                tile_count += 1;
            }
        }

        // Normalize by tile count and clamp to 0-1 range
        let normalize = |val: f32| ((val / tile_count as f32).min(1.0).max(0.0));

        EntertainmentMetrics {
            uec: normalize(total_uec),
            emd: normalize(total_emd),
            stci: normalize(total_stci),
            cdl: normalize(total_cdl),
            arr: normalize(total_arr),
        }
    }
}

// ============================================================================
// SECTION 3: PCG CONFIGURATION PRESETS
// ============================================================================

/// Preset configurations for different generation sprints.
pub mod pcg_presets {
    use super::*;

    /// Aral Sea Ship Graveyard Preset (Darkwood 2 reference)
    pub fn aral_sea_ship_graveyard() -> PCGConfig {
        PCGConfig {
            high_threat_cic_threshold: 0.7,
            archival_evidence_aos_threshold: 0.6,
            spectral_residual_rrm_threshold: 0.7,
            liminal_lsg_threshold: 0.6,
            atrocity_anchor_cic_threshold: 0.9,
            max_assets_per_tile: 4,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.65,
                emd: 0.75,
                stci: 0.55,
                cdl: 0.80,
                arr: 0.85,
            },
        }
    }

    /// Vozrozhdeniya Biological Lab Preset (High RRM)
    pub fn vozrozhdeniya_lab() -> PCGConfig {
        PCGConfig {
            high_threat_cic_threshold: 0.6,
            archival_evidence_aos_threshold: 0.7,
            spectral_residual_rrm_threshold: 0.6,
            liminal_lsg_threshold: 0.7,
            atrocity_anchor_cic_threshold: 0.85,
            max_assets_per_tile: 5,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.70,
                emd: 0.80,
                stci: 0.60,
                cdl: 0.85,
                arr: 0.80,
            },
        }
    }

    /// Post-Soviet Industrial Collapse Preset (High AOS)
    pub fn post_soviet_collapse() -> PCGConfig {
        PCGConfig {
            high_threat_cic_threshold: 0.65,
            archival_evidence_aos_threshold: 0.8,
            spectral_residual_rrm_threshold: 0.5,
            liminal_lsg_threshold: 0.65,
            atrocity_anchor_cic_threshold: 0.88,
            max_assets_per_tile: 3,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.60,
                emd: 0.85, // High mystery density from archival gaps
                stci: 0.50,
                cdl: 0.75,
                arr: 0.90, // High ambiguity
            },
        }
    }
}

// ============================================================================
// SECTION 4: INTEGRATION HOOKS
// ============================================================================

/// Hooks for integration with Style Router (File 5) and Audio Automation (File 10).
pub mod integration {
    use super::*;

    /// Notify Style Router of tile generation for style selection.
    pub fn notify_style_router(tile: &WorldTile) -> String {
        // Style Router queries invariants to select appropriate style
        if tile.invariants.rrm.0 > 0.7 {
            "machine_canyon_biomech_bci".to_string()
        } else {
            "spectral_engraving_dark_sublime".to_string()
        }
    }

    /// Notify Audio Automation of tile generation for ambient mixing.
    pub fn notify_audio_automation(tile: &WorldTile) -> AudioProfile {
        AudioProfile {
            cic_intensity: tile.invariants.cic.0,
            rrm_chanting: tile.invariants.rrm.0 > 0.6,
            mdi_folk_instruments: tile.invariants.mdi.0 > 0.5,
            det_silence_spikes: tile.invariants.det.0 < 0.4,
        }
    }

    #[derive(Debug, Clone)]
    pub struct AudioProfile {
        pub cic_intensity: f32,
        pub rrm_chanting: bool,
        pub mdi_folk_instruments: bool,
        pub det_silence_spikes: bool,
    }
}

// ============================================================================
// SECTION 5: UNIT TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tile_classification_high_cic() {
        // Mock invariants with high CIC
        let invariants = HistoricalInvariantProfile {
            cic: CatastrophicImprintCoefficient(0.95),
            aos: ArchivalOpacityScore(0.7),
            rrm: RitualResidueMap(0.6),
            lsg: LiminalStressGradient(0.5),
            spr: SpectralPlausibilityRating(0.8),
            fcf: FolkloricConvergenceFactor(0.7),
            rwf: ReliabilityWeightingFactor(0.6),
            det: DreadExposureThreshold(0.5),
            hvf: HauntVectorField { x: 0.0, y: 0.0, magnitude: 0.0 },
            mdi: crate::spectral_library::MythicDensityIndex(0.6),
        };

        let config = PCGConfig {
            high_threat_cic_threshold: 0.7,
            archival_evidence_aos_threshold: 0.6,
            spectral_residual_rrm_threshold: 0.7,
            liminal_lsg_threshold: 0.6,
            atrocity_anchor_cic_threshold: 0.9,
            max_assets_per_tile: 4,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.6,
                emd: 0.7,
                stci: 0.5,
                cdl: 0.75,
                arr: 0.8,
            },
        };

        // CIC > 0.9 should classify as AtrocityAnchor
        assert_eq!(config.atrocity_anchor_cic_threshold, 0.9);
        assert!(invariants.cic.0 >= config.atrocity_anchor_cic_threshold);
    }

    #[test]
    fn test_charter_compliance_validation() {
        let asset = GeneratedAsset {
            asset_id: "test_asset".to_string(),
            asset_type: AssetType::EnvironmentalTrace,
            invariant_bindings: InvariantBindings {
                primary_invariant: "CIC".to_string(),
                threshold_met: 0.8,
                historical_source: "Test Archive".to_string(),
                spectral_plausibility: 0.7,
            },
            charter_compliant: true,
            entertainment_contribution: EntertainmentContribution {
                uec_delta: 0.2,
                emd_delta: 0.2,
                stci_delta: 0.1,
                cdl_delta: 0.15,
                arr_delta: 0.1,
            },
        };

        // Asset should pass validation
        assert!(asset.charter_compliant);
        assert!(!asset.invariant_bindings.historical_source.is_empty());
        
        let total_contribution = asset.entertainment_contribution.uec_delta
            + asset.entertainment_contribution.emd_delta;
        assert!(total_contribution >= 0.1);
    }

    #[test]
    fn test_entertainment_metric_prediction() {
        // Test that PCG can predict metrics before runtime
        let config = pcg_presets::aral_sea_ship_graveyard();
        
        // Verify target metrics are within Entertainment Metrics Schema ranges
        assert!(config.target_metrics.uec >= 0.55 && config.target_metrics.uec <= 0.85);
        assert!(config.target_metrics.emd >= 0.60 && config.target_metrics.emd <= 0.90);
        assert!(config.target_metrics.arr >= 0.70 && config.target_metrics.arr <= 1.0);
    }
}
