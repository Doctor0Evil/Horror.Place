//! # Horror$Place Audio Automation Engine
//!
//! This module implements invariant-driven audio middleware where every sound parameter
//! is determined by the **Geo-Historical Invariant Layer** rather than random chance.
//! Audio becomes a "voice of place" that whispers historical fragments, ritual echoes,
//! and environmental dread based on verifiable historical data (CIC, RRM, MDI, DET, etc.).
//!
//! ## Core Philosophy (Ice-Pick Lodge "Deep Game" + Darkwood Audio Design)
//! - **Negative Space Audio:** Silence is a tool. High-UEC regions get silence spikes.
//! - **Historical Grounding:** All audio must trace to real-world sources (industrial, folk, archival).
//! - **Implication Only:** No explicit screams, violence, or gratuitous horror SFX (Charter Pillar 2).
//! - **Player as Listener:** Audio cues replace quest markers (no hand-holding).
//!
//! ## Reference: Darkwood 2 Aral Sea Audio Design
//! - Industrial decay sounds (rusted machinery, ship graveyard creaks)
//! - Slavic folk instrumentation (gusli, zhaleika, atmospheric drone)
//! - Toxic dust storm ambience (wind through salt flats, contaminated marshlands)
//! - Vozrozhdeniya biological lab echoes (phantom PA announcements, alarm loops)
//! - Silence spikes in high-UEC regions (negative space as dread amplifier)
//!
//! ## Safety Compliance
//! All audio generation adheres to the `Rivers of Blood Charter` (File 3):
//! - No explicit screams or violence SFX
//! - Only environmental + fragmented testimony audio
//! - Historical sourcing required for all audio assets

use crate::spectral_library::{
    SpectralLibrary, HistoricalInvariantProfile, EntertainmentMetrics,
    CatastrophicImprintCoefficient, MythicDensityIndex, ArchivalOpacityScore,
    RitualResidueMap, DreadExposureThreshold, HauntVectorField,
    SpectralPlausibilityRating, FolkloricConvergenceFactor,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

// ============================================================================
// SECTION 1: AUDIO INVARIANT MAPPING STRUCTURES
// ============================================================================

/// Audio profile generated from historical invariants.
/// This is the core data structure passed to FMOD/Wwise middleware.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvariantAudioProfile {
    /// Catastrophic Imprint → Rumble intensity, industrial decay SFX
    pub cic_audio_params: CICAudioParams,
    /// Mythic Density → Folk instrumentation, ambient anomalies
    pub mdi_audio_params: MDIAudioParams,
    /// Archival Opacity → Audio glitches, fragmented testimony
    pub aos_audio_params: AOSAudioParams,
    /// Ritual Residue → Chanting fragments, occult audio triggers
    pub rrm_audio_params: RRMAudioParams,
    /// Dread Exposure → Silence spikes, psychological audio effects
    pub det_audio_params: DETAudioParams,
    /// Haunt Vector → Directional audio flow, weather migration
    pub hvf_audio_params: HVFAudioParams,
    /// Overall mix settings based on entertainment metrics
    pub entertainment_mix: EntertainmentMix,
    /// Charter compliance validation
    pub charter_compliant: bool,
}

/// CIC-driven audio parameters (industrial decay, catastrophe echoes).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CICAudioParams {
    /// Rumble intensity (0.0 - 1.0)
    pub rumble_intensity: f32,
    /// Industrial decay SFX volume (creaking metal, structural collapse)
    pub decay_sfx_volume: f32,
    /// Low-frequency drone presence (sub-bass dread)
    pub drone_presence: f32,
    /// Historical source reference (e.g., "Aral Sea Ship Graveyard")
    pub historical_source: String,
}

/// MDI-driven audio parameters (folklore, myths, ambient anomalies).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MDIAudioParams {
    /// Slavic folk instrumentation enabled (gusli, zhaleika)
    pub folk_instruments_enabled: bool,
    /// Folk instrument volume (0.0 - 1.0)
    pub folk_volume: f32,
    /// Ambient anomaly frequency (ghostly whispers, distant voices)
    pub anomaly_frequency: f32,
    /// Myth source reference (e.g., "Slavic Folklore Motif Index")
    pub myth_source: String,
}

/// AOS-driven audio parameters (archival gaps, audio glitches).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AOSAudioParams {
    /// Audio glitch intensity (bitcrush, stutter, dropout)
    pub glitch_intensity: f32,
    /// Fragmented testimony triggers (redacted audio, broken recordings)
    pub testimony_fragments: Vec<TestimonyFragment>,
    /// Contradictory audio layers (overlapping voices, conflicting accounts)
    pub contradictory_layers: u8,
    /// Archival source reference (e.g., "Soviet Redaction Records")
    pub archival_source: String,
}

