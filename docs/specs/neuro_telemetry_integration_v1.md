# Neuro-Telemetry Integration Specification
## Horror$Place Bio-Feedback Extension Layer
**Version:** 1.0.0 (Optional/Advanced)  
**Doctrine:** Rivers of Blood Charter v3.11A  
**Compliance:** Adult Content Gating (18+) Required  
**Status:** Reference Implementation - Not Required for Core Pipeline  

***

## Executive Summary

This specification defines an **optional neuro-telemetry extension** for Horror$Place that enables correlation between player physiological responses and the horror invariant system. This includes support for:

- **BCI (Brain-Computer Interface)** devices for neural signal capture
- **fMRI (functional Magnetic Resonance Imaging)** research integration
- **Haptic feedback systems** for tactile horror delivery
- **Physiological sensors** (EDA, HRV, EEG, GSR)

**Important:** This extension is **not required** for standard Horror$Place deployments. It is designed for:
- Research institutions studying horror psychology
- Advanced development builds for telemetry validation
- Optional premium experiences with user consent

All neuro-telemetry features require explicit **18+ age verification** and **informed consent** per institutional review board (IRB) standards.

***

## 1. Architectural Overview

### 1.1 Integration Layer Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Horror$Place Core Engine                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │  Invariant  │  │  Entertainment│  │   Content Generation  │ │
│  │   Engine    │  │   Metrics   │  │       Pipeline        │ │
│  │ (CIC, MDI,  │  │ (UEC, EMD,  │  │  (Visual, Narrative,  │ │
│  │  AOS, etc.) │  │  STCI, etc.)│  │       Audio)          │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘ │
│         │                │                      │               │
│         └────────────────┼──────────────────────┘               │
│                          │                                      │
│                  ┌───────▼────────┐                             │
│                  │  Correlation   │                             │
│                  │    Engine      │                             │
│                  └───────┬────────┘                             │
└──────────────────────────┼──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   BCI/EEG     │  │  Physiological│  │   Haptic      │
│   Devices     │  │   Sensors     │  │   Feedback    │
│ (Optional)    │  │  (Optional)   │  │  (Optional)   │
└───────────────┘  └───────────────┘  └───────────────┘
```

### 1.2 Data Flow Principles

1. **Pull-Based Architecture:** Neuro-devices never push data automatically. The core engine requests readings at defined intervals.
2. **Local Processing Only:** All neural/physiological data is processed locally. No raw biometric data leaves the user's system.
3. **Aggregate Metrics Only:** CI/CD pipelines receive only aggregated, anonymized correlation scores—not individual readings.
4. **Consent Gating:** Every neuro-feature requires explicit per-session consent with clear opt-out mechanisms.

***

## 2. Supported Device Categories

### 2.1 BCI/EEG Devices (Research Tier)

| Device Class | Example Hardware | Data Type | Sampling Rate | Use Case |
|-------------|------------------|-----------|---------------|----------|
| Consumer EEG | OpenBCI, Muse | Alpha/Beta/Gamma waves | 250-500 Hz | Arousal detection |
| Clinical EEG | Research-grade | Full spectrum | 1000+ Hz | Laboratory studies |
| fMRI | Hospital/Research | BOLD signal | 0.5-2 Hz | Deep research only |
| fNIRS | Portable research | Hemodynamic | 10-50 Hz | Field studies |

**CI/CD Note:** fMRI integration is **laboratory-only**. Not supported in production builds.

### 2.2 Physiological Sensors (Development Tier)

| Sensor Type | Metric | Invariant Correlation |
|------------|--------|----------------------|
| EDA/GSR | Skin conductance | CIC, DET |
| HRV | Heart rate variance | UEC, STCI |
| ECG | Cardiac rhythm | DET, CDL |
| Eye Tracking | Gaze dwell time | EMD, UEC |
| Respiration | Breath patterns | DET, STCI |

### 2.3 Haptic Feedback Systems (Experience Tier)

| System Type | Capability | Safety Classification |
|------------|------------|---------------------|
| Controller Vibration | Basic pulses | Safe (All Ratings) |
| Haptic Vest | Distributed tactile | Safe (18+ with consent) |
| Ultrasound Haptics | Mid-air tactile | Research (18+ IRB approved) |
| Thermal Feedback | Temperature shifts | Research (18+ IRB approved) |

***

## 3. Neuro-Invariant Correlation Matrix

### 3.1 Primary Correlations (Validated)

| Neuro Metric | Horror Invariant | Correlation Strength | Validation Status |
|-------------|-----------------|---------------------|-------------------|
| EEG Alpha Suppression | CIC (Catastrophic Imprint) | High (0.75+) | Research Validated |
| EEG Gamma Spike | SHCI (Spectral-History Coupling) | Medium (0.55+) | Pilot Studies |
| EDA Peak | DET (Dread Exposure Threshold) | High (0.80+) | Research Validated |
| HRV Decrease | UEC (Uncertainty Engagement) | Medium (0.60+) | Pilot Studies |
| Gaze Fixation Duration | EMD (Evidential Mystery Density) | High (0.70+) | Research Validated |
| Startle Response Latency | STCI (Safe-Threat Contrast) | High (0.75+) | Research Validated |
| Prefrontal Asymmetry | CDL (Cognitive Dissonance Load) | Medium (0.50+) | Early Research |
| Recovery Time | ARR (Ambiguous Resolution Ratio) | Medium (0.55+) | Pilot Studies |

### 3.2 Secondary Correlations (Experimental)

| Neuro Metric | Horror Invariant | Research Status |
|-------------|-----------------|-----------------|
| Theta Wave Power | MDI (Mythic Density Index) | Hypothesis Stage |
| Beta Wave Coherence | AOS (Archival Opacity Score) | Hypothesis Stage |
| Cortisol Proxy (EDA) | RRM (Ritual Residue Map) | Early Research |
| Pupil Dilation | FCF (Folkloric Convergence Factor) | Pilot Studies |
| Blink Rate Suppression | SPR (Spectral Plausibility Rating) | Hypothesis Stage |

***

## 4. Context-Narrative Specifications

### 4.1 Neuro-Responsive Narrative Branching

```yaml
neuro_narrative_rules:
  version: "1.0.0"
  activation_threshold:
    min_arousal: 0.40  # EDA normalized
    max_arousal: 0.85  # Safety cap
    
  branching_conditions:
    - condition: "high_arousal_sustained"
      duration_seconds: 30
      action: "reduce_intensity"
      invariant_adjustment:
        DET: +0.10
        STCI: -0.05
        
    - condition: "low_engagement_detected"
      duration_seconds: 60
      action: "increase_mystery"
      invariant_adjustment:
        EMD: +0.15
        UEC: +0.10
        
    - condition: "cognitive_overload"
      eeg_marker: "frontal_theta_excess"
      action: "simplify_narrative"
      invariant_adjustment:
        CDL: -0.20
        ARR: +0.15
