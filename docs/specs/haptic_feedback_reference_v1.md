# Haptic Feedback Reference Specification
## Horror$Place Tactile Horror Extension Layer
**Version:** 1.0.0 (Reference Only)  
**Doctrine:** Rivers of Blood Charter v3.11A  
**Compliance:** Adult Content Gating (18+) Required  
**Status:** Reference Implementation - Not Required for Core Pipeline  

***

## Executive Summary

This specification defines an **optional haptic feedback extension** for Horror$Place that enables tactile horror delivery through various haptic technologies. This includes support for:

- **Controller vibration** (standard gamepads, DualSense, Xbox)
- **Haptic vests** (bHaptics, Woojer, Subpac)
- **Ultrasound mid-air haptics** (Ultraleap, research tier)
- **Thermal feedback devices** (research tier)
- **Full-body haptic suits** (experimental/research)

**Important:** This extension is **not required** for standard Horror$Place deployments. It is designed for:
- Research institutions studying tactile horror
- Advanced development builds for immersive testing
- Optional premium experiences with user consent

All haptic features require explicit **18+ age verification** and **informed consent**. Safety protocols must be strictly enforced.

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
│                  │  Haptic        │                             │
│                  │  Correlation   │                             │
│                  │    Engine      │                             │
│                  └───────┬────────┘                             │
└──────────────────────────┼──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│   Controller  │  │   Haptic      │  │   Advanced    │
│   Vibration   │  │   Vest/Suit   │  │   Research    │
│  (Standard)   │  │  (Premium)    │  │  (Experimental)│
└───────────────┘  └───────────────┘  └───────────────┘
```

### 1.2 Design Philosophy

1. **Layered Intensity:** Haptic feedback should scale from subtle (standard controllers) to immersive (full suits)
2. **Invariant-Driven:** All haptic events must be triggered by horror invariants (CIC, DET, SHCI, etc.)
3. **Safety First:** Pain simulation must never exceed safe physiological thresholds
4. **Consent Gating:** Users must explicitly opt-in to haptic features
5. **Fallback Graceful:** If haptic device unavailable, experience degrades gracefully to audio/visual

***

## 2. Supported Haptic Device Categories

### 2.1 Standard Tier (Consumer Grade)

| Device Class | Example Hardware | Capability | Intensity Range | Safety Classification |
|-------------|------------------|------------|-----------------|----------------------|
| Gamepad Vibration | DualSense, Xbox | Basic pulses, rumble | 0-100% | Safe (All Ratings) |
| Trigger Haptics | DualSense | Adaptive triggers | 0-100% | Safe (All Ratings) |
| Basic Haptic Vest | bHaptics TactSuit | 8-16 motor zones | 0-80% | Safe (18+ with consent) |

### 2.2 Premium Tier (Enthusiast Grade)

| Device Class | Example Hardware | Capability | Intensity Range | Safety Classification |
|-------------|------------------|------------|-----------------|----------------------|
| Advanced Haptic Vest | Woojer Vest Pro | 20+ motor zones, bass | 0-90% | Safe (18+ with consent) |
| Subpac Backpack | Subpac M2 | Low-frequency tactile | 0-85% | Safe (18+ with consent) |
| Full Haptic Suit | bHaptics Full Suit | 40+ motor zones | 0-75% | Safe (18+ with consent) |

### 2.3 Research Tier (Experimental)

| Device Class | Example Hardware | Capability | Intensity Range | Safety Classification |
|-------------|------------------|------------|-----------------|----------------------|
| Ultrasound Mid-Air | Ultraleap Stratos | Contactless tactile | 0-60% | Research (18+ IRB approved) |
| Thermal Feedback | Thermal Touch | Temperature shifts | 15-40°C | Research (18+ IRB approved) |
| Electrotactile | Research prototypes | Electrical stimulation | 0-30% | Research (18+ IRB approved) |

***

## 3. Haptic-Horror Correlation Matrix

### 3.1 Primary Correlations (Validated)

| Haptic Parameter | Horror Invariant | Correlation | Use Case |
|-----------------|-----------------|-------------|----------|
| Vibration Intensity | CIC (Catastrophic Imprint) | Direct | Higher CIC = stronger rumble during events |
| Pulse Frequency | DET (Dread Exposure) | Inverse | Lower DET = faster heartbeat-like pulses |
| Spatial Pattern | HVF (Haunt Vector Field) | Directional | Pulses follow haunt vector direction |
| Duration | SHCI (Spectral Coupling) | Direct | Higher SHCI = longer sustained haptics |
| Onset Latency | STCI (Safe-Threat Contrast) | Inverse | Higher STCI = shorter delay before haptic spike |

### 3.2 Haptic Event Types

```yaml
haptic_event_types:
  
  # Fear Simulation Events
  heartbeat_pulse:
    description: "Simulated heartbeat pattern"
    intensity_range: { min: 0.20, max: 0.60 }
    frequency: "1.0-2.0 Hz"
    safety: "safe"
    invariant_trigger: "UEC > 0.5 OR DET < 0.6"
    
  dread_vibration:
    description: "Low-frequency dread rumble"
    intensity_range: { min: 0.30, max: 0.70 }
    frequency: "0.5-5.0 Hz"
    safety: "safe"
    invariant_trigger: "CIC > 0.6 AND SPR > 0.5"
    
  spectral_touch:
    description: "Light, fleeting tactile sensation"
    intensity_range: { min: 0.10, max: 0.40 }
    duration: "0.1-0.5 seconds"
    safety: "safe"
    invariant_trigger: "SHCI > 0.4 AND MDI > 0.5"
    
  # Pain Simulation Events (Safe Bounds Only)
  pressure_simulation:
    description: "Simulated pressure/pain (non-exceeding)"
    intensity_range: { min: 0.40, max: 0.65 }  # Capped for safety
    duration_max: "2.0 seconds"
    safety: "moderate_caution"
    invariant_trigger: "CIC > 0.8 AND DET < 0.4"
    wellness_check_required: true
    
  constriction_simulation:
    description: "Simulated tightness/constriction"
    intensity_range: { min: 0.35, max: 0.60 }
    duration_max: "3.0 seconds"
    safety: "moderate_caution"
    invariant_trigger: "AOS > 0.7 AND RRM > 0.6"
    wellness_check_required: true
    
  # Touch Simulation Events
  phantom_touch:
    description: "Simulated unseen touch"
    intensity_range: { min: 0.15, max: 0.45 }
    pattern: "single_pulse_or_light_stroke"
    safety: "safe"
    invariant_trigger: "SPR > 0.6 AND SHCI > 0.5"
    
  environmental_contact:
    description: "Simulated environmental touch (walls, objects)"
    intensity_range: { min: 0.20, max: 0.50 }
    pattern: "continuous_while_contact"
    safety: "safe"
    invariant_trigger: "LSG > 0.5"
    
  # Advanced Events (Research Tier)
  thermal_shift:
    description: "Simulated temperature change"
    temperature_range: { min: 18, max: 32 }  # Celsius, safe bounds
    duration_max: "5.0 seconds"
    safety: "research_only"
    invariant_trigger: "CIC > 0.7 AND RRM > 0.7"
    irb_approval_required: true
    
  mid_air_tactile:
    description: "Contactless tactile sensation"
    intensity_range: { min: 0.20, max: 0.50 }
    safety: "research_only"
    invariant_trigger: "SHCI > 0.8 AND SPR > 0.7"
    irb_approval_required: true
