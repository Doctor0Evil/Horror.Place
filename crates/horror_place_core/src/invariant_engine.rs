//! Horror$Place Invariant Engine
//! Version: 3.11A
//! Doctrine: Rivers of Blood Charter
//! 
//! This module provides the foundational invariant system for history-aware horror.
//! All invariants are machine-checkable with hex-safe identifiers for AI-Chat integration.

#![warn(missing_docs)]
#![allow(dead_code)]

use std::collections::HashMap;
use std::fmt;
use serde::{Deserialize, Serialize};

/// Hex-safe identifier type for all invariants
/// Ensures machine-checkable keys across all systems
pub type InvariantId = u32;

/// Core horror invariant values (0.0 - 1.0 normalized)
pub type InvariantValue = f32;

/// Region identifier for geo-historical database queries
pub type RegionId = String;

/// ============================================================================
/// INVARIANT DEFINITIONS (Hex-Safe Identifiers)
/// ============================================================================

/// Layer 1: History-Aware Horror World Model Invariants
pub const CIC: InvariantId = 0xCIC; // Catastrophic Imprint Coefficient
pub const MDI: InvariantId = 0xMDI; // Mythic Density Index
pub const AOS: InvariantId = 0xAOS; // Archival Opacity Score
pub const RRM: InvariantId = 0xRRM; // Ritual Residue Map
pub const FCF: InvariantId = 0xFCF; // Folkloric Convergence Factor
pub const SPR: InvariantId = 0xSPR; // Spectral Plausibility Rating
pub const RWF: InvariantId = 0xRWF; // Reliability Weighting Factor
pub const DET: InvariantId = 0xDET; // Dread Exposure Threshold
pub const HVF: InvariantId = 0xHVF; // Haunt Vector Field
pub const LSG: InvariantId = 0xLSG; // Liminal Stress Gradient

/// Layer 2: Spectral Presence Invariants
pub const SHCI: InvariantId = 0xSHCI; // Spectral-History Coupling Index

/// Layer 3: Entertainment Factor Invariants
pub const UEC: InvariantId = 0xUEC; // Uncertainty Engagement Coefficient
pub const EMD: InvariantId = 0xEMD; // Evidential Mystery Density
pub const STCI: InvariantId = 0xSTCI; // Safe-Threat Contrast Index
pub const CDL: InvariantId = 0xCDL; // Cognitive Dissonance Load
pub const ARR: InvariantId = 0xARR; // Ambiguous Resolution Ratio

/// ============================================================================
/// DATA STRUCTURES
/// ============================================================================

/// Complete invariant set for a single region/tile
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RegionInvariants {
    pub region_id: RegionId,
    pub history_layer: HistoryLayer,
    pub spectral_layer: SpectralLayer,
    pub entertainment_layer: EntertainmentLayer,
    pub metadata: RegionMetadata,
}

/// Layer 1: History-Aware Horror World Model
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryLayer {
    pub cic: InvariantValue, // Catastrophic Imprint Coefficient
    pub mdi: InvariantValue, // Mythic Density Index
    pub aos: InvariantValue, // Archival Opacity Score
    pub rrm: InvariantValue, // Ritual Residue Map
    pub fcf: InvariantValue, // Folkloric Convergence Factor
    pub spr: InvariantValue, // Spectral Plausibility Rating (derived)
    pub rwf: InvariantValue, // Reliability Weighting Factor
    pub det: InvariantValue, // Dread Exposure Threshold
    pub hvf: HauntVector,    // Haunt Vector Field
    pub lsg: InvariantValue, // Liminal Stress Gradient
}

/// Haunt Vector Field with directional components
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HauntVector {
    pub magnitude: InvariantValue,
    pub direction_x: f32,
    pub direction_y: f32,
    pub pressure_gradient: InvariantValue,
}

/// Layer 2: Spectral Presence
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpectralLayer {
    pub shci: InvariantValue, // Spectral-History Coupling Index
    pub manifestation_type: ManifestationType,
    pub activation_threshold: InvariantValue,
}

