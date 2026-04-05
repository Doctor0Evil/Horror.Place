#!/usr/bin/env lua
-- scripts/validate_invariants.lua
-- Horror.Place Seed Validator
-- Validates NDJSON region seed packs against canonical invariant bounds.
-- Exit 0 = success, 1 = validation failure.

local json = require("dkjson")
local io   = io
local string = string

-- Configuration
local CONFIG = {
    strict_mode = true,
    allowed_keys = {
        "seed_id", "region_id", "tile_id", "tile_class", "archetype",
        "historical_events", "seed_version",
        "CIC", "MDI", "AOS", "RRM", "FCF", "SPR", "SHCI", "LSG", "RWF", "DET",
        "HVF_mag", "HVF_dir"
    },
    invariant_keys = {
        "CIC", "MDI", "AOS", "RRM", "FCF", "SPR", "SHCI", "LSG", "RWF", "DET", "HVF_mag"
    }
}

-- Utility: Check if value is within [0.0, 1.0]
local function is_valid_invariant(val)
    if type(val) ~= "number" then return false end
    return val >= 0.0 and val <= 1.0
end

-- Utility: Validate a single seed object
local function validate_seed(line_num, data)
    local errors = {}
    
    -- Check required keys
    if not data.seed_id then table.insert(errors, "missing 'seed_id'") end
    if not data.region_id then table.insert(errors, "missing 'region_id'") end
    if not data.tile_id then table.insert(errors, "missing 'tile_id'") end
    if not data.tile_class then table.insert(errors, "missing 'tile_class'") end
    
    -- Check invariant bounds
    for _, key in ipairs(CONFIG.invariant_keys) do
        if data[key] ~= nil and not is_valid_invariant(data[key]) then
            table.insert(errors, string.format("'%s' value %.2f out of [0.0, 1.0] bounds", key, data[key]))
        end
    end
    
    -- HVF direction check (if present)
    if data.HVF_dir then
        if type(data.HVF_dir) ~= "table" or not data.HVF_dir.x or not data.HVF_dir.y then
            table.insert(errors, "'HVF_dir' must be {x, y, z}")
        end
    end
    
    if #errors > 0 then
        return false, table.concat(errors, "; ")
    end
    return true, nil
end

-- Main validation loop
local function main()
    local filepath = arg[1]
    if not filepath then
        io.stderr:write("Usage: lua scripts/validate_invariants.lua <path/to/seeds.ndjson>\n")
        return 1
    end
    
    local file, err = io.open(filepath, "r")
    if not file then
        io.stderr:write("Error: " .. tostring(err) .. "\n")
        return 1
    end
    
    local line_num = 0
    local valid_count = 0
    local invalid_count = 0
    
    for line in file:lines() do
        line_num = line_num + 1
        if line:match("%S") then -- skip empty lines
            local data, pos, jerr = json.decode(line)
            if not data then
                io.stderr:write(string.format("Line %d: JSON parse error: %s\n", line_num, jerr or "unknown"))
                invalid_count = invalid_count + 1
                goto continue
            end
            
            local ok, err_msg = validate_seed(line_num, data)
            if not ok then
                io.stderr:write(string.format("Line %d: Validation failed: %s\n", line_num, err_msg))
                invalid_count = invalid_count + 1
            else
                valid_count = valid_count + 1
            end
        end
        ::continue::
    end
    
    file:close()
    
    io.stdout:write(string.format("\nValidation Complete: %d valid, %d invalid\n", valid_count, invalid_count))
    
    if invalid_count > 0 then
        return 1
    end
    return 0
end

-- Run if executed directly
if arg and arg[0] == "scripts/validate_invariants.lua" then
    os.exit(main())
end

return { validate_seed = validate_seed }