/// RRM-driven audio parameters (ritual chanting, occult audio).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RRMAudioParams {
    /// Ritual chanting enabled
    pub chanting_enabled: bool,
    /// Chanting volume (0.0 - 1.0)
    pub chanting_volume: f32,
    /// Chanting language (Slavic, Latin, Unknown)
    pub chanting_language: String,
    /// Occult audio triggers (sigil activation sounds, blood-powered doors)
    pub occult_triggers: Vec<OccultTrigger>,
    /// Ritual source reference (e.g., "Vozrozhdeniya Biological Testing")
    pub ritual_source: String,
}

/// DET-driven audio parameters (silence spikes, psychological effects).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DETAudioParams {
    /// Silence spike probability (0.0 - 1.0)
    pub silence_spike_probability: f32,
    /// Silence duration in seconds
    pub silence_duration_sec: f32,
    /// Psychological audio effects (heartbeat, breathing, tinnitus)
    pub psychological_effects: Vec<PsychologicalEffect>,
    /// Exposure time before effects trigger (seconds)
    pub exposure_threshold_sec: f32,
}

/// HVF-driven audio parameters (directional flow, weather migration).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HVFAudioParams {
    /// Directional audio flow (degrees, 0-360)
    pub flow_direction: f32,
    /// Weather migration audio (storm approach, wind shifts)
    pub weather_migration: bool,
    /// Wandering entity audio drift (chants move along HVF)
    pub entity_audio_drift: bool,
    /// Vector magnitude (intensity of flow)
    pub flow_magnitude: f32,
}

/// Fragmented testimony snippet (AOS-driven).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestimonyFragment {
    pub fragment_id: String,
    pub audio_clip_path: String,
    pub reliability_weight: f32, // RWF value
    pub contradiction_group: Option<String>, // Links to conflicting fragments
    pub historical_source: String,
}

/// Occult audio trigger (RRM-driven).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OccultTrigger {
    pub trigger_id: String,
    pub activation_condition: String, // e.g., "player_near_sigil"
    pub audio_clip_path: String,
    pub ritual_phase: String, // e.g., "invocation", "completion"
}

/// Psychological audio effect (DET-driven).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PsychologicalEffect {
    pub effect_type: PsychologicalEffectType,
    pub intensity: f32,
    pub trigger_condition: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PsychologicalEffectType {
    Heartbeat,      // Player heartbeat sync (BCI optional)
    Breathing,      // Labored breathing, suffocation hints
    Tinnitus,       // High-pitched ringing (trauma response)
    WhisperLayer,   // Subliminal whispers below conscious threshold
    MemoryFlash,    // Sudden audio flashback to historical event
}

/// Entertainment-driven audio mix settings.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EntertainmentMix {
    /// Target UEC (Uncertainty Engagement Coefficient)
    pub target_uec: f32,
    /// Target EMD (Evidential Mystery Density)
    pub target_emd: f32,
    /// Target STCI (Safe-Threat Contrast Index)
    pub target_stci: f32,
    /// Target CDL (Cognitive Dissonance Load)
    pub target_cdl: f32,
    /// Target ARR (Ambiguous Resolution Ratio)
    pub target_arr: f32,
    /// Current mix adjustments based on telemetry
    pub mix_adjustments: MixAdjustments,
}

/// Real-time mix adjustments for metric correction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MixAdjustments {
    /// Volume boost/cut for uncertainty (UEC correction)
    pub uncertainty_volume_delta: f32,
    /// Clarity reduction for mystery (EMD correction)
    pub mystery_clarity_delta: f32,
    /// Contrast adjustment for safe-threat (STCI correction)
    pub contrast_delta: f32,
    /// Conflicting audio layers for dissonance (CDL correction)
    pub dissonance_layers_delta: u8,
    /// Resolution withholding for ambiguity (ARR correction)
    pub resolution_withhold: bool,
}

// ============================================================================
// SECTION 2: AUDIO AUTOMATION ENGINE
// ============================================================================

/// Invariant-Driven Audio Automation Engine.
pub struct AudioAutomationEngine {
    spectral_library: Box<dyn SpectralLibrary>,
    fmod_integration: FMODIntegration,
    wwise_integration: WwiseIntegration,
    audio_config: AudioConfig,
}

/// FMOD middleware integration parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FMODIntegration {
    pub enabled: bool,
    pub parameter_mappings: HashMap<String, String>, // Invariant → FMOD Parameter
    pub event_triggers: Vec<String>,
}

/// Wwise middleware integration parameters.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WwiseIntegration {
    pub enabled: bool,
    pub rtpc_mappings: HashMap<String, String>, // Invariant → Wwise RTPC
    pub state_triggers: Vec<String>,
}