```

***

## 4. Safety and Wellness Protocols

### 4.1 Mandatory Safety Caps

```yaml
safety_caps:
  version: "1.0.0"
  
  intensity_limits:
    standard_tier_max: 0.80  # 80% intensity
    premium_tier_max: 0.75   # 75% intensity (more zones = lower per-zone)
    research_tier_max: 0.60  # 60% intensity (experimental)
    
  duration_limits:
    continuous_max_seconds: 10
    pulse_burst_max_seconds: 3
    cooldown_between_events_seconds: 2
    
  frequency_limits:
    safe_range_hz: { min: 0.5, max: 200 }
    infrasound_prohibited: true  # < 20 Hz prohibited
    ultrasonic_prohibited: true   # > 20 kHz prohibited
    
  pain_simulation_caps:
    maximum_intensity: 0.65  # Never exceed 65% for pain simulation
    maximum_duration: 2.0    # Never exceed 2 seconds
    mandatory_cooldown: 30   # 30 second cooldown after pain event
    wellness_check_before: true
```

### 4.2 Wellness Monitoring

```yaml
wellness_monitoring:
  required: true
  
  pre_event_checks:
    - "session_duration < 90 minutes"
    - "last_pain_event > 30 seconds ago"
    - "user_consent_active"
    - "wellness_opt_out_not_triggered"
    
  during_event_monitoring:
    - "real_time_intensity_tracking"
    - "user_pause_detection"
    - "emergency_stop_available"
    
  post_event_logging:
    - "event_intensity"
    - "event_duration"
    - "user_response"
    - "wellness_flags"
