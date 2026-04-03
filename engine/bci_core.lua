-- engine/bci_core.lua
local BCI = {
    fear      = 0.0,  -- 0–1 normalized composite
    arousal   = 0.0,  -- 0–1
    valence   = 0.0,  -- -1–1 mapped to 0–1 internally if needed
    last_t    = 0.0,

    mode      = "UNDERSTIMULATED", -- v1 intensity mode
    overwhelmed_since = nil        -- timestamp when OVERWHELMED started
}

local thresholds = {
    UNDERSTIMULATED_MAX = 0.35,
    OPTIMAL_STRESS_MAX  = 0.80,
    OVERWHELMED_MIN     = 0.80
}

-- Called by device-specific adapters that already normalized their payload
function BCI.ingest_normalized(payload)
    -- payload: { fear, arousal, valence, t, adapter_id, contract_version }
    if not payload or not payload.fear or not payload.t then
        return
    end

    BCI.fear    = math.min(1.0, math.max(0.0, payload.fear))
    BCI.arousal = math.min(1.0, math.max(0.0, payload.arousal or BCI.arousal))
    BCI.valence = payload.valence or BCI.valence
    BCI.last_t  = payload.t

    BCI._update_mode()
end

function BCI._update_mode()
    local f = BCI.fear

    local prev_mode = BCI.mode
    if f < thresholds.UNDERSTIMULATED_MAX then
        BCI.mode = "UNDERSTIMULATED"
        BCI.overwhelmed_since = nil
    elseif f < thresholds.OPTIMAL_STRESS_MAX then
        BCI.mode = "OPTIMAL_STRESS"
        BCI.overwhelmed_since = nil
    else
        if BCI.mode ~= "OVERWHELMED" then
            BCI.overwhelmed_since = BCI.last_t
        end
        BCI.mode = "OVERWHELMED"
    end

    if prev_mode ~= BCI.mode then
        -- Emit a structured intensity transition event under telemetry pipeline
        if BCI.on_mode_changed then
            BCI.on_mode_changed(prev_mode, BCI.mode, BCI.last_t)
        end
    end
end

function BCI.get_intensity_mode()
    return BCI.mode
end

function BCI.get_overwhelmed_duration(now_t)
    if BCI.mode ~= "OVERWHELMED" or not BCI.overwhelmed_since then
        return 0.0
    end
    return now_t - BCI.overwhelmed_since
end

function BCI.snapshot()
    return {
        fear     = BCI.fear,
        arousal  = BCI.arousal,
        valence  = BCI.valence,
        mode     = BCI.mode,
        last_t   = BCI.last_t
    }
end

return BCI