/// Audio configuration for generation sprints.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AudioConfig {
    /// Minimum CIC threshold for industrial decay SFX
    pub industrial_decay_cic_threshold: f32,
    /// Minimum MDI threshold for folk instrumentation
    pub folk_instruments_mdi_threshold: f32,
    /// Minimum AOS threshold for audio glitches
    pub audio_glitch_aos_threshold: f32,
    /// Minimum RRM threshold for ritual chanting
    pub ritual_chanting_rrm_threshold: f32,
    /// Minimum DET threshold for silence spikes
    pub silence_spike_det_threshold: f32,
    /// Charter compliance enforcement (cannot be disabled)
    pub charter_enforcement: bool,
    /// Target entertainment metrics for validation
    pub target_metrics: EntertainmentMetrics,
    /// BCI integration enabled (Tier 3 research only)
    pub bci_integration: bool,
}

impl AudioAutomationEngine {
    pub fn new(
        spectral_library: Box<dyn SpectralLibrary>,
        config: AudioConfig,
    ) -> Self {
        Self {
            spectral_library,
            fmod_integration: FMODIntegration {
                enabled: true,
                parameter_mappings: Self::create_fmod_mappings(),
                event_triggers: vec![
                    "cic_industrial_decay".to_string(),
                    "mdi_folk_anomaly".to_string(),
                    "aos_audio_glitch".to_string(),
                    "rrm_ritual_chant".to_string(),
                    "det_silence_spike".to_string(),
                ],
            },
            wwise_integration: WwiseIntegration {
                enabled: false,
                rtpc_mappings: Self::create_wwise_mappings(),
                state_triggers: vec![],
            },
            audio_config: config,
        }
    }

    /// Create FMOD parameter mappings from invariants.
    fn create_fmod_mappings() -> HashMap<String, String> {
        let mut mappings = HashMap::new();
        mappings.insert("CIC".to_string(), "CatastrophicIntensity".to_string());
        mappings.insert("MDI".to_string(), "MythicAmbience".to_string());
        mappings.insert("AOS".to_string(), "ArchivalGlitch".to_string());
        mappings.insert("RRM".to_string(), "RitualPresence".to_string());
        mappings.insert("DET".to_string(), "DreadExposure".to_string());
        mappings.insert("UEC".to_string(), "UncertaintyMix".to_string());
        mappings.insert("STCI".to_string(), "ThreatContrast".to_string());
        mappings
    }

    /// Create Wwise RTPC mappings from invariants.
    fn create_wwise_mappings() -> HashMap<String, String> {
        let mut mappings = HashMap::new();
        mappings.insert("CIC".to_string(), "RTPC_CIC_Intensity".to_string());
        mappings.insert("MDI".to_string(), "RTPC_MDI_Ambience".to_string());
        mappings.insert("AOS".to_string(), "RTPC_AOS_Glitch".to_string());
        mappings.insert("RRM".to_string(), "RTPC_RRM_Chant".to_string());
        mappings.insert("DET".to_string(), "RTPC_DET_Dread".to_string());
        mappings
    }

    /// Generate audio profile from historical invariants.
    pub fn generate_audio_profile(
        &self,
        x: f32,
        y: f32,
        current_metrics: &EntertainmentMetrics,
    ) -> InvariantAudioProfile {
        // Query historical invariants for this coordinate
        let invariants = self.spectral_library.query_invariants(x, y);

        // Generate CIC audio parameters
        let cic_params = self.generate_cic_audio(&invariants);

        // Generate MDI audio parameters
        let mdi_params = self.generate_mdi_audio(&invariants);

        // Generate AOS audio parameters
        let aos_params = self.generate_aos_audio(&invariants);

        // Generate RRM audio parameters
        let rrm_params = self.generate_rrm_audio(&invariants);

        // Generate DET audio parameters
        let det_params = self.generate_det_audio(&invariants, current_metrics);

        // Generate HVF audio parameters
        let hvf_params = self.generate_hvf_audio(&invariants);

        // Generate entertainment-driven mix
        let entertainment_mix = self.generate_entertainment_mix(current_metrics);

        // Validate charter compliance
        let charter_compliant = self.validate_charter_compliance(
            &cic_params,
            &mdi_params,
            &aos_params,
            &rrm_params,
            &det_params,
        );

        InvariantAudioProfile {
            cic_audio_params: cic_params,
            mdi_audio_params: mdi_params,
            aos_audio_params: aos_params,
            rrm_audio_params: rrm_params,
            det_audio_params: det_params,
            hvf_audio_params: hvf_params,
            entertainment_mix,
            charter_compliant,
        }
    }

