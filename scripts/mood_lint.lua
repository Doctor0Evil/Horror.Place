#!/usr/bin/env lua
-- scripts/mood_lint.lua
-- Horror.Place Mood Module Linter
-- Validates that mood Lua modules registered in registry/moods.json
-- export all required hooks and follow naming conventions.
-- Exit code 0 = success, 1 = validation failure.

local json = require("dkjson")

local ok_argparse, argparse_mod = pcall(require, "argparse")

local argparse = nil
if ok_argparse and type(argparse_mod) == "table" and argparse_mod.ArgumentParser then
    argparse = argparse_mod
else
    -- Minimal fallback if argparse is not available; supports: mood_lint.lua [registry_path]
    argparse = {
        parse = function(args)
            return { registry = args[1] or "registry/moods.json" }
        end
    }
end

-- Configuration
local CONFIG = {
    lua_path = os.getenv("LUA_PATH") or "./?.lua;./?/init.lua",
    strict_mode = true,      -- Fail on any missing hook
    verbose = false,         -- Print detailed validation steps
    allow_deprecated = false -- Allow deprecated hook names with warning
}

-- Utility: Load JSON file safely
local function load_json(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, "failed to open file: " .. tostring(err)
    end
    local content = f:read("*a")
    f:close()

    local obj, pos, jerr = json.decode(content, 1, nil)
    if not obj then
        return nil, string.format("JSON parse error at position %d: %s", pos or -1, tostring(jerr))
    end
    return obj, nil
end

-- Utility: Require a Lua module safely (returns module or error string)
local function safe_require(module_name)
    local ok, result = pcall(require, module_name)
    if not ok then
        return nil, result
    end
    return result, nil
end

-- Utility: Check if a value is a callable function
local function is_callable(value)
    return type(value) == "function"
end

-- Utility: Log message with optional verbosity control
local function log(level, message, ...)
    if level == "error" or (level == "info" and CONFIG.verbose) then
        local prefix = string.upper(level) .. ": "
        io.stderr:write(prefix, string.format(message, ...), "\n")
    end
end

-- Validate a single mood entry from the registry
-- Returns: boolean success, string? error_message
local function validate_mood_entry(mood_id, entry)
    local errors = {}

    -- Check required fields
    if not entry.lua_module then
        table.insert(errors, string.format("mood '%s' missing required field 'lua_module'", mood_id))
        return false, table.concat(errors, "; ")
    end

    if not entry.requires_hooks or type(entry.requires_hooks) ~= "table" then
        table.insert(errors, string.format("mood '%s' missing or invalid 'requires_hooks' array", mood_id))
        return false, table.concat(errors, "; ")
    end

    -- Attempt to require the module
    local module, err = safe_require(entry.lua_module)
    if not module then
        table.insert(errors, string.format("failed to require '%s': %s", entry.lua_module, tostring(err)))
        return false, table.concat(errors, "; ")
    end

    -- Verify module is a table
    if type(module) ~= "table" then
        table.insert(errors, string.format(
            "module '%s' did not return a table (got %s)",
            entry.lua_module,
            type(module)
        ))
        return false, table.concat(errors, "; ")
    end

    -- Check each required hook
    for _, hook_name in ipairs(entry.requires_hooks) do
        local hook = module[hook_name]
        if not is_callable(hook) then
            table.insert(errors, string.format(
                "mood '%s' module '%s' missing required hook '%s' (got %s)",
                mood_id,
                entry.lua_module,
                tostring(hook_name),
                type(hook)
            ))
            if CONFIG.strict_mode then
                -- In strict mode, we can fail fast, but still report accumulated errors
            end
        end
    end

    -- Optional: Check for deprecated hooks if strict mode allows
    if not CONFIG.allow_deprecated and entry.deprecated_hooks then
        for _, dep_hook in ipairs(entry.deprecated_hooks) do
            if module[dep_hook] then
                log("info", "warning: mood '%s' uses deprecated hook '%s'", mood_id, dep_hook)
            end
        end
    end

    if #errors > 0 then
        return false, table.concat(errors, "; ")
    end

    return true, nil
end

-- Main validation routine
local function main(argv)
    argv = argv or arg

    local registry_path
    if argparse and argparse.ArgumentParser then
        -- Full argparse usage if available
        local parser = argparse.ArgumentParser({
            description = "Horror.Place Mood Module Linter"
        })
        parser:argument("registry", "Path to moods registry JSON")
              :args("?")
              :default("registry/moods.json")
        parser:option("--verbose", "-v", "Enable verbose logging")
              :args(0)
        parser:flag("--allow-deprecated", "Allow deprecated hooks with warnings")

        local parsed = parser:parse(argv)
        registry_path = parsed.registry
        CONFIG.verbose = parsed.verbose or false
        CONFIG.allow_deprecated = parsed["allow-deprecated"] or false
    else
        -- Fallback minimal parser
        local parsed = argparse.parse(argv)
        registry_path = parsed.registry or "registry/moods.json"
    end

    -- Load registry
    local registry, err = load_json(registry_path)
    if not registry then
        log("error", "Failed to load registry '%s': %s", registry_path, tostring(err))
        return 1
    end

    -- Validate each mood entry
    local total = 0
    local passed = 0
    local failed = {}

    for mood_id, entry in pairs(registry) do
        total = total + 1
        local ok, err_msg = validate_mood_entry(mood_id, entry)

        if ok then
            passed = passed + 1
            log("info", "✓ %s", mood_id)
        else
            table.insert(failed, { id = mood_id, error = err_msg })
            log("error", "✗ %s: %s", mood_id, err_msg)
        end
    end

    if CONFIG.verbose then
        log("info", "Validation complete: %d/%d moods passed", passed, total)
    end

    if #failed > 0 then
        log("error", "Failed validations:")
        for _, f in ipairs(failed) do
            log("error", "  - %s: %s", f.id, f.error)
        end
        return 1
    end

    return 0
end

-- Run if executed directly
if ... == nil then
    os.exit(main(arg))
end

-- Export for use as a library
return {
    validate_mood_entry = validate_mood_entry,
    load_json = load_json,
    CONFIG = CONFIG,
    main = main
}
