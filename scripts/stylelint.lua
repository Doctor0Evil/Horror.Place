-- scripts/stylelint.lua
--
-- Style Linter for Horror$Place Style Contracts.
-- Validates a style contract file (parsed as a Lua table) against the
-- stylecontract_v1.json schema structure and the Rivers of Blood Charter.
-- This is a Lua implementation for use within the engine's CI/CD or
-- pre-commit hooks, potentially called by runstylelint.lua.

local json = require("dkjson") -- Assuming a JSON parsing library like dkjson is available

-- --- Schema Definition (Embedded for portability, ideally loaded from JSON file) ---
local STYLE_CONTRACT_SCHEMA = {
    style_id = "string",
    name = "string",
    description = "string",
    tier = "string",
    platforms = "table", -- array of strings
    evidence_types = "table", -- array of strings
    forbidden_depictions = "table", -- array of strings
    metric_levers = "table", -- object with UEC, EMD, etc.
    invariant_requirements = "table", -- optional object
}

local VALID_TIERS = { "standard", "mature", "research" }
local VALID_PLATFORMS = { "web", "vr", "bci" } -- Extend as needed
local VALID_EVIDENCE_TYPES = { "archival_ledger", "spectral_static", "ritual_residue", "biomech_residual", "indbiometric_residue", "system_error_glitch", "spectral_reflection", "temporal_bleed", "material_disturbance", "archival_metallic" } -- Extend as needed
local VALID_FORBIDDEN_DEPICTIONS = { "human_anatomy_direct", "graphic_violence", "explicit_suffering", "decontextualized_horror", "violates_procedural_implication_doctrine", "bright_red_color", "static_metal_surfaces", "bright_colors", "overly_detailed_monsters", "overly_detailed_violence", "bright_red_color", "excessive_visual_distortion" } -- From charter and style contracts
local VALID_METRICS = { "UEC", "EMD", "STCI", "CDL", "ARR" }

-- --- Linting Functions ---

-- Checks if a value is within the expected type
local function is_type(val, expected_type)
    if expected_type == "array" then
        return type(val) == "table" and val[1] ~= nil -- Simple check for array-like table
    else
        return type(val) == expected_type
    end
end

-- Validates the basic structure against the embedded schema
local function validate_schema(contract)
    for field, expected_type in pairs(STYLE_CONTRACT_SCHEMA) do
        if contract[field] == nil then
            print("ERROR: Missing required field: " .. field)
            return false
        end
        if not is_type(contract[field], expected_type) then
            print("ERROR: Field '" .. field .. "' has incorrect type. Expected " .. expected_type .. ", got " .. type(contract[field]))
            return false
        end
    end
    return true
end

-- Validates specific enumerations and ranges
local function validate_enums_and_ranges(contract)
    -- Tier
    if not table.contains(VALID_TIERS, contract.tier) then
        print("ERROR: Invalid tier '" .. contract.tier .. "'. Valid options: " .. table.concat(VALID_TIERS, ", "))
        return false
    end

    -- Platforms
    for _, platform in ipairs(contract.platforms) do
        if not table.contains(VALID_PLATFORMS, platform) then
            print("ERROR: Invalid platform '" .. platform .. "'. Valid options: " .. table.concat(VALID_PLATFORMS, ", "))
            return false
        end
    end

    -- Evidence Types
    for _, etype in ipairs(contract.evidence_types) do
        if not table.contains(VALID_EVIDENCE_TYPES, etype) then
            print("WARNING: Unknown evidence type '" .. etype .. "'. Check list or consider adding to VALID_EVIDENCE_TYPES.")
            -- Could be an error depending on strictness, warn for now
        end
    end

    -- Forbidden Depictions (against charter)
    for _, fdep in ipairs(contract.forbidden_depictions) do
        if not table.contains(VALID_FORBIDDEN_DEPICTIONS, fdep) then
            print("WARNING: Unknown forbidden depiction '" .. fdep .. "'. Check list or consider adding to VALID_FORBIDDEN_DEPICTIONS.")
            -- Could be an error depending on strictness, warn for now
        end
    end

    -- Metric Levers (values should be numbers between -1.0 and 1.0)
    if contract.metric_levers then
        for metric, value in pairs(contract.metric_levers) do
            if not table.contains(VALID_METRICS, metric) then
                print("WARNING: Unknown metric lever '" .. metric .. "'. Valid options: " .. table.concat(VALID_METRICS, ", "))
            end
            if type(value) ~= "number" then
                print("ERROR: Metric lever '" .. metric .. "' must be a number. Got " .. type(value))
                return false
            end
            if value < -1.0 or value > 1.0 then
                print("ERROR: Metric lever '" .. metric .. "' value " .. value .. " is out of range [-1.0, 1.0]")
                return false
            end
        end
    end

    -- Invariant Requirements (values should be numbers between 0.0 and 1.0 if present)
    if contract.invariant_requirements then
        -- Assuming invariant names are known, e.g., CIC_min, MDI_min, etc.
        for req_name, req_value in pairs(contract.invariant_requirements) do
            if type(req_value) ~= "number" then
                print("ERROR: Invariant requirement '" .. req_name .. "' must be a number. Got " .. type(req_value))
                return false
            end
            if req_value < 0.0 or req_value > 1.0 then
                print("ERROR: Invariant requirement '" .. req_name .. "' value " .. req_value .. " is out of range [0.0, 1.0]")
                return false
            end
        end
    end

    return true
end

-- Main lint function
-- @param contract_table: A Lua table representing the parsed style contract
-- @return: boolean indicating success, string with error message if failed
function lint_style_contract(contract_table)
    if type(contract_table) ~= "table" then
        return false, "Input is not a Lua table."
    end

    print("--- Linting Style Contract: " .. (contract_table.style_id or "Unknown ID") .. " ---")

    if not validate_schema(contract_table) then
        return false, "Schema validation failed."
    end

    if not validate_enums_and_ranges(contract_table) then
        return false, "Enum/range validation failed."
    end

    print("SUCCESS: Style contract is valid according to schema and rules.")
    return true, "OK"
end

-- Helper function to check if table contains a value (for enums)
table.contains = function(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

-- Example usage (commented out for library use):
-- local example_contract = {
--     style_id = "test name = "Test Style",
--     description = "A style for testing.",
--     tier = "standard",
--     platforms = {"web"},
--     evidence_types = {"archival_ledger"},
--     forbidden_depictions = {"human_anatomy_direct"},
--     metric_levers = { UEC = 0.1, EMD = 0.2 }
-- }
-- lint_style_contract(example_contract)

print("Style Linter (Lua) loaded.")