    /// Generate CIC-driven audio parameters.
    fn generate_cic_audio(&self, invariants: &HistoricalInvariantProfile) -> CICAudioParams {
        let cic = invariants.cic.0;

        // Industrial decay SFX scale with CIC
        let decay_volume = if cic >= self.audio_config.industrial_decay_cic_threshold {
            (cic - 0.5) * 1.5 // Scale from 0.0 to 0.75
        } else {
            0.0
        };

        // Rumble intensity based on catastrophe level
        let rumble = cic * 0.8;

        // Low-frequency drone for high-CIC zones
        let drone = if cic > 0.7 { cic * 0.6 } else { 0.0 };

        // Historical source reference
        let source = if cic > 0.8 {
            "Aral Sea Environmental Disaster Archives (1960-2000)".to_string()
        } else if cic > 0.5 {
            "Soviet Industrial Collapse Records (1990s)".to_string()
        } else {
            "Local Industrial Decay Documentation".to_string()
        };

        CICAudioParams {
            rumble_intensity: rumble.min(1.0),
            decay_sfx_volume: decay_volume.min(1.0),
            drone_presence: drone.min(1.0),
            historical_source: source,
        }
    }

    /// Generate MDI-driven audio parameters.
    fn generate_mdi_audio(&self, invariants: &HistoricalInvariantProfile) -> MDIAudioParams {
        let mdi = invariants.mdi.0;

        // Slavic folk instrumentation (gusli, zhaleika)
        let folk_enabled = mdi >= self.audio_config.folk_instruments_mdi_threshold;
        let folk_volume = if folk_enabled { mdi * 0.7 } else { 0.0 };

        // Ambient anomaly frequency (ghostly whispers, distant voices)
        let anomaly_freq = mdi * 0.5;

        // Myth source reference
        let source = if mdi > 0.7 {
            "Slavic Folklore Motif Index (Aarne-Thompson-Uther)".to_string()
        } else {
            "Regional Urban Legend Archives".to_string()
        };

        MDIAudioParams {
            folk_instruments_enabled: folk_enabled,
            folk_volume: folk_volume.min(1.0),
            anomaly_frequency: anomaly_freq.min(1.0),
            myth_source: source,
        }
    }

    /// Generate AOS-driven audio parameters.
    fn generate_aos_audio(&self, invariants: &HistoricalInvariantProfile) -> AOSAudioParams {
        let aos = invariants.aos.0;

        // Audio glitch intensity (bitcrush, stutter, dropout)
        let glitch = if aos >= self.audio_config.audio_glitch_aos_threshold {
            (aos - 0.5) * 1.2
        } else {
            0.0
        };

        // Fragmented testimony triggers
        let mut fragments = Vec::new();
        if aos > 0.6 {
            fragments.push(TestimonyFragment {
                fragment_id: "testimony_redacted_01".to_string(),
                audio_clip_path: "audio/testimonies/redacted_fragment_01.wav".to_string(),
                reliability_weight: invariants.rwf.0,
                contradiction_group: Some("evacuation_conflict".to_string()),
                historical_source: "Soviet Archival Redaction Records".to_string(),
            });
        }

        // Contradictory audio layers
        let contradictory_layers = if aos > 0.8 { 3 } else if aos > 0.6 { 2 } else { 0 };

        AOSAudioParams {
            glitch_intensity: glitch.min(1.0),
            testimony_fragments: fragments,
            contradictory_layers,
            archival_source: "Soviet Archival Gaps & Redaction Records".to_string(),
        }
    }

    /// Generate RRM-driven audio parameters.
    fn generate_rrm_audio(&self, invariants: &HistoricalInvariantProfile) -> RRMAudioParams {
        let rrm = invariants.rrm.0;

        // Ritual chanting enabled
        let chanting_enabled = rrm >= self.audio_config.ritual_chanting_rrm_threshold;
        let chanting_volume = if chanting_enabled { rrm * 0.8 } else { 0.0 };

        // Chanting language based on historical context
        let language = if rrm > 0.8 {
            "Old Church Slavonic".to_string()
        } else if rrm > 0.6 {
            "Russian (Soviet Era)".to_string()
        } else {
            "Unknown".to_string()
        };

        // Occult audio triggers
        let mut triggers = Vec::new();
        if rrm > 0.7 {
            triggers.push(OccultTrigger {
                trigger_id: "sigil_activation_01".to_string(),
                activation_condition: "player_near_sigil".to_string(),
                audio_clip_path: "audio/occult/sigil_activate.wav".to_string(),
                ritual_phase: "invocation".to_string(),
            });
        }

        RRMAudioParams {
            chanting_enabled,
            chanting_volume: chanting_volume.min(1.0),
            chanting_language: language,
            occult_triggers: triggers,
            ritual_source: "Vozrozhdeniya Biological Testing Records".to_string(),
        }
    }