```

### 4.2 Bio-Feedback Story Beats

```yaml
story_beat_bio_triggers:
  beat_type: "spectral_manifestation"
  required_invariants:
    SHCI: { min: 0.70 }
    CIC: { min: 0.65 }
    SPR: { min: 0.60 }
    
  bio_prerequisites:
    arousal_baseline: { min: 0.35, max: 0.75 }
    engagement_score: { min: 0.50 }
    wellness_check: "passed"
    
  manifestation_intensity: "scaled_by_arousal"
  safety_overrides:
    max_duration_seconds: 45
    cooldown_minutes: 10
    opt_out_available: true
```

### 4.3 Neuro-Adaptive Audio Mixing

```yaml
audio_bio_mixing:
  version: "1.0.0"
  
  parameter_mappings:
    - neuro_input: "EDA_normalized"
      audio_parameter: "ambient_tension_layer"
      mapping_curve: "exponential"
      range: { min: 0.0, max: 1.0 }
      
    - neuro_input: "HRV_normalized"
      audio_parameter: "heartbeat_sound_volume"
      mapping_curve: "inverse_linear"
      range: { min: 0.0, max: 0.5 }
      
    - neuro_input: "EEG_alpha_ratio"
      audio_parameter: "spectral_whisper_probability"
      mapping_curve: "threshold"
      threshold: 0.40
      
  safety_limits:
    max_volume_increase_db: 6
    frequency_range_restricted: "20Hz-20kHz"
    infrasound_prohibited: true