```

### 4.3 User Consent Framework

```yaml
consent_framework:
  version: "1.0.0"
  
  required_disclosures:
    - "haptic_feedback_will_be_used"
    - "pain_simulation_included"
    - "intensity_ranges_explained"
    - "opt_out_available_anytime"
    - "emergency_stop_instructions"
    - "potential_discomfort_warning"
    - "medical_contraindications"
    
  consent_levels:
    - level: "none"
      description: "No haptic feedback"
      
    - level: "basic"
      description: "Standard controller vibration only"
      pain_simulation: false
      
    - level: "moderate"
      description: "Premium haptic devices, no pain simulation"
      pain_simulation: false
      
    - level: "advanced"
      description: "Full haptic experience including safe pain simulation"
      pain_simulation: true
      age_gate: "18+"
      explicit_consent_required: true
      
  renewal_requirements:
    session_based: true
    expiration: "end_of_session"
    reconsent_on_intensity_increase: true
```

***

## 5. Haptic Event Specification Language

### 5.1 Haptic Event Definition Format

```yaml
# File: haptic_events/manifestation_pulse.yaml
haptic_event:
  event_id: "manifestation_pulse_01"
  version: "1.0.0"
  
  metadata:
    name: "Spectral Manifestation Pulse"
    description: "Rhythmic pulse pattern when spectral entity manifests"
    horror_category: "spectral_presence"
    intensity_tier: "moderate"
    
  invariant_requirements:
    CIC: { min: 0.5 }
    SHCI: { min: 0.6 }
    SPR: { min: 0.5 }
    
  haptic_parameters:
    device_targets:
      - "controller_vibration"
      - "haptic_vest"
      - "full_suit"
      
    pattern:
      type: "rhythmic_pulse"
      base_frequency_hz: 1.5
      variation_range: 0.3
      pulses_per_cycle: 3
      cycle_duration_seconds: 2.0
      
    intensity:
      base: 0.45
      scaling:
        by_CIC: 0.3  # Intensity increases with CIC
        by_SHCI: 0.2 # Intensity increases with SHCI
        by_DET: -0.1 # Intensity decreases if DET is high (safer area)
      max_cap: 0.70
      
    spatial_distribution:
      controller: "both_motors_balanced"
      vest: "chest_and_back_synchronized"
      suit: "full_body_wave_pattern"
      
    duration:
      base_seconds: 3.0
      fade_in_seconds: 0.3
      fade_out_seconds: 0.5
      loop_enabled: false
      
  safety_parameters:
    wellness_check_required: false
    maximum_intensity: 0.70
    cooldown_seconds: 5.0
    emergency_stop_enabled: true
    
  audio_visual_sync:
    audio_cue: "spectral_manifestation"
    visual_effect: "entity_appear"
    sync_tolerance_ms: 50
```

### 5.2 Haptic Scripting API (Lua Reference)

```lua
-- File: horror_place_haptic/lua/haptic_api.lua
-- Status: Reference Implementation - Optional Feature