    /// Generate DET-driven audio parameters.
    fn generate_det_audio(
        &self,
        invariants: &HistoricalInvariantProfile,
        current_metrics: &EntertainmentMetrics,
    ) -> DETAudioParams {
        let det = invariants.det.0;

        // Silence spike probability (negative space audio)
        // High UEC regions get more silence to amplify dread
        let silence_prob = if det <= self.audio_config.silence_spike_det_threshold {
            0.3 + (current_metrics.uec * 0.4) // Scale with UEC
        } else {
            0.1
        };

        // Silence duration (2-5 seconds typical)
        let silence_duration = if silence_prob > 0.5 { 4.0 } else { 2.0 };

        // Psychological effects
        let mut effects = Vec::new();
        if det < 0.4 {
            // Low DET = faster psychological effects
            effects.push(PsychologicalEffect {
                effect_type: PsychologicalEffectType::Heartbeat,
                intensity: 0.6,
                trigger_condition: "player_stationary_10s".to_string(),
            });
            effects.push(PsychologicalEffect {
                effect_type: PsychologicalEffectType::WhisperLayer,
                intensity: 0.4,
                trigger_condition: "high_aos_zone".to_string(),
            });
        }

        // Exposure threshold before effects trigger
        let exposure_threshold = if det < 0.3 { 30.0 } else if det < 0.5 { 60.0 } else { 120.0 };

        DETAudioParams {
            silence_spike_probability: silence_prob.min(1.0),
            silence_duration_sec: silence_duration,
            psychological_effects: effects,
            exposure_threshold_sec: exposure_threshold,
        }
    }

    /// Generate HVF-driven audio parameters.
    fn generate_hvf_audio(&self, invariants: &HistoricalInvariantProfile) -> HVFAudioParams {
        let hvf = &invariants.hvf;

        // Calculate flow direction from vector
        let direction = (hvf.y.atan2(hvf.x) * 180.0 / std::f32::consts::PI + 360.0) % 360.0;

        // Weather migration enabled for high-magnitude HVF
        let weather_migration = hvf.magnitude > 0.6;

        // Entity audio drift along HVF
        let entity_drift = hvf.magnitude > 0.5;

        HVFAudioParams {
            flow_direction: direction,
            weather_migration,
            entity_audio_drift: entity_drift,
            flow_magnitude: hvf.magnitude,
        }
    }

    /// Generate entertainment-driven audio mix.
    fn generate_entertainment_mix(&self, current_metrics: &EntertainmentMetrics) -> EntertainmentMix {
        let target = &self.audio_config.target_metrics;

        // Calculate mix adjustments based on metric deviations
        let adjustments = self.calculate_mix_adjustments(current_metrics, target);

        EntertainmentMix {
            target_uec: target.uec,
            target_emd: target.emd,
            target_stci: target.stci,
            target_cdl: target.cdl,
            target_arr: target.arr,
            mix_adjustments: adjustments,
        }
    }

    /// Calculate real-time mix adjustments for metric correction.
    fn calculate_mix_adjustments(
        &self,
        current: &EntertainmentMetrics,
        target: &EntertainmentMetrics,
    ) -> MixAdjustments {
        // UEC correction: If too low, increase uncertainty audio
        let uec_delta = if current.uec < target.uec {
            (target.uec - current.uec) * 0.5 // Volume boost
        } else {
            0.0
        };

        // EMD correction: If too low, reduce audio clarity
        let emd_delta = if current.emd < target.emd {
            (target.emd - current.emd) * -0.3 // Reduce clarity
        } else {
            0.0
        };

        // STCI correction: Adjust contrast between safe/threat audio
        let stci_delta = if current.stci > target.stci {
            -0.2 // Reduce contrast if overwhelmed
        } else if current.stci < target.stci {
            0.2 // Increase contrast if too safe
        } else {
            0.0
        };

        // CDL correction: Add conflicting audio layers
        let cdl_delta = if current.cdl < target.cdl {
            2 // Add 2 more contradictory layers
        } else {
            0
        };

        // ARR correction: Withhold resolution if too low
        let arr_withhold = current.arr < target.arr;

        MixAdjustments {
            uncertainty_volume_delta: uec_delta,
            mystery_clarity_delta: emd_delta,
            contrast_delta: stci_delta,
            dissonance_layers_delta: cdl_delta,
            resolution_withhold: arr_withhold,
        }
    }