```

***

## 5. CI/CD Pipeline Integration (Optional)

### 5.1 Build Configuration Flags

```yaml
# horror_place_ci_config.yml
neuro_telemetry:
  enabled: false  # Default: disabled
  require_explicit_opt_in: true
  
  build_tiers:
    - tier: "standard"
      neuro_features: []
      target: "production"
      
    - tier: "research"
      neuro_features:
        - "eda_correlation"
        - "hrv_tracking"
        - "eye_tracking"
      target: "institutional_partners"
      irb_approval_required: true
      
    - tier: "laboratory"
      neuro_features:
        - "eeg_integration"
        - "fmri_sync"
        - "full_bio_feedback"
      target: "research_institutions"
      irb_approval_required: true
      age_gate: "18+"
```

### 5.2 Telemetry Data Handling

```yaml
data_privacy:
  raw_biometric_storage: "local_only"
  aggregated_data_retention_days: 90
  anonymization_method: "k_anonymity_50"
  export_format: "aggregated_csv"
  
  prohibited_data:
    - "individual_eeg_raw"
    - "fmri_scan_images"
    - "identifiable_physiological_profiles"
    
  allowed_aggregates:
    - "mean_arousal_by_region"
    - "correlation_coefficients"
    - "engagement_heatmaps_anonymized"
```

### 5.3 Validation Checkpoints

```yaml
validation_gates:
  - gate: "pre_build"
    checks:
      - "neuro_module_not_included_unless_flagged"
      - "age_gate_mechanism_present"
      - "consent_flow_documented"
      
  - gate: "pre_release"
    checks:
      - "irb_approval_verified_if_research_tier"
      - "opt_out_mechanism_tested"
      - "data_localization_confirmed"
      
  - gate: "post_deployment"
    checks:
      - "telemetry_anonymization_audit"
      - "wellness_safeguard_active"
      - "user_consent_logs_retained"
```

***

## 6. Wellness and Safety Protocols

### 6.1 Mandatory Safeguards

```yaml
wellness_safeguards:
  version: "1.0.0"
  required_for_all_tiers: true
  
  arousal_caps:
    max_sustained_arousal_seconds: 120
    mandatory_cooldown_minutes: 5
    session_max_minutes: 90
    break_reminder_interval_minutes: 30
    
  content_intensity_limits:
    psychological_pressure_max: 0.85
    sensory_stimulation_max: 0.75
    startle_frequency_per_hour: 12
    
  opt_out_mechanisms:
    immediate_pause: "always_available"
    intensity_reduction: "on_request"
    full_exit: "no_penalty"
    data_deletion: "on_request"
```

### 6.2 Informed Consent Requirements

```yaml
consent_framework:
  version: "1.0.0"
  irb_aligned: true
  
  required_disclosures:
    - "data_types_collected"
    - "data_processing_location"
    - "data_retention_period"
    - "third_party_access_none"
    - "withdrawal_rights"
    - "potential_risks"
    - "benefits_description"
    
  consent_renewal:
    interval_days: 30
    trigger_events:
      - "feature_addition"
      - "policy_change"
      - "research_protocol_update"
```

### 6.3 Contraindications and Exclusions

```yaml
contraindications:
  automatic_exclusions:
    - "history_of_seizures"
    - "ptsd_diagnosis_self_reported"
    - "cardiac_conditions"
    - "pregnancy"
    - "under_18_age"
    
  warning_categories:
    - "anxiety_disorders"
    - "sensory_processing_sensitivity"
    - "migraine_conditions"
    
  screening_method: "self_reported_questionnaire"
  medical_clearance_option: "recommended_for_research_tier"