/// Type of spectral manifestation based on history coupling
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ManifestationType {
    AudioEcho,      // Low SHCI - audio only
    VisualGlitch,   // Mid SHCI - partial visibility
    FullEntity,     // High SHCI - complete spectral presence
    Environmental,  // History-encoded environmental changes
}

/// Layer 3: Entertainment Metrics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EntertainmentLayer {
    pub uec: InvariantValue, // Uncertainty Engagement Coefficient
    pub emd: InvariantValue, // Evidential Mystery Density
    pub stci: InvariantValue, // Safe-Threat Contrast Index
    pub cdl: InvariantValue, // Cognitive Dissonance Load
    pub arr: InvariantValue, // Ambiguous Resolution Ratio
}

/// Additional metadata for region tracking
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RegionMetadata {
    pub last_updated: u64,
    pub validation_status: ValidationStatus,
    pub rivers_of_blood_compliant: bool,
    pub doctrine_version: String,
}

/// Validation status for invariant integrity checks
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ValidationStatus {
    Valid,
    Warning,
    Invalid,
    PendingReview,
}

/// ============================================================================
/// INVARIANT ENGINE CORE
/// ============================================================================

/// Main engine for managing and validating horror invariants
pub struct InvariantEngine {
    regions: HashMap<RegionId, RegionInvariants>,
    validation_rules: Vec<ValidationRule>,
    doctrine_version: String,
}

/// Validation rule for invariant constraints
pub struct ValidationRule {
    pub name: String,
    pub validator: Box<dyn Fn(&RegionInvariants) -> ValidationResult + Send + Sync>,
}

/// Result of invariant validation
#[derive(Debug, Clone)]
pub struct ValidationResult {
    pub passed: bool,
    pub message: String,
    pub severity: ValidationSeverity,
}

#[derive(Debug, Clone, PartialEq)]
pub enum ValidationSeverity {
    Info,
    Warning,
    Error,
    Critical,
}

impl InvariantEngine {
    /// Create new invariant engine with Rivers of Blood Charter defaults
    pub fn new() -> Self {
        let mut engine = InvariantEngine {
            regions: HashMap::new(),
            validation_rules: Vec::new(),
            doctrine_version: "3.11A".to_string(),
        };
        engine.initialize_default_rules();
        engine
    }