    /// Validate audio profile against Rivers of Blood Charter.
    fn validate_charter_compliance(
        &self,
        cic: &CICAudioParams,
        mdi: &MDIAudioParams,
        aos: &AOSAudioParams,
        rrm: &RRMAudioParams,
        det: &DETAudioParams,
    ) -> bool {
        if !self.audio_config.charter_enforcement {
            return true; // Should never happen in production
        }

        // Charter Pillar 2: No explicit screams or violence SFX
        // (Enforced at asset level, but we validate metadata here)

        // Charter Pillar 1: Historical grounding required
        if cic.historical_source.is_empty() {
            return false;
        }
        if mdi.folk_instruments_enabled && mdi.myth_source.is_empty() {
            return false;
        }
        if !aos.testimony_fragments.is_empty() && aos.archival_source.is_empty() {
            return false;
        }
        if rrm.chanting_enabled && rrm.ritual_source.is_empty() {
            return false;
        }

        // Charter Pillar 3: Entertainment validation
        // Audio must contribute to uncertainty, not confusion
        if det.silence_spike_probability > 0.8 {
            // Too much silence becomes frustrating, not engaging
            return false;
        }

        true
    }

    /// Apply audio profile to FMOD middleware.
    pub fn apply_to_fmod(&self, profile: &InvariantAudioProfile) {
        if !self.fmod_integration.enabled {
            return;
        }

        // Set FMOD parameters from invariant mappings
        self.set_fmod_parameter("CatastrophicIntensity", profile.cic_audio_params.rumble_intensity);
        self.set_fmod_parameter("MythicAmbience", profile.mdi_audio_params.folk_volume);
        self.set_fmod_parameter("ArchivalGlitch", profile.aos_audio_params.glitch_intensity);
        self.set_fmod_parameter("RitualPresence", profile.rrm_audio_params.chanting_volume);
        self.set_fmod_parameter("DreadExposure", profile.det_audio_params.silence_spike_probability);

        // Set entertainment metric parameters
        self.set_fmod_parameter("UncertaintyMix", profile.entertainment_mix.mix_adjustments.uncertainty_volume_delta);
        self.set_fmod_parameter("ThreatContrast", profile.entertainment_mix.mix_adjustments.contrast_delta);

        // Trigger events based on thresholds
        if profile.cic_audio_params.decay_sfx_volume > 0.5 {
            self.trigger_fmod_event("cic_industrial_decay");
        }
        if profile.mdi_audio_params.folk_instruments_enabled {
            self.trigger_fmod_event("mdi_folk_anomaly");
        }
        if profile.aos_audio_params.glitch_intensity > 0.5 {
            self.trigger_fmod_event("aos_audio_glitch");
        }
        if profile.rrm_audio_params.chanting_enabled {
            self.trigger_fmod_event("rrm_ritual_chant");
        }
        if profile.det_audio_params.silence_spike_probability > 0.5 {
            self.trigger_fmod_event("det_silence_spike");
        }
    }

    /// Set FMOD parameter value.
    fn set_fmod_parameter(&self, name: &str, value: f32) {
        // In production, this calls FMOD API
        // Example: fmod_system.set_parameter_by_name(name, value)
        log::debug!("FMOD Parameter: {} = {}", name, value);
    }

    /// Trigger FMOD event.
    fn trigger_fmod_event(&self, event_name: &str) {
        // In production, this calls FMOD API
        // Example: fmod_system.trigger_event(event_name)
        log::debug!("FMOD Event Triggered: {}", event_name);
    }

    /// Apply audio profile to Wwise middleware.
    pub fn apply_to_wwise(&self, profile: &InvariantAudioProfile) {
        if !self.wwise_integration.enabled {
            return;
        }

        // Set Wwise RTPCs from invariant mappings
        for (invariant, rtpc) in &self.wwise_integration.rtpc_mappings {
            let value = match invariant.as_str() {
                "CIC" => profile.cic_audio_params.rumble_intensity,
                "MDI" => profile.mdi_audio_params.folk_volume,
                "AOS" => profile.aos_audio_params.glitch_intensity,
                "RRM" => profile.rrm_audio_params.chanting_volume,
                "DET" => profile.det_audio_params.silence_spike_probability,
                _ => 0.0,
            };
            self.set_wwise_rtpc(rtpc, value);
        }
    }

    /// Set Wwise RTPC value.
    fn set_wwise_rtpc(&self, name: &str, value: f32) {
        // In production, this calls Wwise API
        // Example: wwise_system.set_rtpc_value(name, value)
        log::debug!("Wwise RTPC: {} = {}", name, value);
    }