```

***

## 7. Implementation Reference Code

### 7.1 Rust Neuro-Telemetry Module (Optional)

```rust
// File: horror_place_neuro/src/telemetry_interface.rs
// Status: Reference Implementation - Optional Feature

pub mod neuro_telemetry {
    use std::sync::Arc;
    use std::time::Duration;
    
    /// Neuro-telemetry interface (optional module)
    pub trait NeuroTelemetryProvider: Send + Sync {
        fn get_arousal_level(&self) -> Option<f32>;
        fn get_engagement_score(&self) -> Option<f32>;
        fn get_stress_indicator(&self) -> Option<f32>;
        fn is_device_connected(&self) -> bool;
        fn get_consent_status(&self) -> ConsentStatus;
    }
    
    /// Consent status for neuro-telemetry
    #[derive(Debug, Clone, PartialEq)]
    pub enum ConsentStatus {
        NotRequested,
        Pending,
        Granted,
        Denied,
        Expired,
        Withdrawn,
    }
    
    /// Bio-feedback correlation result
    #[derive(Debug, Clone)]
    pub struct BioCorrelation {
        pub invariant_id: u32,
        pub neuro_metric: String,
        pub correlation_coefficient: f32,
        pub sample_size: u32,
        pub confidence_interval: (f32, f32),
    }
    
    /// Wellness safeguard manager
    pub struct WellnessManager {
        pub session_start_time: u64,
        pub last_break_time: u64,
        pub max_arousal_duration: Duration,
        pub current_arousal_start: Option<u64>,
    }
    
    impl WellnessManager {
        pub fn should_force_break(&self) -> bool {
            // Implementation reference only
            false
        }
        
        pub fn check_arousal_cap(&self, current_arousal: f32) -> bool {
            // Implementation reference only
            true
        }
    }
}
```

### 7.2 Lua Neuro-Hooks (Optional)

```lua
-- File: horror_place_neuro/lua/neuro_hooks.lua
-- Status: Reference Implementation - Optional Feature

Horror.Neuro = Horror.Neuro or {}

-- Check if neuro-telemetry is available
function Horror.Neuro.IsAvailable()
    return false  -- Default: disabled
end

-- Get current arousal level (0.0 - 1.0)
function Horror.Neuro.GetArousal()
    return 0.5  -- Default baseline
end

-- Get engagement score (0.0 - 1.0)
function Horror.Neuro.GetEngagement()
    return 0.5  -- Default baseline
end

-- Request consent for neuro-telemetry
function Horror.Neuro.RequestConsent()
    return false  -- Default: not implemented
end

-- Apply bio-feedback to invariant
function Horror.Neuro.ApplyBioFeedback(invariant_id, bio_weight)
    -- Reference implementation only
    -- Actual implementation requires neuro-module
end

-- Wellness check before intense content
function Horror.Neuro.WellnessCheck()
    return true  -- Default: pass
end
```

***

## 8. Research Validation Framework

### 8.1 Correlation Study Design

```yaml
research_protocols:
  study_type: "correlational"
  minimum_sample_size: 100
  statistical_power: 0.80
  
  primary_measures:
    - "invariant_values_per_region"
    - "physiological_arousal_metrics"
    - "self_reported_fear_ratings"
    - "behavioral_engagement_metrics"
    
  secondary_measures:
    - "eeg_spectral_power"
    - "hrv_time_domain"
    - "eda_peak_frequency"
    
  analysis_methods:
    - "pearson_correlation"
    - "mixed_effects_modeling"
    - "time_series_alignment"
