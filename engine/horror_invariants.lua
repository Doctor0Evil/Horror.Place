-- engine/horrorinvariants.lua
--
-- Lua API for the Horror$Place Invariant system.
-- This module provides a Lua interface to the Rust-based Spectral Library.
-- It allows other Lua scripts (e.g., surprisedirector.lua, trajectoryscare.lua)
-- to query regional invariants (CIC, MDI, AOS, etc.) and evaluate preconditions.
-- This assumes a mechanism exists to call the Rust functions (e.g., using mlua or a custom FFI).

-- Placeholder for the Rust Spectral Library instance (implementation depends on FFI setup)
local spectral_lib_instance = nil

-- Function to load the Rust library instance (implementation specific to FFI binding)
local function init_rust_bindings()
    -- Example using mlua or similar:
    -- local rust_module = require('horror_place_engine')
    -- spectral_lib_instance = rust_module.get_spectral_library()
    print("WARNING: Rust bindings for H. API not initialized.")
end

-- Initialize bindings on module load (this needs to be handled by the actual engine setup)
init_rust_bindings()

-- The H. API namespace
H = {}

-- Helper function to safely call Rust functions (placeholder)
local function call_rust_function(func_name, ...)
    if not spectral_lib_instance then
        print(string.format("ERROR: Cannot call '%s', Rust bindings not ready.", func_name))
        return nil
    end
    -- Example: return spectral_lib_instance[func_name](...)
    print(string.format("Simulating call to Rust: %s", func_name))
    return 0.5 -- Placeholder return value
end

-- --- Core H. API Functions ---

-- Query functions for individual invariants of a region
function H.CIC(region_id)
    -- Assumes a Rust function `get_region_invariants` exists and returns a table
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.CIC or 0.0
    else
        print("H.CIC: Failed to retrieve invariants or CIC not found for region: " .. tostring(region_id))
        return 0.0 -- Default value if unavailable
    end
end

function H.MDI(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.MDI or 0.0
    else
        print("H.MDI: Failed to retrieve invariants or MDI not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.AOS(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.AOS or 0.0
    else
        print("H.AOS: Failed to retrieve invariants or AOS not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.RRM(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.RRM or 0.0
    else
        print("H.RRM: Failed to retrieve invariants or RRM not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.FCF(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.FCF or 0.0
    else
        print("H.FCF: Failed to retrieve invariants or FCF not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.SPR(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.SPR or 0.0
    else
        print("H.SPR: Failed to retrieve invariants or SPR not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.RWF(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.RWF or 0.0
    else
        print("H.RWF: Failed to retrieve invariants or RWF not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.DET(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.DET or 0.0
    else
        print("H.DET: Failed to retrieve invariants or DET not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.HVF(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.HVF or 0.0
    else
        print("H.HVF: Failed to retrieve invariants or HVF not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.LSG(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.LSG or 0.0
    else
        print("H.LSG: Failed to retrieve invariants or LSG not found for region: " .. tostring(region_id))
        return 0.0
    end
end

function H.SHCI(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        return invariants.SHCI or 0.0
    else
        print("H.SHCI: Failed to retrieve invariants or SHCI not found for region: " .. tostring(region_id))
        return 0.0
    end
end

-- Convenience function to get all invariants for a region as a table
function H.get_all_invariants(region_id)
    local invariants = call_rust_function("get_region_invariants", region_id)
    if invariants and type(invariants) == "table" then
        -- Return the table fetched from Rust, assuming it has all keys
        return invariants
    else
        print("H.get_all_invariants: Failed to retrieve invariants for region: " .. tostring(region_id))
        return {
            CIC = 0.0, MDI = 0.0, AOS = 0.0, RRM = 0.0, FCF = 0.0,
            SPR = 0.0, RWF = 0.0, DET = 0.0, HVF = 0.0, LSG = 0.0, SHCI = 0.0
        }
    end
end

-- Function to evaluate a set of preconditions against a region's invariants
-- precondition_table format: { CIC = {min = 0.8}, SPR = {min = 0.6, max = 0.9} }
function H.evaluate_preconditions(region_id, precondition_table)
    if not precondition_table or type(precondition_table) ~= "table" then
        print("H.evaluate_preconditions: Invalid precondition_table provided
    end

    local region_invariants = H.get_all_invariants(region_id)
    if not region_invariants then
        print("H.evaluate_preconditions: Could not get invariants for region: " .. tostring(region_id))
        return false
    end

    for inv_name, thresholds in pairs(precondition_table) do
        local inv_value = region_invariants[inv_name]
        if inv_value == nil then
            print(string.format("H.evaluate_preconditions: Unknown invariant '%s' in precondition.", inv_name))
            return false -- Fail if an unknown invariant is requested
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

print("H. API (Lua) loaded.")
