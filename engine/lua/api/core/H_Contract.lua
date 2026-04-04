--- H_Contract.lua
--- Horror.Place Runtime Contract API (Lua)
--- ──────────────────────────────────────
--- Provides in-game access to loaded contractCards, enforces invariant gating,
--- verifies deadledgerref anchors, and exposes metric adjustment hooks.
--- Aligns with Ice-Pick Lodge "Deep Game" philosophy: systems over scripts,
--- constraints over authorial hand-holding.

local H_Contract = {}
H_Contract._version = "v1.0.0"

-- Internal cache for loaded contracts
local _contract_cache = {}
local _history_service = require("H_History") -- Assumed external ledger API

--- Load a contract from a stable contractRef URI.
--- @param contract_uri string "contract://..."
--- @return table|nil contract_object, string|nil error_message
function H_Contract.load(contract_uri)
    if not contract_uri or type(contract_uri) ~= "string" then
        return nil, "H_Contract.load: Invalid contract_uri"
    end
    
    if _contract_cache[contract_uri] then
        return _contract_cache[contract_uri], nil
    end
    
    -- TODO: Implement engine-side contract resolution (JSON parse from Pak/AssetRegistry)
    local raw = Engine_GetContractData(contract_uri) 
    if not raw then
        return nil, "H_Contract.load: Contract not found in registry"
    end
    
    _contract_cache[contract_uri] = raw
    return raw, nil
end

--- Verify ledger anchoring before allowing high-impact seed instantiation.
--- @param contract table Loaded contract object
--- @return boolean is_anchored
function H_Contract.verify_anchor(contract)
    if not contract.deadledgerref then
        warn("H_Contract: Contract missing deadledgerref. Defaulting to unanchored state.")
        return false
    end
    return _history_service.isAnchored(contract.deadledgerref)
end

--- Check if a runtime invariant value respects the contract's target.
--- Allows for small epsilon tolerance (±0.05) to account for PCG variance.
--- @param contract table
--- @param invariant_key string "CIC" | "AOS" | "RRM" | "LSG" | "DET" | "SHCI"
--- @param current_value number
--- @return boolean is_within_bounds
function H_Contract.check_invariant(contract, invariant_key, current_value)
    local target = contract.invariants[invariant_key]
    if not target then
        error("H_Contract: Unknown invariant key '" .. tostring(invariant_key) .. "'")
    end
    local EPSILON = 0.05
    return math.abs(current_value - target) <= EPSILON
end

--- Retrieve the acceptable metric band for a given metric name.
--- @param contract table
--- @param metric_key string "UEC" | "EMD" | "STCI" | "CDL" | "ARR"
--- @return number min, number max
function H_Contract.get_metric_band(contract, metric_key)
    local band = contract.metrics[metric_key]
    if not band or #band ~= 2 then
        error("H_Contract: Invalid or missing metric band for '" .. tostring(metric_key) .. "'")
    end
    return band[1], band[2]
end

--- Adjust a runtime metric and log telemetry for the research loop.
--- @param metric_key string
--- @param delta number
function H_Contract.adjust_metric(metric_key, delta)
    local current = Metrics_GetCurrentValue(metric_key) or 0.0
    local new_val = math.max(0.0, math.min(1.0, current + delta))
    Metrics_SetValue(metric_key, new_val)
    
    -- Log to telemetry pipeline for AI-Chat refinement
    Telemetry_Log("metric_adjust", { metric = metric_key, delta = delta, new_value = new_val })
end

--- Gating helper: Prevents overt events from triggering if DET threshold is breached.
--- @param contract table
--- @param event_intensity number 0.0 - 10.0
--- @return boolean should_trigger
function H_Contract.gate_dread_event(contract, event_intensity)
    local det_target = contract.invariants.DET
    -- Allow events only if they don't push cumulative DET > target + tolerance
    local cumulative_det = Metrics_GetCurrentValue("cumulative_DET") or 0.0
    return (cumulative_det + event_intensity) <= (det_target + 1.5)
end

return H_Contract
