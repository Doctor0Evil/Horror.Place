-- engine/surprisedirector.lua
--
-- The Surprise Director module manages the scheduling and execution of
-- Surprise.Events! based on regional invariants, current metrics,
-- and BCI feedback. It uses the H. API to check conditions and the
-- BCI. API to modulate timing and intensity.
--
-- This file is designed to be driven by data/contract files that
-- conform to schemas/eventcontract_v1.json.

local H   = require("engine.horror_invariants")
local BCI = require("engine.bci_adapter")

----------------------------------------------------------------------
-- Local tension probe (lightweight, for pacing hints)
----------------------------------------------------------------------

local Director = {
    last_event_time = 0.0,
    cooldown        = 15.0,   -- seconds between \"big\" Surprise.Events!
}

local function compute_local_tension(region_id, t)
    local cic  = H.CIC(region_id)
    local spr  = H.SPR(region_id)
    local lsg  = H.LSG(region_id)
    local fear = BCI.get_fear()

    local base = (cic * 0.4) + (spr * 0.3) + (lsg * 0.3)
    local mod  = (fear * 0.5)
    return math.min(1.0, base + mod)
end

local function should_trigger(region_id, t)
    local tension = compute_local_tension(region_id, t)
    local dt      = t - Director.last_event_time

    if dt < Director.cooldown then
        return false, tension
    end

    -- Only fire when tension is high but fear is below panic
    local fear = BCI.get_fear()
    local panic_threshold = 0.85
    if tension > 0.7 and fear < panic_threshold then
        return true, tension
    end

    return false, tension
end

----------------------------------------------------------------------
-- Contract‑driven Surprise.Events! scheduling and execution
----------------------------------------------------------------------

local SurpriseEventQueue = {}
local ActiveSurprises    = {}

-- SurpriseEventDefinition is a table keyed by event_id.
-- In production this should be hydrated from eventcontract_v1.json
-- files validated by the StyleLintRuntimeValidator.
local SurpriseEventDefinition = {
    --[[
    event_id = {
        event_id           = "water_whisper_01",
        name               = "Water Whisper",
        trigger_conditions = { CIC = {min = 0.5}, AOS = {min = 0.7} }, -- H. API
        bci_prerequisites  = { min_fear = 0.3 },                       -- BCI. API
        metrics_impact     = { UEC = 0.1, EMD = 0.15 },                -- for logging
        intensity_range    = { min = 0.3, max = 0.8 },
        cooldown_min       = 30,
        cooldown_max       = 120,
        duration_estimate  = 10,
        -- other properties from schemas/eventcontract_v1.json
    }
    ]]
}

----------------------------------------------------------------------
-- Registration
----------------------------------------------------------------------

local function register_surprise_event(def)
    if def and def.event_id then
        SurpriseEventDefinition[def.event_id] = def
        print("Surprise Director: Registered Surprise Event: " .. def.event_id)
    else
        print("Surprise Director ERROR: invalid Surprise Event definition.")
    end
end

----------------------------------------------------------------------
-- Preconditions and BCI gating
----------------------------------------------------------------------

local function can_trigger_event(event_def, current_region_id)
    -- 1. H. API preconditions (invariants)
    if event_def.trigger_conditions then
        if not H.evaluate_preconditions(current_region_id, event_def.trigger_conditions) then
            print("Surprise Director: Event '" .. event_def.event_id .. "' failed H. preconditions.")
            return false
        end
    end

    -- 2. BCI. API prerequisites (optional)
    if event_def.bci_prerequisites then
        if event_def.bci_prerequisites.min_fear then
            if BCI.get_fear() < event_def.bci_prerequisites.min_fear then
                print("Surprise Director: Event '" .. event_def.event_id .. "' failed BCI min_fear.")
                return false
            end
        end
        -- Further BCI checks (HRV, facial affect, etc.) can be added here.
    end

    -- 3. Cooldown (simple per‑event)
    local active_event = ActiveSurprises[event_def.event_id]
    if active_event and active_event.cooldown_remaining > 0 then
        -- Soft‑fail; event still on cooldown
        return false
    end

    return true
end

----------------------------------------------------------------------
-- Scheduling
----------------------------------------------------------------------

