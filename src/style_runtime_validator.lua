-- File: src/style_runtime_validator.lua

local StyleRegistry = require("style_registry")

local RuntimeStyleValidator = {}

function RuntimeStyleValidator.validate_activation(style_decision, inv, metrics, caps)
    local style = StyleRegistry.get_all()[style_decision.style_id]
    local issues = {}

    if not style then
        table.insert(issues, {
            severity = "error",
            code = "STYLE_UNKNOWN",
            message = "Unknown style_id: "..tostring(style_decision.style_id),
            path = "style_decision.style_id"
        })
        return issues
    end

    if style.invariant_requirements and not style.invariant_requirements(inv) then
        table.insert(issues, {
            severity = "error",
            code = "STYLE_INV_INCOMPATIBLE",
            message = "Style "..style.id.." activated where invariant requirements are not met.",
            path = "invariants"
        })
    end

    if style.metric_targets then
        for name, range in pairs(style.metric_targets) do
            local v = metrics[name]
            if v ~= nil and (v < range.min or v > range.max) then
                table.insert(issues, {
                    severity = "info",
                    code = "STYLE_METRIC_OFF_TARGET",
                    message = "Metric "..name.."="..string.format("%.2f", v).." outside target range ["..range.min..","..range.max.."] for style "..style.id..".",
                    path = "metrics."..name
                })
            end
        end
    end

    local realism_cap   = caps.realism_cap or 1.0
    local intensity_cap = caps.intensity_cap or 1.0
    local cic_det = inv.cic * inv.det

    if cic_det > intensity_cap + 0.1 then
        table.insert(issues, {
            severity = "warning",
            code = "STYLE_CAP_VIOLATION",
            message = "CIC*DET exceeds region intensity_cap for style "..style.id..".",
            path = "invariants.cic_det"
        })
    end

    return issues
end

return RuntimeStyleValidator