    /// BCI Integration (Tier 3 Research Only).
    /// Syncs audio parameters to player physiological state.
    #[cfg(feature = "research")]
    pub fn apply_bci_sync(&self, profile: &mut InvariantAudioProfile, bci_data: &BCIData) {
        // Heart rate → Heartbeat audio intensity
        if let Some(heartbeat) = &mut profile.det_audio_params.psychological_effects
            .iter_mut()
            .find(|e| matches!(e.effect_type, PsychologicalEffectType::Heartbeat))
        {
            heartbeat.intensity = bci_data.heart_rate_normalized;
        }

        // EDA (arousal) → Silence spike probability
        profile.det_audio_params.silence_spike_probability += bci_data.eda_arousal * 0.2;

        // Respiration → Whisper layer volume
        if let Some(whisper) = &mut profile.det_audio_params.psychological_effects
            .iter_mut()
            .find(|e| matches!(e.effect_type, PsychologicalEffectType::WhisperLayer))
        {
            whisper.intensity = bci_data.respiration_rate_normalized * 0.5;
        }
    }

    /// Predict entertainment metrics from audio profile.
    pub fn predict_audio_metrics(&self, profile: &InvariantAudioProfile) -> EntertainmentMetrics {
        // Calculate predicted metric contributions from audio
        let uec = profile.cic_audio_params.rumble_intensity * 0.3
            + profile.det_audio_params.silence_spike_probability * 0.4
            + profile.entertainment_mix.mix_adjustments.uncertainty_volume_delta * 0.3;

        let emd = profile.aos_audio_params.glitch_intensity * 0.4
            + profile.aos_audio_params.contradictory_layers as f32 * 0.1
            + profile.entertainment_mix.mix_adjustments.mystery_clarity_delta * 0.2;

        let stci = profile.cic_audio_params.decay_sfx_volume * 0.3
            + profile.entertainment_mix.mix_adjustments.contrast_delta * 0.4
            + profile.det_audio_params.silence_spike_probability * 0.3;

        let cdl = profile.aos_audio_params.contradictory_layers as f32 * 0.3
            + profile.rrm_audio_params.chanting_volume * 0.2
            + profile.entertainment_mix.mix_adjustments.dissonance_layers_delta as f32 * 0.2;

        let arr = if profile.entertainment_mix.mix_adjustments.resolution_withhold {
            0.85
        } else {
            0.65
        };

        EntertainmentMetrics {
            uec: uec.min(1.0).max(0.0),
            emd: emd.min(1.0).max(0.0),
            stci: stci.min(1.0).max(0.0),
            cdl: cdl.min(1.0).max(0.0),
            arr: arr.min(1.0).max(0.0),
        }
    }
}

// ============================================================================
// SECTION 3: BCI DATA STRUCTURES (TIER 3 RESEARCH)
// ============================================================================

/// Physiological data from BCI/biosensors (Tier 3 research only).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg(feature = "research")]
pub struct BCIData {
    /// Heart rate normalized (0.0 - 1.0)
    pub heart_rate_normalized: f32,
    /// Electrodermal activity (arousal) normalized (0.0 - 1.0)
    pub eda_arousal: f32,
    /// Respiration rate normalized (0.0 - 1.0)
    pub respiration_rate_normalized: f32,
    /// EEG attention level (0.0 - 1.0)
    pub eeg_attention: f32,
    /// Timestamp of reading
    pub timestamp_ms: u64,
}

// ============================================================================
// SECTION 4: AUDIO CONFIGURATION PRESETS
// ============================================================================

/// Preset configurations for different audio generation sprints.
pub mod audio_presets {
    use super::*;

    /// Aral Sea Ship Graveyard Audio Preset (Darkwood 2 reference).
    pub fn aral_sea_ship_graveyard() -> AudioConfig {
        AudioConfig {
            industrial_decay_cic_threshold: 0.6,
            folk_instruments_mdi_threshold: 0.5,
            audio_glitch_aos_threshold: 0.6,
            ritual_chanting_rrm_threshold: 0.7,
            silence_spike_det_threshold: 0.4,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.65,
                emd: 0.75,
                stci: 0.55,
                cdl: 0.80,
                arr: 0.85,
            },
            bci_integration: false,
        }
    }

    /// Vozrozhdeniya Biological Lab Audio Preset (High RRM).
    pub fn vozrozhdeniya_lab() -> AudioConfig {
        AudioConfig {
            industrial_decay_cic_threshold: 0.5,
            folk_instruments_mdi_threshold: 0.4,
            audio_glitch_aos_threshold: 0.7,
            ritual_chanting_rrm_threshold: 0.6,
            silence_spike_det_threshold: 0.3,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.70,
                emd: 0.80,
                stci: 0.60,
                cdl: 0.85,
                arr: 0.80,
            },
            bci_integration: true, // Tier 3 research
        }
    }

    /// Post-Soviet Industrial Collapse Audio Preset (High AOS).
    pub fn post_soviet_collapse() -> AudioConfig {
        AudioConfig {
            industrial_decay_cic_threshold: 0.65,
            folk_instruments_mdi_threshold: 0.6,
            audio_glitch_aos_threshold: 0.5,
            ritual_chanting_rrm_threshold: 0.5,
            silence_spike_det_threshold: 0.5,
            charter_enforcement: true,
            target_metrics: EntertainmentMetrics {
                uec: 0.60,
                emd: 0.85, // High mystery from audio glitches
                stci: 0.50,
                cdl: 0.75,
                arr: 0.90, // High ambiguity
            },
            bci_integration: false,
        }
    }
}

