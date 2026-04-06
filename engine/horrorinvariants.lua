-- engine/horrorinvariants.lua
--
-- Canonical Invariant Access API (H.*) for Horror.Place
--
-- Role:
-- - Narrow surface for querying invariants (CIC, MDI, AOS, etc.)
-- - Reads from data shaped by schemas/invariantsv1.json
-- - Enforces canonical key names and ranges (DET clamped to 0–10)
--
-- Integration:
-- - Engine core (C/Rust) populates region data or wires FFI callbacks.
-- - Higher-level Lua (directors, PCG, moods) must always go through H.*

local H = {}

----------------------------------------------------------------------
-- Backing store and wiring
----------------------------------------------------------------------

-- Internal data store populated by engine core or FFI callbacks.
-- Structure: H._regions[region_id] = { CIC = 0.5, DET = 4.0, ... }
H._regions = H._regions or {}

-- Optional function hook for external lookup (e.g., Rust/FFI).
-- Signature: external_region_lookup(region_id) -> table or nil
H.external_region_lookup = H.external_region_lookup or nil

----------------------------------------------------------------------
-- Canonical invariant keys (must match invariants schema)
----------------------------------------------------------------------

H.Keys = {
    CIC  = "CIC",
    MDI  = "MDI",
    AOS  = "AOS",
    RRM  = "RRM",
    FCF  = "FCF",
    SPR  = "SPR",
    RWF  = "RWF",
    DET  = "DET",
    HVF  = "HVF",
    LSG  = "LSG",
    SHCI = "SHCI"
}

----------------------------------------------------------------------
-- Internal helpers
----------------------------------------------------------------------

local function resolve_region(region_id)
    local region_data = H._regions[region_id]
    if region_data then
        return region_data
    end

    if H.external_region_lookup then
        local from_external = H.external_region_lookup(region_id)
        if type(from_external) == "table" then
            H._regions[region_id] = from_external
            return from_external
        end
    end

    return nil
end

local function clamp_det(value)
    if value == nil then
        return nil
    end
    if value < 0.0 then
        return 0.0
    end
    if value > 10.0 then
        return 10.0
    end
    return value
end

----------------------------------------------------------------------
-- Generic low-level getter
----------------------------------------------------------------------

function H.get_invariant(region_id, invariant_key)
    if not H.Keys[invariant_key] then
        error("H.get_invariant: unknown invariant key: " .. tostring(invariant_key))
    end

    local region_data = resolve_region(region_id)
    if not region_data then
        return nil
    end

    return region_data[H.Keys[invariant_key]]
end

----------------------------------------------------------------------
-- Canonical API surface (per-invariant functions)
----------------------------------------------------------------------

function H.CIC(region_id)  return H.get_invariant(region_id, "CIC") end
function H.MDI(region_id)  return H.get_invariant(region_id, "MDI") end
function H.AOS(region_id)  return H.get_invariant(region_id, "AOS") end
function H.RRM(region_id)  return H.get_invariant(region_id, "RRM") end
function H.FCF(region_id)  return H.get_invariant(region_id, "FCF") end
function H.SPR(region_id)  return H.get_invariant(region_id, "SPR") end
function H.RWF(region_id)  return H.get_invariant(region_id, "RWF") end
function H.HVF(region_id)  return H.get_invariant(region_id, "HVF") end
function H.LSG(region_id)  return H.get_invariant(region_id, "LSG") end
function H.SHCI(region_id) return H.get_invariant(region_id, "SHCI") end

-- DET has a special 0–10 range; clamp here.
function H.DET(region_id)
    local val = H.get_invariant(region_id, "DET")
    return clamp_det(val)
end

----------------------------------------------------------------------
-- Bulk access and mutation hooks
----------------------------------------------------------------------

-- Return a shallow copy of all invariants for a region.
function H.get_all(region_id)
    local data = resolve_region(region_id)
    if not data then
        return {}
    end
    local copy = {}
    for k, v in pairs(data) do
        copy[k] = v
    end
    return copy
end

-- Engine core hook: replace all invariants for a region.
function H._update_region(region_id, data_table)
    if type(data_table) ~= "table" then
        error("H._update_region: data_table must be a table")
    end
    H._regions[region_id] = data_table
end

----------------------------------------------------------------------
-- Preconditions and derived helpers
----------------------------------------------------------------------

-- precondition_table format:
--   { CIC = { min = 0.8 }, SPR = { min = 0.6, max = 0.9 } }
function H.evaluate_preconditions(region_id, precondition_table)
    if type(precondition_table) ~= "table" then
        return false
    end

    local region_invariants = H.get_all(region_id)
    if not region_invariants then
        return false
    end

    for inv_name, thresholds in pairs(precondition_table) do
        local inv_value = region_invariants[inv_name]
        if inv_value == nil then
            return false
        end
        if thresholds.min and inv_value < thresholds.min then
            return false
        end
        if thresholds.max and inv_value > thresholds.max then
            return false
        end
    end

    return true
end

-- Convenience wrapper for systems that want a single record with
-- key invariants plus placeholders for entertainment metrics.
function H.region_metrics(region_id)
    local inv = H.get_all(region_id)
    return {
        CIC = inv.CIC,
        RRM = inv.RRM,
        AOS = inv.AOS,
        HVF = inv.HVF,
        LSG = inv.LSG,
        DET = inv.DET,
        UEC = 0.0,
        EMD = 0.0,
        ARR = 0.0
    }
end

----------------------------------------------------------------------
-- Export
----------------------------------------------------------------------

_G.H = H

return H