    /// Initialize validation rules from Rivers of Blood Charter
    fn initialize_default_rules(&mut self) {
        // Rule 1: CIC must be high for blood river regions
        self.add_rule(ValidationRule {
            name: "rivers_of_blood_cic_threshold".to_string(),
            validator: Box::new(|region: &RegionInvariants| {
                if region.metadata.rivers_of_blood_compliant {
                    if region.history_layer.cic >= 0.85 {
                        ValidationResult {
                            passed: true,
                            message: "CIC threshold met for Rivers of Blood region".to_string(),
                            severity: ValidationSeverity::Info,
                        }
                    } else {
                        ValidationResult {
                            passed: false,
                            message: format!(
                                "CIC {} below required 0.85 for Rivers of Blood compliance",
                                region.history_layer.cic
                            ),
                            severity: ValidationSeverity::Error,
                        }
                    }
                } else {
                    ValidationResult {
                        passed: true,
                        message: "Non-Rivers region, CIC check skipped".to_string(),
                        severity: ValidationSeverity::Info,
                    }
                }
            }),
        });

        // Rule 2: SHCI must correlate with CIC for deterministic manifestations
        self.add_rule(ValidationRule {
            name: "shci_cic_correlation".to_string(),
            validator: Box::new(|region: &RegionInvariants| {
                let cic = region.history_layer.cic;
                let shci = region.spectral_layer.shci;
                let correlation = (cic - shci).abs();
                
                if correlation <= 0.15 {
                    ValidationResult {
                        passed: true,
                        message: "SHCI-CIC correlation within acceptable bounds".to_string(),
                        severity: ValidationSeverity::Info,
                    }
                } else {
                    ValidationResult {
                        passed: false,
                        message: format!(
                            "SHCI-CIC correlation deviation: {:.2} (max: 0.15)",
                            correlation
                        ),
                        severity: ValidationSeverity::Warning,
                    }
                }
            }),
        });

        // Rule 3: Entertainment metrics must maintain player engagement balance
        self.add_rule(ValidationRule {
            name: "entertainment_balance".to_string(),
            validator: Box::new(|region: &RegionInvariants| {
                let uec = region.entertainment_layer.uec;
                let arr = region.entertainment_layer.arr;
                let cdl = region.entertainment_layer.cdl;
                
                // UEC should be moderate-high for engaging uncertainty
                let uec_valid = uec >= 0.5 && uec <= 0.9;
                // ARR should be high to maintain mystery
                let arr_valid = arr >= 0.6;
                // CDL should support multiple explanations
                let cdl_valid = cdl >= 0.5;
                
                if uec_valid && arr_valid && cdl_valid {
                    ValidationResult {
                        passed: true,
                        message: "Entertainment metrics balanced for engaging horror".to_string(),
                        severity: ValidationSeverity::Info,
                    }
                } else {
                    let mut issues = Vec::new();
                    if !uec_valid { issues.push("UEC out of range"); }
                    if !arr_valid { issues.push("ARR too low"); }
                    if !cdl_valid { issues.push("CDL insufficient"); }
                    
                    ValidationResult {
                        passed: false,
                        message: format!("Entertainment balance issues: {}", issues.join(", ")),
                        severity: ValidationSeverity::Warning,
                    }
                }
            }),
        });

        // Rule 4: DET must scale with CIC for psychological safety
        self.add_rule(ValidationRule {
            name: "det_cic_safety_scaling".to_string(),
            validator: Box::new(|region: &RegionInvariants| {
                let cic = region.history_layer.cic;
                let det = region.history_layer.det;
                
                // Higher CIC should generally mean lower DET (more dangerous)
                let expected_det = 1.0 - (cic * 0.7);
                let deviation = (det - expected_det).abs();
                
                if deviation <= 0.2 {
                    ValidationResult {
                        passed: true,
                        message: "DET appropriately scaled to CIC".to_string(),
                        severity: ValidationSeverity::Info,
                    }
                } else {
                    ValidationResult {
                        passed: false,
                        message: format!(
                            "DET deviation from CIC expectation: {:.2}",
                            deviation
                        ),
                        severity: ValidationSeverity::Warning,
                    }
                }
            }),
        });
    }

    /// Add a validation rule to the engine
    pub fn add_rule(&mut self, rule: ValidationRule) {
        self.validation_rules.push(rule);
    }

    /// Register a region with its invariants
    pub fn register_region(&mut self, region: RegionInvariants) -> Result<(), String> {
        // Validate before registration
        let validation = self.validate_region(&region);
        if !validation.iter().all(|v| v.passed) {
            let errors: Vec<&ValidationResult> = validation.iter().filter(|v| !v.passed).collect();
            return Err(format!(
                "Region validation failed: {}",
                errors.iter().map(|e| &e.message).collect::<Vec<_>>().join("; ")
            ));
        }
        
        self.regions.insert(region.region_id.clone(), region);
        Ok(())
    }

    /// Validate a region against all rules
    pub fn validate_region(&self, region: &RegionInvariants) -> Vec<ValidationResult> {
        self.validation_rules
            .iter()
            .map(|rule| (rule.validator)(region))
            .collect()
    }

    /// Query invariant value for a region
    pub fn get_invariant(&self, region_id: &str, invariant_id: InvariantId) -> Option<InvariantValue> {
        self.regions.get(region_id).map(|region| {
            match invariant_id {
                CIC => region.history_layer.cic,
                MDI => region.history_layer.mdi,
                AOS => region.history_layer.aos,
                RRM => region.history_layer.rrm,
                FCF => region.history_layer.fcf,
                SPR => region.history_layer.spr,
                RWF => region.history_layer.rwf,
                DET => region.history_layer.det,
                LSG => region.history_layer.lsg,
                SHCI => region.spectral_layer.shci,
                UEC => region.entertainment_layer.uec,
                EMD => region.entertainment_layer.emd,
                STCI => region.entertainment_layer.stci,
                CDL => region.entertainment_layer.cdl,
                ARR => region.entertainment_layer.arr,
                _ => 0.0,
            }
        })
    }

