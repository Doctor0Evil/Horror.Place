-- File: tools/style_lint.lua

local StyleRegistry = require("style_registry")

local StyleLint = {}

-- pseudo: we assume other modules for parsing Lua/JSON/YAML exist
local LuaParser   = require("tools.lua_parser")
local MetaLoader  = require("tools.meta_loader")

local function lint_lua_file(path, style_profiles)
    local ast = LuaParser.parse_file(path)
    local issues = {}

    -- Example: ensure style imports when styles are referenced
    local referenced_styles = LuaParser.find_string_literals(ast, "style_id")
    for _, style_id in ipairs(referenced_styles) do
        if style_profiles[style_id] then
            if not LuaParser.has_require(ast, "artstyles.") then
                table.insert(issues, {
                    severity = "error",
                    code = "STYLE_IMPORT_REQUIRED",
                    message = "File references style_id="..style_id.." but does not require any artstyles module.",
                    path = path
                })
            end
        end
    end

    -- Additional checks here...

    return issues
end

local function lint_meta_file(path, style_profiles)
    local meta = MetaLoader.load(path)
    local issues = {}

    local style_id = meta.target_artstyle
    local profile  = style_profiles[style_id]

    if profile then
        -- Palette constraints example
        if profile.visual_flags and profile.visual_flags.palette_desaturation then
            if meta.palette and meta.palette.vibrant_colors == true then
                table.insert(issues, {
                    severity = "error",
                    code = "STYLE_PALETTE_CONSTRAINTS",
                    message = "Artstyle "..style_id.." forbids vibrant colors.",
                    path = path..":palette"
                })
            end
        end

        -- Composition constraints example (lone figure)
        if style_id == "SPECTRAL_ENGRAVING_DARK_SUBLIME" then
            if meta.observer_count and meta.observer_count ~= 1 then
                table.insert(issues, {
                    severity = "error",
                    code = "STYLE_COMPOSITION_CONSTRAINTS",
                    message = "Artstyle "..style_id.." requires exactly one primary observer.",
                    path = path..":observer_count"
                })
            end
        end
    end

    return issues
end

function StyleLint.run(paths)
    local styles = StyleRegistry.get_all()
    local results = { errors = {}, warnings = {}, info = {} }

    for _, path in ipairs(paths.lua_files or {}) do
        local issues = lint_lua_file(path, styles)
        for _, issue in ipairs(issues) do
            table.insert(results[issue.severity.."s"], issue)
        end
    end

    for _, path in ipairs(paths.meta_files or {}) do
        local issues = lint_meta_file(path, styles)
        for _, issue in ipairs(issues) do
            table.insert(results[issue.severity.."s"], issue)
        end
    end

    results.passed = (#results.errors == 0)

    return results
end

return StyleLint