Horror.Haptic = Horror.Haptic or {}

-- Check if haptic system is available
function Horror.Haptic.IsAvailable()
    return false  -- Default: disabled
end

-- Get user consent level
function Horror.Haptic.GetConsentLevel()
    return "none"  -- Default: no consent
end

-- Trigger haptic event by ID
function Horror.Haptic.TriggerEvent(event_id, intensity_override)
    -- Reference implementation only
end

-- Trigger heartbeat pattern
function Horror.Haptic.Heartbeat(intensity, frequency_hz, duration_seconds)
    -- intensity: 0.0 - 1.0
    -- frequency_hz: 0.5 - 3.0
    -- duration_seconds: 0.0 - 10.0
end

-- Trigger dread rumble
function Horror.Haptic.DreadRumble(intensity, duration_seconds)
    -- intensity: 0.0 - 1.0
    -- duration_seconds: 0.0 - 5.0
end

-- Trigger spectral touch (light, fleeting)
function Horror.Haptic.SpectralTouch(intensity, location)
    -- intensity: 0.0 - 0.5
    -- location: "left", "right", "front", "back", "random"
end

-- Trigger pain simulation (safe bounds only)
function Horror.Haptic.PainSimulation(intensity, duration_seconds)
    -- intensity: 0.0 - 0.65 (capped for safety)
    -- duration_seconds: 0.0 - 2.0 (capped for safety)
    -- Requires wellness check
end

-- Stop all haptic feedback immediately
function Horror.Haptic.StopAll()
end

-- Set global intensity scale (user preference)
function Horror.Haptic.SetGlobalScale(scale)
    -- scale: 0.0 - 1.0
end

-- Get current haptic device info
function Horror.Haptic.GetDeviceInfo()
    return {
        device_type = "none",
        zones_available = 0,
        intensity_cap = 0.0
    }
end
```

***

## 6. CI/CD Pipeline Integration (Optional)

### 6.1 Build Configuration

```yaml
# horror_place_ci_config.yml
haptic_feedback:
  enabled: false  # Default: disabled
  require_explicit_opt_in: true
  
  build_tiers:
    - tier: "standard"
      haptic_features: ["controller_vibration"]
      target: "production"
      
    - tier: "premium"
      haptic_features: ["controller_vibration", "haptic_vest", "full_suit"]
      target: "premium_releases"
      age_gate: "18+"
      
    - tier: "research"
      haptic_features: ["all_features", "thermal", "ultrasound", "electrotactile"]
      target: "research_institutions"
      irb_approval_required: true
      age_gate: "18+"
```

### 6.2 Validation Checkpoints

```yaml
validation_gates:
  - gate: "pre_build"
    checks:
      - "haptic_module_not_included_unless_flagged"
      - "safety_caps_enforced_in_code"
      - "consent_flow_implemented"
      
  - gate: "pre_release"
    checks:
      - "intensity_limits_verified"
      - "emergency_stop_tested"
      - "wellness_monitoring_active"
      
  - gate: "post_deployment"
    checks:
      - "user_consent_logs_retained"
      - "safety_incident_reporting_active"
      - "intensity_audit_completed"
```

***

## 7. Implementation Reference Code

### 7.1 Rust Haptic Module (Optional)

```rust
// File: horror_place_haptic/src/haptic_interface.rs
// Status: Reference Implementation - Optional Feature

pub mod haptic_interface {
    use std::sync::Arc;
    
    /// Haptic device interface (optional module)
    pub trait HapticDevice: Send + Sync {
        fn trigger_vibration(&self, intensity: f32, duration_ms: u32) -> bool;
        fn trigger_pattern(&self, pattern_id: &str, intensity: f32) -> bool;
        fn stop_all(&self) -> bool;
        fn is_connected(&self) -> bool;
        fn get_device_info(&self) -> DeviceInfo;
    }
    
    /// Device information
    #[derive(Debug, Clone)]
    pub struct DeviceInfo {
        pub device_type: String,
        pub zones: u32,
        pub max_intensity: f32,
        pub capabilities: Vec<String>,
    }
    