    /// Calculate derived SPR from CIC, MDI, and AOS
    pub fn calculate_spr(cic: InvariantValue, mdi: InvariantValue, aos: InvariantValue) -> InvariantValue {
        // SPR formula: weighted combination of history invariants
        // CIC has highest weight (actual catastrophe), then AOS (mystery), then MDI (rumors)
        (cic * 0.5) + (aos * 0.3) + (mdi * 0.2)
    }

    /// Calculate Haunt Vector Field from neighboring regions
    pub fn calculate_hvf(
        &self,
        region_id: &str,
        neighbors: Vec<&str>
    ) -> Option<HauntVector> {
        let region = self.regions.get(region_id)?;
        
        let mut total_pressure = region.history_layer.cic;
        let mut direction_x = 0.0f32;
        let mut direction_y = 0.0f32;
        
        for (i, neighbor_id) in neighbors.iter().enumerate() {
            if let Some(neighbor) = self.regions.get(*neighbor_id) {
                let pressure = neighbor.history_layer.cic;
                total_pressure += pressure;
                
                // Simple directional calculation based on neighbor index
                let angle = (i as f32) * (std::f32::consts::PI * 2.0 / neighbors.len() as f32);
                direction_x += pressure * angle.cos();
                direction_y += pressure * angle.sin();
            }
        }
        
        let magnitude = total_pressure / (neighbors.len() as f32 + 1.0);
        let pressure_gradient = region.history_layer.lsg * magnitude;
        
        Some(HauntVector {
            magnitude,
            direction_x,
            direction_y,
            pressure_gradient,
        })
    }

    /// Determine manifestation type based on SHCI
    pub fn get_manifestation_type(shci: InvariantValue) -> ManifestationType {
        match shci {
            v if v < 0.4 => ManifestationType::AudioEcho,
            v if v < 0.6 => ManifestationType::VisualGlitch,
            v if v < 0.8 => ManifestationType::Environmental,
            _ => ManifestationType::FullEntity,
        }
    }

    /// Export region data for Lua engine integration
    pub fn export_to_lua_table(&self, region_id: &str) -> Option<String> {
        let region = self.regions.get(region_id)?;
        
        Some(format!(
            r#"{{
    region_id = "{region_id}",
    history = {{
        CIC = {cic},
        MDI = {mdi},
        AOS = {aos},
        RRM = {rrm},
        FCF = {fcf},
        SPR = {spr},
        RWF = {rwf},
        DET = {det},
        LSG = {lsg},
        HVF = {{ magnitude = {hvf_mag}, dir_x = {hvf_x}, dir_y = {hvf_y} }}
    }},
    spectral = {{
        SHCI = {shci},
        manifestation = "{manifestation}",
        activation_threshold = {activation}
    }},
    entertainment = {{
        UEC = {uec},
        EMD = {emd},
        STCI = {stci},
        CDL = {cdl},
        ARR = {arr}
    }}
}}"#,
            region_id = region.region_id,
            cic = region.history_layer.cic,
            mdi = region.history_layer.mdi,
            aos = region.history_layer.aos,
            rrm = region.history_layer.rrm,
            fcf = region.history_layer.fcf,
            spr = region.history_layer.spr,
            rwf = region.history_layer.rwf,
            det = region.history_layer.det,
            lsg = region.history_layer.lsg,
            hvf_mag = region.history_layer.hvf.magnitude,
            hvf_x = region.history_layer.hvf.direction_x,
            hvf_y = region.history_layer.hvf.direction_y,
            shci = region.spectral_layer.shci,
            manifestation = format!("{:?}", region.spectral_layer.manifestation_type),
            activation = region.spectral_layer.activation_threshold,
            uec = region.entertainment_layer.uec,
            emd = region.entertainment_layer.emd,
            stci = region.entertainment_layer.stci,
            cdl = region.entertainment_layer.cdl,
            arr = region.entertainment_layer.arr,
        ))
    }

    /// Get all registered regions
    pub fn get_all_regions(&self) -> Vec<&RegionInvariants> {
        self.regions.values().collect()
    }

    /// Get doctrine version
    pub fn get_doctrine_version(&self) -> &str {
        &self.doctrine_version
    }
}

