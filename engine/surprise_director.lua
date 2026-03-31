-- engine/surprise_director.lua
local H   = require("engine.horror_invariants")
local BCI = require("engine.bci_adapter")

local Director = {
    last_event_time = 0.0,
    cooldown        = 15.0,   -- seconds between big Surprise.Events!
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

    -- Example: only fire when tension is high but fear is below panic
    local fear = BCI.get_fear()
    local panic_threshold = 0.85
    if tension > 0.7 and fear < panic_threshold then
        return true, tension
    end

    return false, tension
end

function Director.update(region_id, t)
    local trigger, tension = should_trigger(region_id, t)
    if trigger then
        Director.last_event_time = t
        return {
            type    = "SurpriseEvent",
            region  = region_id,
            tension = tension
        }
    end
    return nil
end

return Director