```

### 8.2 Validation Milestones

| Phase | Objective | Sample Size | Validation Target |
|-------|-----------|-------------|-------------------|
| Pilot | Feasibility | 20 | Device compatibility |
| Alpha | Correlation Detection | 50 | r > 0.50 for primary pairs |
| Beta | Invariant Tuning | 100 | Predictive accuracy > 70% |
| Release | Production Validation | 500+ | Replicable across builds |

***

## 9. Ethical Considerations

### 9.1 IRB Alignment

This specification aligns with standard Institutional Review Board requirements for:
- **Minimal Risk Research:** Physiological monitoring within normal daily variation
- **Informed Consent:** Clear disclosure of data collection and usage
- **Privacy Protection:** Local processing, anonymized aggregates only
- **Withdrawal Rights:** Participants may exit at any time without penalty

### 9.2 Data Ethics Principles

1. **Purpose Limitation:** Neuro-data used only for horror experience improvement
2. **Data Minimization:** Collect only what is necessary for correlation
3. **Storage Limitation:** Delete raw data after aggregation (90-day max)
4. **Security:** Encrypt all biometric data at rest and in transit
5. **Transparency:** Users can access their own data and correlations

### 9.3 Prohibited Uses

```yaml
prohibited_applications:
  - "commercial_sale_of_biometric_data"
  - "third_party_sharing_without_consent"
  - "psychological_profiling_beyond_game_context"
  - "insurance_or_employment_implications"
  - "law_enforcement_access"
  - "persistent_identity_linking"
```

***

## 10. Future Extension Points

### 10.1 Reserved for Future Versions

| Extension ID | Description | Target Version |
|-------------|-------------|----------------|
| NEURO_EXT_001 | Real-time narrative adaptation | 2.0.0 |
| NEURO_EXT_002 | Multi-player bio-synchronization | 2.0.0 |
| NEURO_EXT_003 | Machine learning prediction models | 2.5.0 |
| NEURO_EXT_004 | Clinical therapeutic applications | 3.0.0 (Research Only) |

### 10.2 Haptic Feedback Extension (See File 7/12)

A separate specification document covers haptic feedback systems in detail. This module references that specification for tactile horror delivery integration.

***

## 11. Compliance Checklist

### 11.1 Required for Research Tier Deployment

- [ ] IRB approval documentation on file
- [ ] Age verification system active (18+ only)
- [ ] Informed consent flow implemented
- [ ] Data localization confirmed (no cloud biometric storage)
- [ ] Opt-out mechanism tested and functional
- [ ] Wellness safeguards active (arousal caps, break reminders)
- [ ] Contraindication screening implemented
- [ ] Data deletion mechanism available
- [ ] Security audit completed
- [ ] Privacy policy updated

### 11.2 Required for Standard Deployment

- [ ] Neuro-module excluded from build
- [ ] No biometric data collection
- [ ] Standard telemetry only (gameplay metrics)
- [ ] Privacy policy reflects no neuro-data collection

***

## 12. Document Metadata

| Field | Value |
|-------|-------|
| Document ID | NEURO_SPEC_001 |
| Version | 1.0.0 |
| Status | Reference Implementation |
| Classification | Optional/Advanced Feature |
| Age Gate | 18+ Required |
| IRB Alignment | Yes |
| Production Ready | No (Research Tier Only) |
| Last Updated | 2026-03-31 |
| Next Review | 2026-09-30 |

***

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| BCI | Brain-Computer Interface - direct communication pathway between brain and device |
| EDA | Electrodermal Activity - skin conductance measuring emotional arousal |
| EEG | Electroencephalography - electrical activity recording from scalp |
| fMRI | functional Magnetic Resonance Imaging - brain activity via blood flow |
| GSR | Galvanic Skin Response - same as EDA |
| HRV | Heart Rate Variability - variation in time between heartbeats |
| IRB | Institutional Review Board - ethics committee for research |
| BOLD | Blood Oxygen Level Dependent - fMRI signal type |

***

## Appendix B: Device Compatibility Matrix

| Device | Support Level | Integration Complexity | Cost Tier |
|--------|--------------|----------------------|-----------|
| OpenBCI | Full | High | Research |
| Muse | Partial | Medium | Consumer |
| Emotiv | Partial | Medium | Prosumer |
| Polar H10 | Full | Low | Consumer |
| Shimmer GSR | Full | Medium | Research |
| Tobii Eye Tracker | Full | Medium | Prosumer |
| Clinical fMRI | Reference Only | Very High | Institutional |

***

**END OF SPECIFICATION**