impl Default for InvariantEngine {
    fn default() -> Self {
        Self::new()
    }
}

impl fmt::Display for InvariantEngine {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        writeln!(f, "Horror$Place Invariant Engine v{}", self.doctrine_version)?;
        writeln!(f, "Registered Regions: {}", self.regions.len())?;
        writeln!(f, "Validation Rules: {}", self.validation_rules.len())?;
        Ok(())
    }
}

/// ============================================================================
/// RIVERS OF BLOOD CHARTER SPECIFIC IMPLEMENTATIONS
/// ============================================================================

/// Create a Rivers of Blood compliant region (Eidoville Valley template)
pub fn create_rivers_of_blood_region(region_id: &str) -> RegionInvariants {
    let cic = 0.91;
    let mdi = 0.72;
    let aos = 0.84;
    let rrm = 0.78;
    let fcf = 0.81;
    let spr = InvariantEngine::calculate_spr(cic, mdi, aos);
    let rwf = 0.68;
    let det = 0.65;
    let lsg = 0.88;
    
    RegionInvariants {
        region_id: region_id.to_string(),
        history_layer: HistoryLayer {
            cic,
            mdi,
            aos,
            rrm,
            fcf,
            spr,
            rwf,
            det,
            hvf: HauntVector {
                magnitude: 0.85,
                direction_x: 0.6,
                direction_y: -0.4,
                pressure_gradient: lsg * 0.85,
            },
            lsg,
        },
        spectral_layer: SpectralLayer {
            shci: 0.93,
            manifestation_type: ManifestationType::FullEntity,
            activation_threshold: 0.75,
        },
        entertainment_layer: EntertainmentLayer {
            uec: 0.78,
            emd: 0.71,
            stci: 0.65,
            cdl: 0.81,
            arr: 0.74,
        },
        metadata: RegionMetadata {
            last_updated: 0, // Will be set on registration
            validation_status: ValidationStatus::PendingReview,
            rivers_of_blood_compliant: true,
            doctrine_version: "3.11A".to_string(),
        },
    }
}

/// ============================================================================
/// UNIT TESTS
/// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rivers_of_blood_region_creation() {
        let region = create_rivers_of_blood_region("eidoville_valley");
        assert!(region.metadata.rivers_of_blood_compliant);
        assert!(region.history_layer.cic >= 0.85);
        assert!(region.spectral_layer.shci >= 0.9);
    }

    #[test]
    fn test_spr_calculation() {
        let spr = InvariantEngine::calculate_spr(0.9, 0.5, 0.8);
        assert!(spr > 0.5);
        assert!(spr <= 1.0);
    }

    #[test]
    fn test_manifestation_type_thresholds() {
        assert_eq!(InvariantEngine::get_manifestation_type(0.3), ManifestationType::AudioEcho);
        assert_eq!(InvariantEngine::get_manifestation_type(0.5), ManifestationType::VisualGlitch);
        assert_eq!(InvariantEngine::get_manifestation_type(0.7), ManifestationType::Environmental);
        assert_eq!(InvariantEngine::get_manifestation_type(0.9), ManifestationType::FullEntity);
    }

    #[test]
    fn test_engine_validation() {
        let mut engine = InvariantEngine::new();
        let region = create_rivers_of_blood_region("test_region");
        assert!(engine.register_region(region).is_ok());
    }
}