    /// Haptic event definition
    #[derive(Debug, Clone)]
    pub struct HapticEvent {
        pub event_id: String,
        pub pattern: HapticPattern,
        pub intensity_base: f32,
        pub intensity_scale: IntensityScale,
        pub duration_ms: u32,
        pub safety_level: SafetyLevel,
    }
    
    /// Haptic pattern types
    #[derive(Debug, Clone)]
    pub enum HapticPattern {
        RhythmicPulse { frequency_hz: f32, pulses: u32 },
        ContinuousRumble { frequency_range: (f32, f32) },
        SingleBurst { sharpness: f32 },
        WavePattern { direction: String, speed: f32 },
    }
    
    /// Intensity scaling based on invariants
    #[derive(Debug, Clone)]
    pub struct IntensityScale {
        pub by_cic: f32,
        pub by_shci: f32,
        pub by_det: f32,
        pub max_cap: f32,
    }
    
    /// Safety classification
    #[derive(Debug, Clone, PartialEq)]
    pub enum SafetyLevel {
        Safe,
        ModerateCaution,
        ResearchOnly,
    }
    
    /// Wellness manager for haptic safety
    pub struct HapticWellnessManager {
        pub last_pain_event_time: Option<u64>,
        pub session_start_time: u64,
        pub consent_level: ConsentLevel,
        pub intensity_history: Vec<(u64, f32)>,
    }
    
    #[derive(Debug, Clone, PartialEq)]
    pub enum ConsentLevel {
        None,
        Basic,
        Moderate,
        Advanced,
    }
    
    impl HapticWellnessManager {
        pub fn can_trigger_pain_simulation(&self) -> bool {
            // Check cooldown, consent, session duration
            true
        }
        
        pub fn log_event(&mut self, intensity: f32) {
            // Log for safety auditing
        }
    }
}
```

***

## 8. Research Validation Framework

### 8.1 Study Design for Haptic Horror

```yaml
research_protocols:
  study_type: "user_experience_validation"
  minimum_sample_size: 50
  statistical_power: 0.80
  
  primary_measures:
    - "fear_intensity_ratings"
    - "immersion_scores"
    - "presence_questionnaire"
    - "physiological_arousal"
    - "haptic_comfort_ratings"
    
  secondary_measures:
    - "memory_retention_of_events"
    - "narrative_engagement"
    - "willingness_to_repeat"
    
  control_conditions:
    - "audio_visual_only"
    - "basic_haptics_only"
    - "full_haptics"
    
  analysis_methods:
    - "anova_comparisons"
    - "correlation_with_invariants"
    - "qualitative_feedback_analysis"
```

### 8.2 Validation Milestones

| Phase | Objective | Sample Size | Validation Target |
|-------|-----------|-------------|-------------------|
| Pilot | Feasibility | 10 | Device compatibility, safety |
| Alpha | Effectiveness | 25 | Immersion improvement > 20% |
| Beta | Safety Validation | 50 | No adverse events, comfort > 7/10 |
| Release | Production Validation | 200+ | Replicable across user groups |

***

## 9. Ethical Considerations

### 9.1 Pain Simulation Ethics

**Guiding Principle:** Pain simulation must never cause actual harm or lasting discomfort.

```yaml
pain_simulation_ethics:
  prohibited:
    - "intensity_causing_actual_pain"
    - "duration_causing_muscle_fatigue"
    - "frequency_causing_nausea"
    - "patterns_mimicking_medical_conditions"
    
  required:
    - "clear_distinction_from_actual_pain"
    - "user_control_at_all_times"
    - "immediate_stop_mechanism"
    - "pre_experience_education"
    
  contraindications:
    - "chronic_pain_conditions"
    - "fibromyalgia"
    - "neuropathy"
    - "recent_injury"
    - "pregnancy"