local function schedule_surprise_event(event_id, target_region_id)
    local event_def = SurpriseEventDefinition[event_id]
    if not event_def then
        print("Surprise Director: Unknown event_id '" .. tostring(event_id) .. "'.")
        return false
    end

    if not can_trigger_event(event_def, target_region_id) then
        print("Surprise Director: Conditions not met for '" .. event_id .. "'.")
        return false
    end

    -- Intensity based on design range; later, modulate by invariants/BCI.
    local min_int = event_def.intensity_range and event_def.intensity_range.min or 0.3
    local max_int = event_def.intensity_range and event_def.intensity_range.max or 0.8
    local intensity = min_int + math.random() * (max_int - min_int)

    local cooldown_min = event_def.cooldown_min or 30
    local cooldown_max = event_def.cooldown_max or 120
    local scheduled_time = os.clock() + math.random(cooldown_min, cooldown_max)

    local event_instance = {
        id           = event_id,
        definition   = event_def,
        target_region= target_region_id,
        scheduled_at = scheduled_time,
        intensity    = intensity,
        state        = "scheduled"  -- scheduled | active | finished
    }

    table.insert(SurpriseEventQueue, event_instance)
    print(string.format(
        "Surprise Director: Scheduled '%s' in '%s' at %.2f (intensity %.2f)",
        event_id, target_region_id, scheduled_time, intensity
    ))

    return true
end

----------------------------------------------------------------------
-- Execution
----------------------------------------------------------------------

local function execute_surprise_event(event_instance)
    if event_instance.state ~= "scheduled" then
        return
    end

    event_instance.state = "active"
    print(string.format(
        "Surprise Director: EXECUTING '%s' in '%s' (intensity %.2f)",
        event_instance.id, event_instance.target_region, event_instance.intensity
    ))

    -- Hook into rendering/audio/haptics systems here, using the
    -- event definition’s fields (audio_cue, visual_effect, haptic_pattern, etc.).

    -- Track cooldown using duration_estimate as a simple stand‑in.
    local duration = event_instance.definition.duration_estimate or 5
    ActiveSurprises[event_instance.id] = {
        cooldown_remaining = duration
    }

    -- Remove from queue
    for i, queued in ipairs(SurpriseEventQueue) do
        if queued == event_instance then
            table.remove(SurpriseEventQueue, i)
            break
        end
    end
end

----------------------------------------------------------------------
-- Main update loop
----------------------------------------------------------------------

local function update_surprise_director(dt)
    local current_time = os.clock()

    -- Update cooldowns
    for event_id, info in pairs(ActiveSurprises) do
        info.cooldown_remaining = info.cooldown_remaining - dt
        if info.cooldown_remaining <= 0 then
            ActiveSurprises[event_id] = nil
            print("Surprise Director: Event '" .. event_id .. "' cooldown expired.")
        end
    end

    -- Execute scheduled events whose time has arrived
    for i = #SurpriseEventQueue, 1, -1 do
        local instance = SurpriseEventQueue[i]
        if current_time >= instance.scheduled_at then
            execute_surprise_event(instance)
        end
    end
end

----------------------------------------------------------------------
-- High‑level Director API (lightweight hint + optional scheduling)
----------------------------------------------------------------------

function Director.update(region_id, t, opts)
    -- opts can carry flags like { auto_schedule = true, event_id = "..." }
    local trigger, tension = should_trigger(region_id, t)

    if trigger and opts and opts.auto_schedule and opts.event_id then
        schedule_surprise_event(opts.event_id, region_id)
    end

    -- The Director always returns a lightweight summary that other
    -- systems (Story., Style Router, etc.) can consume.
    return {
        type        = "SurpriseDirectorTick",
        region      = region_id,
        tension     = tension,
        auto_trigger= trigger
    }
end

----------------------------------------------------------------------
-- Example inline registration (for dev/testing only)
----------------------------------------------------------------------

local example_event = {
    event_id           = "aral_sea_dissolution_01",
    name               = "Aral Sea Dissolution",
    trigger_conditions = { CIC = { min = 0.8 }, SPR = { min = 0.7 } },
    bci_prerequisites  = { min_fear = 0.4 },
    intensity_range    = { min = 0.5, max = 0.9 },
    cooldown_min       = 60,
    cooldown_max       = 180,
    duration_estimate  = 15
}

register_surprise_event(example_event)

print("Surprise Director (Lua) loaded.")

return {
    update                  = Director.update,
    register_surprise_event = register_surprise_event,
    schedule_surprise_event = schedule_surprise_event
}
