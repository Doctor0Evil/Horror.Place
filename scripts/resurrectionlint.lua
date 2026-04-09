-- scripts/resurrectionlint.lua
local json = require("dkjson")

local function read_file(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, "failed to open " .. path .. ": " .. tostring(err)
    end
    local text = f:read("*a")
    f:close()
    return text
end

local function load_registry(path)
    local text, err = read_file(path)
    if not text then
        error(err)
    end
    local doc, pos, decode_err = json.decode(text, 1, nil)
    if decode_err then
        error("decode error in " .. path .. ": " .. tostring(decode_err))
    end
    return doc
end

local function lint_module(entry)
    local ok, mod = pcall(require, entry.luaModule)
    if not ok then
        return false, "require failed for " .. entry.luaModule .. ": " .. tostring(mod)
    end
    if type(mod.onEventAttempt) ~= "function" then
        return false, "onEventAttempt missing in " .. entry.luaModule
    end

    -- Optional static check: ensure the source mentions Resurrection.gate_resurrection.
    local src_path = entry.path:gsub("%.json$", ".lua")
    local src, err = read_file(src_path)
    if not src then
        return false, "cannot read Lua source for " .. entry.luaModule .. ": " .. err
    end
    if not src:find("Resurrection%.gate_resurrection", 1, true) then
        return false, "Resurrection.gate_resurrection not referenced in " .. src_path
    end

    return true
end

local function main()
    local registry_path = arg[1] or "registry/resurrections.json"
    local reg = load_registry(registry_path)
    local failed = false
    for _, entry in ipairs(reg.items or {}) do
        local ok, err = lint_module(entry)
        if not ok then
            io.stderr:write("[resurrectionlint] ", err, "\n")
            failed = true
        end
    end
    if failed then
        os.exit(1)
    end
end

main()