```

### 9.2 Informed Consent Requirements

```yaml
consent_requirements:
  must_include:
    - "clear_description_of_haptic_types"
    - "pain_simulation_explanation"
    - "intensity_ranges_with_examples"
    - "opt_out_instructions"
    - "emergency_stop_location"
    - "potential_side_effects"
    - "right_to_withdraw"
    
  must_verify:
    - "age_18_or_older"
    - "understanding_of_content"
    - "voluntary_participation"
    - "no_coercion"
```

***

## 10. Future Extension Points

### 10.1 Reserved for Future Versions

| Extension ID | Description | Target Version |
|-------------|-------------|----------------|
| HAPTIC_EXT_001 | Biometric-responsive haptics | 2.0.0 |
| HAPTIC_EXT_002 | Multi-user synchronized haptics | 2.0.0 |
| HAPTIC_EXT_003 | AI-generated haptic patterns | 2.5.0 |
| HAPTIC_EXT_004 | Clinical therapeutic applications | 3.0.0 (Research Only) |

***

## 11. Compliance Checklist

### 11.1 Required for Premium Tier Deployment

- [ ] Age verification system active (18+)
- [ ] Informed consent flow implemented
- [ ] Safety caps enforced in code
- [ ] Emergency stop mechanism tested
- [ ] Wellness monitoring active
- [ ] User preference system functional
- [ ] Intensity audit logging enabled
- [ ] Contraindication screening implemented

### 11.2 Required for Research Tier Deployment

- [ ] All Premium Tier requirements met
- [ ] IRB approval documentation on file
- [ ] Medical supervision available
- [ ] Data anonymization confirmed
- [ ] Participant debriefing protocol
- [ ] Adverse event reporting system

### 11.3 Required for Standard Deployment

- [ ] Haptic module excluded or limited to basic vibration
- [ ] No pain simulation included
- [ ] Safety caps enforced
- [ ] User can disable all haptics

***

## 12. Document Metadata

| Field | Value |
|-------|-------|
| Document ID | HAPTIC_SPEC_001 |
| Version | 1.0.0 |
| Status | Reference Implementation |
| Classification | Optional/Advanced Feature |
| Age Gate | 18+ Required (for advanced features) |
| IRB Alignment | Yes (for research tier) |
| Production Ready | Partial (basic features only) |
| Last Updated | 2026-03-31 |
| Next Review | 2026-09-30 |

***

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| Haptic | Relating to the sense of touch |
| Tactile Feedback | Physical sensation delivered through devices |
| Pain Simulation | Simulated sensation of pain within safe bounds |
| Intensity Cap | Maximum allowed haptic intensity for safety |
| Wellness Check | Pre-event safety verification |
| IRB | Institutional Review Board - ethics committee |

***

## Appendix B: Device Compatibility Matrix

| Device | Support Level | Integration Complexity | Cost Tier |
|--------|--------------|----------------------|-----------|
| DualSense | Full | Low | Consumer |
| Xbox Controller | Full | Low | Consumer |
| bHaptics TactSuit | Full | Medium | Enthusiast |
| Woojer Vest | Full | Medium | Enthusiast |
| Subpac | Full | Low | Enthusiast |
| Ultraleap | Reference Only | High | Research |
| Thermal Touch | Reference Only | High | Research |

***

## Appendix C: Safety Incident Reporting Template

```yaml
incident_report:
  report_id: "HAPTIC_INC_001"
  timestamp: "2026-03-31T12:00:00Z"
  severity: "low|medium|high|critical"
  
  incident_details:
    event_type: "user_discomfort|device_malfunction|safety_breach"
    intensity_at_incident: 0.0
    duration_at_incident: 0.0
    user_consent_level: "none|basic|moderate|advanced"
    
  user_information:
    age_verified: true
    contraindications_screened: true
    prior_incidents: false
    
  response_taken:
    immediate_stop_triggered: true
    user_informed: true
    medical_attention_required: false
    
  corrective_actions:
    - "action_description"
    
  prevention_measures:
    - "measure_description"
```

***

**END OF SPECIFICATION**

*This document is part of the Horror$Place core specification suite. Haptic feedback is an optional extension for enhanced horror experiences. All implementations must prioritize user safety and consent.*
