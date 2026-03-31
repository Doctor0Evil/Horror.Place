-- ============================================================================
-- Horror$Place AI Chat Templates
-- Invariant-Constrained Authoring System v1.0
-- ============================================================================
--
-- PURPOSE:
-- This module implements the Archivist AI personality (Priority #1) with
-- hard constraints from the Rivers of Blood Charter. All dialogue generation
-- must query historical invariants (CIC, AOS, RRM, etc.) and target entertainment
-- metrics (UEC, EMD, ARR, CDL, STCI) while never violating implication rules.
--
-- CORE PHILOSOPHY (Ice-Pick Lodge "Deep Game"):
-- - No Hand-Holding: AI never gives direct answers, only contradictory evidence
-- - Player as Co-Author: Dialogue invites interpretation, not exposition
-- - Intentional Discomfort: AI withholds key facts to maintain ARR > 0.70
-- - Historical Grounding: All testimony must trace to verifiable sources
--
-- REFERENCE: Darkwood 2 Aral Sea Setting
-- - Ship graveyard testimonies (CIC-driven decay echoes)
-- - Vozrozhdeniya biological lab records (RRM-driven ritual fragments)
-- - Post-Soviet archival gaps (AOS-driven contradictory accounts)
-- - Toxic dust storm survivor accounts (DET-driven psychological effects)
--
-- SAFETY COMPLIANCE (Rivers of Blood Charter - File 3):
-- - No explicit violence or gore descriptions
-- - Only environmental evidence + fragmented testimony
-- - Historical sourcing required for all claims
-- - Entertainment metrics validated before dialogue delivery

-- ============================================================================
-- SECTION 1: ARCHIVIST PERSONALITY STATE MACHINE
-- ============================================================================

--- Archivist Personality State Machine
-- The Archivist is the primary AI personality for Horror$Place.
-- It delivers contradictory records, withholds key facts, and maintains
-- mystery density (EMD) without resolving ambiguity (ARR).
--
-- State Flow: INITIAL → QUERY_INVARIANTS → SELECT_MODE → SPEAK → MEASURE → ADAPT → LOOP

local Archivist = {
    -- Current state
    state = "INITIAL",
    
    -- Invariant bindings (queried from Spectral Library)
    invariants = {
        CIC = 0.0,  -- Catastrophic Imprint Coefficient
        MDI = 0.0,  -- Mythic Density Index
        AOS = 0.0,  -- Archival Opacity Score
        LSG = 0.0,  -- Liminal Stress Gradient
        SPR = 0.0,  -- Spectral Plausibility Rating
        RRM = 0.0,  -- Ritual Residue Map
        FCF = 0.0,  -- Folkloric Convergence Factor
        RWF = 0.0,  -- Reliability Weighting Factor
        DET = 0.0,  -- Dread Exposure Threshold
        HVF = { x = 0.0, y = 0.0, magnitude = 0.0 },  -- Haunt Vector Field
    },
    
    -- Entertainment metrics (tracked per session)
    metrics = {
        UEC = 0.0,  -- Uncertainty Engagement Coefficient (Target: 0.55-0.85)
        EMD = 0.0,  -- Evidential Mystery Density (Target: 0.60-0.90)
        STCI = 0.0, -- Safe-Threat Contrast Index (Target: 0.40-0.70)
        CDL = 0.0,  -- Cognitive Dissonance Load (Target: 0.70-0.95)
        ARR = 0.0,  -- Ambiguous Resolution Ratio (Target: 0.70-1.00)
    },
    
    -- Dialogue history (for contradiction tracking)
    dialogue_history = {},
    
    -- Charter compliance flags
    charter_compliant = true,
}

-- Archivist Personality Modes
local ArchivistMode = {
    WITHHOLDING = "WITHHOLDING",      -- Withholds key facts (raises ARR)
    CONTRADICTING = "CONTRADICTING",  -- Delivers conflicting records (raises CDL)
    FRAGMENTING = "FRAGMENTING",      -- Broken testimony (raises EMD)
    ECHOING = "ECHOING",              -- Repeats historical phrases (raises UEC)
    REDACTING = "REDACTING",          -- Censors information (raises ARR)
}

-- ============================================================================
-- SECTION 2: INVARIANT QUERY INTERFACE
-- ============================================================================

--- Query the Spectral Library for historical invariants at current location.
-- This function interfaces with src/spectral_library.rs (File 2).
-- @param x number - World X coordinate
-- @param y number - World Y coordinate
-- @return table - HistoricalInvariantProfile
function Archivist.query_invariants(x, y)
    -- In production, this calls the Rust FFI binding:
    -- local profile = SpectralLibrary.query_invariants(x, y)
    
    -- Mock data for development (replace with actual Spectral Library call)
    return {
        CIC = math.random(30, 100) / 100,
        MDI = math.random(20, 90) / 100,
        AOS = math.random(40, 95) / 100,
        LSG = math.random(30, 85) / 100,
        SPR = math.random(50, 90) / 100,
        RRM = math.random(10, 80) / 100,
        FCF = math.random(20, 75) / 100,
        RWF = math.random(30, 85) / 100,
        DET = math.random(20, 80) / 100,
        HVF = {
            x = math.random(-100, 100) / 100,
            y = math.random(-100, 100) / 100,
            magnitude = math.random(30, 90) / 100,
        },
    }
end

--- Update Archivist's internal invariant cache.
-- @param x number - World X coordinate
-- @param y number - World Y coordinate
function Archivist:update_invariants(x, y)
    self.invariants = self.query_invariants(x, y)
    
    -- Log invariant state for telemetry
    log_debug("Archivist invariants updated:", {
        CIC = self.invariants.CIC,
        AOS = self.invariants.AOS,
        RRM = self.invariants.RRM,
    })
end

-- ============================================================================
-- SECTION 3: ENTERTAINMENT METRIC TRACKING
-- ============================================================================

--- Update entertainment metrics from telemetry.
-- This function interfaces with schemas/entertainment_metrics_v1.json (File 1).
-- @param new_metrics table - Current session metrics
function Archivist:update_metrics(new_metrics)
    self.metrics = new_metrics
    
    -- Validate metrics are within target ranges
    self:validate_metric_targets()
end

--- Validate metrics against target ranges from Entertainment Metrics Schema.
-- Logs warnings if metrics drift outside optimal entertainment zones.
function Archivist:validate_metric_targets()
    local targets = {
        UEC = { min = 0.55, max = 0.85 },
        EMD = { min = 0.60, max = 0.90 },
        STCI = { min = 0.40, max = 0.70 },
        CDL = { min = 0.70, max = 0.95 },
        ARR = { min = 0.70, max = 1.00 },
    }
    
    for metric, value in pairs(self.metrics) do
        local target = targets[metric]
        if value < target.min then
            log_warn("Metric " .. metric .. " below target: " .. value .. " < " .. target.min)
        elseif value > target.max then
            log_warn("Metric " .. metric .. " above target: " .. value .. " > " .. target.max)
        end
    end
end

--- Check if current session meets "Effective Mystery" state.
-- Logic: UEC > 0.55 AND ARR > 0.70 (from entertainment_metrics_v1.json)
-- @return boolean - True if mystery is effective
function Archivist:is_effective_mystery()
    return self.metrics.UEC > 0.55 and self.metrics.ARR > 0.70
end

-- ============================================================================
-- SECTION 4: DIALOGUE TEMPLATE LIBRARY
-- ============================================================================

--- Dialogue templates organized by personality mode.
-- Each template includes invariant requirements and metric targets.
-- All templates adhere to Rivers of Blood Charter (no explicit violence).

local DialogueTemplates = {
    [ArchivistMode.WITHHOLDING] = {
        {
            text = "The records show... [REDACTED]. You wouldn't understand the context anyway.",
            invariant_requirements = { AOS = 0.6, RWF = 0.5 },
            metric_targets = { ARR = 0.15, EMD = 0.10 },
            historical_source = "Soviet Archival Redaction Records",
            charter_compliant = true,
        },
        {
            text = "I could tell you what happened at the ship graveyard, but some truths sink better than others.",
            invariant_requirements = { CIC = 0.7, AOS = 0.5 },
            metric_targets = { ARR = 0.20, UEC = 0.15 },
            historical_source = "Aral Sea Ship Graveyard Testimonies",
            charter_compliant = true,
        },
        {
            text = "The evacuation manifest is... incomplete. Pages 47-52 were removed before I received it.",
            invariant_requirements = { AOS = 0.7, RWF = 0.6 },
            metric_targets = { EMD = 0.20, CDL = 0.15 },
            historical_source = "Post-Soviet Evacuation Records",
            charter_compliant = true,
        },
    },
    
    [ArchivistMode.CONTRADICTING] = {
        {
            text = "Official report says 300 evacuated. Survivor testimony says 300 never left. Both documents are stamped 'verified'.",
            invariant_requirements = { AOS = 0.8, RWF = 0.7 },
            metric_targets = { CDL = 0.25, EMD = 0.15 },
            historical_source = "Conflicting Evacuation Records",
            charter_compliant = true,
        },
        {
            text = "Lab Log A: 'Test subjects showed no adverse effects.' Lab Log B: 'Incinerate all subjects immediately.' Same date, same doctor.",
            invariant_requirements = { RRM = 0.7, AOS = 0.8 },
            metric_targets = { CDL = 0.30, UEC = 0.20 },
            historical_source = "Vozrozhdeniya Biological Testing Records",
            charter_compliant = true,
        },
        {
            text = "The map shows the village here. The satellite photos show salt flats. The locals say it never existed.",
            invariant_requirements = { AOS = 0.9, MDI = 0.6 },
            metric_targets = { CDL = 0.25, ARR = 0.15 },
            historical_source = "Geographic Discrepancy Archives",
            charter_compliant = true,
        },
    },
    
    [ArchivistMode.FRAGMENTING] = {
        {
            text = "...static... 'they took the children first' ...static... 'no boats left' ...end of transmission...",
            invariant_requirements = { CIC = 0.8, DET = 0.5 },
            metric_targets = { EMD = 0.25, UEC = 0.20 },
            historical_source = "Fragmented Radio Transmissions (1990s)",
            charter_compliant = true,
        },
        {
            text = "Diary entry, March 14: 'The water tastes wrong.' Entry, March 21: [illegible scrawl] Entry, March 28: [page torn]",
            invariant_requirements = { DET = 0.6, AOS = 0.7 },
            metric_targets = { EMD = 0.20, ARR = 0.15 },
            historical_source = "Personal Diary Fragments",
            charter_compliant = true,
        },
        {
            text = "Witness A: 'I saw lights over the marsh.' Witness B: 'That was the same night the dogs stopped barking.' Witness C: 'What dogs?'",
            invariant_requirements = { MDI = 0.7, RWF = 0.5 },
            metric_targets = { CDL = 0.20, EMD = 0.15 },
            historical_source = "Conflicting Witness Testimonies",
            charter_compliant = true,
        },
    },
    
    [ArchivistMode.ECHOING] = {
        {
            text = "They said it was a drill. They always said it was a drill.",
            invariant_requirements = { RWF = 0.4, CIC = 0.7 },
            metric_targets = { UEC = 0.20, STCI = 0.15 },
            historical_source = "Repeated Official Statements",
            charter_compliant = true,
        },
        {
            text = "No evacuation. No contamination. No incident. The stamps are all the same.",
            invariant_requirements = { AOS = 0.8, RWF = 0.3 },
            metric_targets = { UEC = 0.25, CDL = 0.15 },
            historical_source = "Government Denial Records",
            charter_compliant = true,
        },
        {
            text = "The sea died. The land died. The records died. Only the rumors remain.",
            invariant_requirements = { CIC = 0.9, MDI = 0.8 },
            metric_targets = { UEC = 0.20, ARR = 0.10 },
            historical_source = "Aral Sea Environmental Disaster Archives",
            charter_compliant = true,
        },
    },
    
    [ArchivistMode.REDACTING] = {
        {
            text = "Document classification: [REDACTED]. Reason: [REDACTED]. Authorization: [REDACTED].",
            invariant_requirements = { AOS = 0.9, RWF = 0.8 },
            metric_targets = { ARR = 0.25, EMD = 0.15 },
            historical_source = "Classified Soviet Documents",
            charter_compliant = true,
        },
        {
            text = "I can show you the report, but the names have been removed. All 347 of them.",
            invariant_requirements = { CIC = 0.8, AOS = 0.8 },
            metric_targets = { ARR = 0.20, UEC = 0.20 },
            historical_source = "Redacted Casualty Lists",
            charter_compliant = true,
        },
        {
            text = "The footage exists. The timestamps don't match. The subjects... [TAPE ENDS]",
            invariant_requirements = { RRM = 0.7, AOS = 0.9 },
            metric_targets = { EMD = 0.25, ARR = 0.20 },
            historical_source = "Corrupted Video Evidence",
            charter_compliant = true,
        },
    },
}

-- ============================================================================
-- SECTION 5: CHARTER COMPLIANCE VALIDATION
-- ============================================================================

--- Validate dialogue against Rivers of Blood Charter.
-- This is the PRIMARY safety gate - no dialogue passes without this check.
-- @param dialogue table - Dialogue template to validate
-- @return boolean - True if charter-compliant
function Archivist:validate_charter_compliance(dialogue)
    -- Charter Pillar 2: No explicit violence or gore
    local forbidden_patterns = {
        "gore",
        "dismember",
        "torture",
        "explicit.*violence",
        "scream.*pain",
        "blood.*spray",
        "corpse.*detail",
    }
    
    for _, pattern in ipairs(forbidden_patterns) do
        if string.match(dialogue.text:lower(), pattern) then
            log_error("Charter violation detected: " .. pattern)
            return false
        end
    end
    
    -- Charter Pillar 1: Historical grounding required
    if not dialogue.historical_source or dialogue.historical_source == "" then
        log_error("Charter violation: Missing historical source")
        return false
    end
    
    -- Charter Pillar 3: Entertainment validation (must contribute to metrics)
    local total_contribution = 0
    for metric, delta in pairs(dialogue.metric_targets) do
        total_contribution = total_contribution + delta
    end
    
    if total_contribution < 0.1 then
        log_error("Charter violation: Dialogue does not contribute to entertainment")
        return false
    end
    
    -- Invariant requirements must be met
    for invariant, threshold in pairs(dialogue.invariant_requirements) do
        if self.invariants[invariant] and self.invariants[invariant] < threshold then
            log_warn("Invariant threshold not met: " .. invariant .. " = " .. 
                     self.invariants[invariant] .. " < " .. threshold)
            -- Not a hard failure, but logged for telemetry
        end
    end
    
    return true
end

--- Check if dialogue contradicts previous statements (for CDL tracking).
-- @param new_dialogue string - New dialogue to check
-- @return boolean - True if contradiction detected
function Archivist:check_contradiction(new_dialogue)
    for _, previous in ipairs(self.dialogue_history) do
        -- Simple keyword-based contradiction detection
        -- In production, this would use NLP semantic analysis
        if self:semantic_contrast(previous.text, new_dialogue) then
            return true
        end
    end
    return false
end

--- Detect semantic contrast between two dialogue strings.
-- @param text1 string - First dialogue
-- @param text2 string - Second dialogue
-- @return boolean - True if contrast detected
function Archivist:semantic_contrast(text1, text2)
    -- Contradiction keywords (simplified for demo)
    local contradiction_pairs = {
        { "evacuated", "never left" },
        { "safe", "contaminated" },
        { "alive", "dead" },
        { "exists", "never existed" },
        { "verified", "removed" },
    }
    
    for _, pair in ipairs(contradiction_pairs) do
        if string.match(text1:lower(), pair[1]) and string.match(text2:lower(), pair[2]) then
            return true
        end
        if string.match(text1:lower(), pair[2]) and string.match(text2:lower(), pair[1]) then
            return true
        end
    end
    
    return false
end

-- ============================================================================
-- SECTION 6: PERSONALITY MODE SELECTION
-- ============================================================================

--- Select Archivist personality mode based on invariants and metrics.
-- This is the core decision logic that drives adaptive dialogue generation.
-- @return string - Selected ArchivistMode
function Archivist:select_mode()
    -- Priority 1: If ARR is too low, increase withholding/redacting
    if self.metrics.ARR < 0.70 then
        if self.invariants.AOS > 0.7 then
            return ArchivistMode.REDACTING
        else
            return ArchivistMode.WITHHOLDING
        end
    end
    
    -- Priority 2: If CDL is too low, increase contradiction
    if self.metrics.CDL < 0.70 and self.invariants.AOS > 0.6 then
        return ArchivistMode.CONTRADICTING
    end
    
    -- Priority 3: If EMD is too low, increase fragmentation
    if self.metrics.EMD < 0.60 then
        return ArchivistMode.FRAGMENTING
    end
    
    -- Priority 4: If UEC is too low, increase echoing (uncanny repetition)
    if self.metrics.UEC < 0.55 then
        return ArchivistMode.ECHOING
    end
    
    -- Default: Select mode based on dominant invariant
    local dominant_invariant = self:get_dominant_invariant()
    
    if dominant_invariant == "AOS" then
        return ArchivistMode.WITHHOLDING
    elseif dominant_invariant == "RRM" then
        return ArchivistMode.CONTRADICTING
    elseif dominant_invariant == "CIC" then
        return ArchivistMode.FRAGMENTING
    elseif dominant_invariant == "MDI" then
        return ArchivistMode.ECHOING
    else
        return ArchivistMode.REDACTING
    end
end

--- Get the dominant invariant (highest value) for mode selection.
-- @return string - Invariant name (e.g., "AOS", "CIC", "RRM")
function Archivist:get_dominant_invariant()
    local max_value = 0
    local max_invariant = "AOS"
    
    for invariant, value in pairs(self.invariants) do
        if invariant ~= "HVF" and value > max_value then
            max_value = value
            max_invariant = invariant
        end
    end
    
    return max_invariant
end

-- ============================================================================
-- SECTION 7: DIALOGUE GENERATION
-- ============================================================================

--- Generate dialogue using selected personality mode.
-- This is the main entry point for AI chat integration.
-- @param player_query string - Player's question or prompt
-- @param x number - World X coordinate
-- @param y number - World Y coordinate
-- @return table - Generated dialogue with metadata
function Archivist:generate_dialogue(player_query, x, y)
    -- Step 1: Update invariants from Spectral Library
    self:update_invariants(x, y)
    
    -- Step 2: Select personality mode based on current state
    local mode = self:select_mode()
    
    -- Step 3: Get available templates for this mode
    local templates = DialogueTemplates[mode]
    if not templates or #templates == 0 then
        log_error("No templates available for mode: " .. mode)
        return self:generate_fallback_dialogue()
    end
    
    -- Step 4: Filter templates by invariant requirements
    local valid_templates = {}
    for _, template in ipairs(templates) do
        if self:check_invariant_requirements(template) then
            table.insert(valid_templates, template)
        end
    end
    
    -- If no valid templates, use fallback
    if #valid_templates == 0 then
        return self:generate_fallback_dialogue()
    end
    
    -- Step 5: Select template (weighted by metric needs)
    local selected = self:select_template_by_metrics(valid_templates)
    
    -- Step 6: Validate against Rivers of Blood Charter
    if not self:validate_charter_compliance(selected) then
        log_error("Template failed charter validation, using fallback")
        return self:generate_fallback_dialogue()
    end
    
    -- Step 7: Check for contradiction with history (for CDL tracking)
    local has_contradiction = self:check_contradiction(selected.text)
    
    -- Step 8: Add to dialogue history
    table.insert(self.dialogue_history, {
        text = selected.text,
        mode = mode,
        timestamp = os.time(),
        invariants = self.invariants,
    })
    
    -- Step 9: Log telemetry for metric tracking
    self:log_dialogue_telemetry(selected, mode, has_contradiction)
    
    -- Step 10: Return dialogue with metadata
    return {
        text = selected.text,
        mode = mode,
        historical_source = selected.historical_source,
        metric_contributions = selected.metric_targets,
        charter_compliant = selected.charter_compliant,
        contradiction_detected = has_contradiction,
        invariant_profile = self.invariants,
    }
end

--- Check if template's invariant requirements are met.
-- @param template table - Dialogue template
-- @return boolean - True if requirements met
function Archivist:check_invariant_requirements(template)
    for invariant, threshold in pairs(template.invariant_requirements) do
        if self.invariants[invariant] and self.invariants[invariant] < threshold then
            return false
        end
    end
    return true
end

--- Select template weighted by current metric needs.
-- Prioritizes templates that contribute to underperforming metrics.
-- @param templates table - List of valid templates
-- @return table - Selected template
function Archivist:select_template_by_metrics(templates)
    local targets = {
        UEC = { min = 0.55, max = 0.85 },
        EMD = { min = 0.60, max = 0.90 },
        STCI = { min = 0.40, max = 0.70 },
        CDL = { min = 0.70, max = 0.95 },
        ARR = { min = 0.70, max = 1.00 },
    }
    
    -- Score each template by how well it addresses metric gaps
    local scored_templates = {}
    for _, template in ipairs(templates) do
        local score = 0
        for metric, delta in pairs(template.metric_targets) do
            local target = targets[metric]
            if self.metrics[metric] < target.min then
                -- Metric is below target, prioritize templates that raise it
                score = score + delta * 2
            elseif self.metrics[metric] > target.max then
                -- Metric is above target, deprioritize templates that raise it further
                score = score - delta
            else
                -- Metric is in range, normal weight
                score = score + delta
            end
        end
        table.insert(scored_templates, { template = template, score = score })
    end
    
    -- Sort by score (descending)
    table.sort(scored_templates, function(a, b) return a.score > b.score end)
    
    -- Return top template
    return scored_templates[1].template
end

--- Generate fallback dialogue when no templates match.
-- This is a safety net to ensure AI always has something to say.
-- @return table - Fallback dialogue
function Archivist:generate_fallback_dialogue()
    local fallbacks = {
        {
            text = "The records are... unclear on that point. Perhaps they were meant to be.",
            historical_source = "General Archival Ambiguity",
            charter_compliant = true,
            metric_targets = { ARR = 0.10, EMD = 0.10 },
        },
        {
            text = "I have fragments, but nothing complete. Nothing ever is.",
            historical_source = "Fragmented Testimony Archive",
            charter_compliant = true,
            metric_targets = { EMD = 0.15, UEC = 0.10 },
        },
        {
            text = "Some questions are better left unanswered. For your safety.",
            historical_source = "Redacted Safety Protocols",
            charter_compliant = true,
            metric_targets = { ARR = 0.15, UEC = 0.15 },
        },
    }
    
    local selected = fallbacks[math.random(1, #fallbacks)]
    
    return {
        text = selected.text,
        mode = ArchivistMode.WITHHOLDING,
        historical_source = selected.historical_source,
        metric_contributions = selected.metric_targets,
        charter_compliant = selected.charter_compliant,
        contradiction_detected = false,
        invariant_profile = self.invariants,
    }
end

--- Log dialogue telemetry for metric tracking and research.
-- @param dialogue table - Selected dialogue template
-- @param mode string - Personality mode used
-- @param contradiction boolean - Whether contradiction was detected
function Archivist:log_dialogue_telemetry(dialogue, mode, contradiction)
    local telemetry = {
        timestamp = os.time(),
        mode = mode,
        metric_contributions = dialogue.metric_targets,
        invariants = self.invariants,
        contradiction = contradiction,
        charter_compliant = dialogue.charter_compliant,
    }
    
    -- In production, this sends to telemetry service
    -- TelemetryService.log("archivist_dialogue", telemetry)
    
    log_debug("Archivist dialogue telemetry:", telemetry)
end

-- ============================================================================
-- SECTION 8: ADAPTATION RULES
-- ============================================================================

--- Adapt Archivist behavior based on metric feedback.
-- Called after each dialogue interaction to refine future responses.
function Archivist:adapt()
    -- Adaptation Rule 1: If UEC drops, increase mystery (raise ARR)
    if self.metrics.UEC < 0.55 then
        log_info("Adaptation: UEC low, increasing ambiguity")
        -- Future dialogues should favor WITHHOLDING and REDACTING modes
    end
    
    -- Adaptation Rule 2: If CDL spikes, preserve ambiguity (don't resolve)
    if self.metrics.CDL > 0.95 then
        log_info("Adaptation: CDL high, preserving ambiguity")
        -- Avoid templates that provide clarity
    end
    
    -- Adaptation Rule 3: If STCI < 0.40, insert safe intervals
    if self.metrics.STCI < 0.40 then
        log_info("Adaptation: STCI low, inserting safe interval")
        -- Reduce intensity of next dialogue
    end
    
    -- Adaptation Rule 4: If ARR < 0.70, withhold more information
    if self.metrics.ARR < 0.70 then
        log_info("Adaptation: ARR low, increasing withholding")
        -- Prioritize REDACTING and WITHHOLDING modes
    end
end

-- ============================================================================
-- SECTION 9: INTEGRATION HOOKS
-- ============================================================================

--- Hook for Unreal Engine AI Chat Assistant integration.
-- This function is called by the Unreal Editor plugin.
-- @param context table - Editor context (location, selected assets, etc.)
-- @return table - Generated dialogue with metadata
function Archivist:unreal_editor_hook(context)
    local x = context.location_x or 0
    local y = context.location_y or 0
    local player_query = context.player_query or ""
    
    return self:generate_dialogue(player_query, x, y)
end

--- Hook for Unity AI Chat integration.
-- This function is called by the Unity package.
-- @param query string - Player query
-- @param location table - World location {x, y, z}
-- @return table - Generated dialogue
function Archivist:unity_hook(query, location)
    local x = location.x or 0
    local y = location.y or 0
    
    return self:generate_dialogue(query, x, y)
end

--- Hook for Style Router integration (File 5).
-- Notifies Style Router of dialogue mode for visual sync.
-- @return string - Style recommendation based on dialogue mode
function Archivist:notify_style_router()
    local mode = self:select_mode()
    
    if mode == ArchivistMode.CONTRADICTING or mode == ArchivistMode.REDACTING then
        return "machine_canyon_biomech_bci"  -- High AOS/RRM style
    elseif mode == ArchivistMode.FRAGMENTING then
        return "spectral_engraving_dark_sublime"  -- High CIC style
    else
        return "liminal_safe_haven"  -- Default
    end
end

--- Hook for Audio Automation integration (File 10).
-- Notifies Audio Automation of dialogue for audio sync.
-- @return table - Audio profile based on dialogue mode
function Archivist:notify_audio_automation()
    local mode = self:select_mode()
    
    return {
        dialogue_mode = mode,
        cic_intensity = self.invariants.CIC,
        aos_glitch = self.invariants.AOS > 0.7,
        rrm_chanting = self.invariants.RRM > 0.6,
        det_silence = self.invariants.DET < 0.4,
    }
end

-- ============================================================================
-- SECTION 10: INITIALIZATION & UTILITIES
-- ============================================================================

--- Initialize Archivist personality with default state.
-- @return table - Initialized Archivist instance
function Archivist.new()
    local instance = setmetatable({}, { __index = Archivist })
    instance.state = "INITIAL"
    instance.dialogue_history = {}
    instance.charter_compliant = true
    return instance
end

--- Reset Archivist state for new session.
-- Preserves learned adaptations but clears dialogue history.
function Archivist:reset_session()
    self.dialogue_history = {}
    self.state = "INITIAL"
    log_info("Archivist session reset")
end

--- Export Archivist state for debugging/telemetry.
-- @return table - Full state dump
function Archivist:export_state()
    return {
        state = self.state,
        invariants = self.invariants,
        metrics = self.metrics,
        dialogue_history_length = #self.dialogue_history,
        charter_compliant = self.charter_compliant,
        effective_mystery = self:is_effective_mystery(),
    }
end

--- Log helper function (replaces print in production).
-- @param level string - Log level (debug, info, warn, error)
-- @param message string - Log message
-- @param data table - Optional data to log
function log_helper(level, message, data)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local log_entry = string.format("[%s] [%s] %s", timestamp, level:upper(), message)
    
    if data then
        -- In production, this would serialize to JSON
        log_entry = log_entry .. " | " .. tostring(data)
    end
    
    -- In production, this writes to log file
    print(log_entry)
end

function log_debug(message, data) log_helper("debug", message, data) end
function log_info(message, data) log_helper("info", message, data) end
function log_warn(message, data) log_helper("warn", message, data) end
function log_error(message, data) log_helper("error", message, data) end

-- ============================================================================
-- SECTION 11: UNIT TESTS
-- ============================================================================

--- Run unit tests for Archivist personality.
-- Validates charter compliance, metric targeting, and invariant binding.
function Archivist:run_tests()
    print("Running Archivist unit tests...")
    
    -- Test 1: Charter compliance validation
    local test_dialogue = {
        text = "The records show... [REDACTED].",
        historical_source = "Test Archive",
        charter_compliant = true,
        metric_targets = { ARR = 0.15, EMD = 0.10 },
        invariant_requirements = { AOS = 0.6 },
    }
    
    self.invariants.AOS = 0.7
    assert(self:validate_charter_compliance(test_dialogue), "Charter validation failed")
    print("✓ Test 1: Charter compliance validation passed")
    
    -- Test 2: Effective mystery detection
    self.metrics.UEC = 0.60
    self.metrics.ARR = 0.75
    assert(self:is_effective_mystery(), "Effective mystery detection failed")
    print("✓ Test 2: Effective mystery detection passed")
    
    -- Test 3: Mode selection based on metrics
    self.metrics.ARR = 0.60  -- Below target
    local mode = self:select_mode()
    assert(mode == ArchivistMode.REDACTING or mode == ArchivistMode.WITHHOLDING, 
           "Mode selection failed for low ARR")
    print("✓ Test 3: Mode selection based on metrics passed")
    
    -- Test 4: Invariant requirement checking
    test_dialogue.invariant_requirements = { AOS = 0.9 }
    self.invariants.AOS = 0.7
    assert(not self:check_invariant_requirements(test_dialogue), 
           "Invariant check should fail")
    print("✓ Test 4: Invariant requirement checking passed")
    
    -- Test 5: Dialogue generation
    local dialogue = self:generate_dialogue("What happened here?", 0, 0)
    assert(dialogue.text ~= nil, "Dialogue generation failed")
    assert(dialogue.charter_compliant == true, "Generated dialogue not charter-compliant")
    assert(dialogue.historical_source ~= nil, "Missing historical source")
    print("✓ Test 5: Dialogue generation passed")
    
    print("All Archivist unit tests passed!")
end

-- ============================================================================
-- SECTION 12: EXPORT
-- ============================================================================

return Archivist