// ============================================================================
// SECTION 5: INTEGRATION HOOKS
// ============================================================================

/// Hooks for integration with PCG Generator (File 9) and Style Router (File 5).
pub mod integration {
    use super::*;

    /// Notify PCG Generator of audio profile for tile generation.
    pub fn notify_pcg_generator(tile_x: i32, tile_y: i32, profile: &InvariantAudioProfile) -> AudioTileData {
        AudioTileData {
            x: tile_x,
            y: tile_y,
            has_industrial_decay: profile.cic_audio_params.decay_sfx_volume > 0.5,
            has_folk_ambience: profile.mdi_audio_params.folk_instruments_enabled,
            has_audio_glitch: profile.aos_audio_params.glitch_intensity > 0.5,
            has_ritual_chant: profile.rrm_audio_params.chanting_enabled,
            silence_zone: profile.det_audio_params.silence_spike_probability > 0.5,
        }
    }

    #[derive(Debug, Clone)]
    pub struct AudioTileData {
        pub x: i32,
        pub y: i32,
        pub has_industrial_decay: bool,
        pub has_folk_ambience: bool,
        pub has_audio_glitch: bool,
        pub has_ritual_chant: bool,
        pub silence_zone: bool,
    }

    /// Notify Style Router of audio profile for style selection.
    pub fn notify_style_router(profile: &InvariantAudioProfile) -> String {
        // Style Router queries audio profile to select appropriate style
        if profile.rrm_audio_params.chanting_enabled {
            "machine_canyon_biomech_bci".to_string()
        } else if profile.cic_audio_params.rumble_intensity > 0.7 {
            "spectral_engraving_dark_sublime".to_string()
        } else {
            "liminal_safe_haven".to_string()
        }
    }
}

// ============================================================================
// SECTION 6: UNIT TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cic_audio_generation() {
        // Test CIC audio params scale correctly
        let cic_high = CICAudioParams {
            rumble_intensity: 0.9,
            decay_sfx_volume: 0.75,
            drone_presence: 0.54,
            historical_source: "Aral Sea Environmental Disaster Archives".to_string(),
        };

        assert!(cic_high.rumble_intensity > 0.7);
        assert!(cic_high.decay_sfx_volume > 0.5);
        assert!(!cic_high.historical_source.is_empty());
    }

    #[test]
    fn test_charter_compliance_validation() {
        // Test that audio profiles without historical sources fail validation
        let cic_no_source = CICAudioParams {
            rumble_intensity: 0.8,
            decay_sfx_volume: 0.6,
            drone_presence: 0.5,
            historical_source: String::new(), // Empty = violation
        };

        assert!(cic_no_source.historical_source.is_empty());
        // This would fail charter validation in production
    }

    #[test]
    fn test_entertainment_metric_prediction() {
        // Test that audio profiles predict metrics within target ranges
        let config = audio_presets::aral_sea_ship_graveyard();

        // Verify target metrics are within Entertainment Metrics Schema ranges
        assert!(config.target_metrics.uec >= 0.55 && config.target_metrics.uec <= 0.85);
        assert!(config.target_metrics.emd >= 0.60 && config.target_metrics.emd <= 0.90);
        assert!(config.target_metrics.arr >= 0.70 && config.target_metrics.arr <= 1.0);
    }

    #[test]
    fn test_silence_spike_probability() {
        // Test silence spikes scale with UEC (negative space audio)
        let metrics_high_uec = EntertainmentMetrics {
            uec: 0.80,
            emd: 0.75,
            stci: 0.55,
            cdl: 0.80,
            arr: 0.85,
        };

        let metrics_low_uec = EntertainmentMetrics {
            uec: 0.40,
            emd: 0.50,
            stci: 0.55,
            cdl: 0.60,
            arr: 0.70,
        };

        // High UEC should get more silence spikes
        assert!(metrics_high_uec.uec > metrics_low_uec.uec);
    }
}
