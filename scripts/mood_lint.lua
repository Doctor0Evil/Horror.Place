-- scripts/mood_lint.lua
-- Simple structural linter for mood Lua modules.

local json = require("dkjson")

local function read_file(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, "failed to open file: " .. tostring(err)
    end
    local data = f:read("*a")
    f:close()
    return data, nil
end

local function load_registry(path)
    local text, err = read_file(path)
    if not text then
        return nil, err
    end
    local obj, pos, jerr = json.decode(text, 1, nil)
    if not obj then
        return nil, "failed to decode JSON at " .. tostring(pos) .. ": " .. tostring(jerr)
    end
    return obj, nil
end

local function lint_mood(id, entry)
    local module_name = entry.lua_module
    local required = entry.requires_hooks or {}

    if not module_name then
        return false, "mood " .. id .. " missing lua_module in registry"
    end

    local ok, mod_or_err = pcall(require, module_name)
    if not ok then
        return false, "require failed for " .. module_name .. ": " .. tostring(mod_or_err)
    end
    local mood = mod_or_err

    if type(mood) ~= "table" then
        return false, "module " .. module_name .. " did not return a table"
    end

    for _, hook in ipairs(required) do
        local fn = mood[hook]
        if type(fn) ~= "function" then
            return false, "mood " .. id .. " missing required hook " .. hook
        end
    end

    return true, nil
end

local function main()
    local registry_path = arg[1] or "registry/moods.json"
    local moods, err = load_registry(registry_path)
    if not moods then
        io.stderr:write("error: ", err, "\n")
        os.exit(1)
    end

    local failed = false
    for mood_id, entry in pairs(moods) do
        local ok, msg = lint_mood(mood_id, entry)
        if not ok then
            failed = true
            io.stderr:write("[mood lint] ", msg, "\n")
        end
    end

    if failed then
        os.exit(1)
    end
end

main()
