-- scripts/validate_contract_card.lua
-- Lightweight semantic validator for seed-level contractCards.
-- Intended to be used both in CI and at runtime (editor or engine).

local M = {}

-- Utility: check numeric range
local function in_range(value, minv, maxv)
    if type(value) ~= "number" then
        return false
    end
    if value < minv or value > maxv then
        return false
    end
    return true
end

-- Utility: check metric band shape { min = x, max = y } with 0..1 range and min <= max
local function validate_metric_band(name, band, errors)
    if type(band) ~= "table" then
        table.insert(errors, "metrics." .. name .. " must be an object with min and max")
        return
    end
    local minv = band.min
    local maxv = band.max
    if type(minv) ~= "number" or type(maxv) ~= "number" then
        table.insert(errors, "metrics." .. name .. ".min and .max must be numbers")
        return
    end
    if not in_range(minv, 0.0, 1.0) or not in_range(maxv, 0.0, 1.0) then
        table.insert(errors, "metrics." .. name .. " values must be within [0.0, 1.0]")
    end
    if minv > maxv then
        table.insert(errors, "metrics." .. name .. " min must be <= max")
    end
end

-- Optional subset check: ensure a seed value lies inside a parent cap band
local function validate_subset_scalar(field, value, parent_min, parent_max, errors)
    if value == nil then
        return
    end
    if parent_min == nil or parent_max == nil then
        return
    end
    if value < parent_min or value > parent_max then
        local msg = string.format(
            "invariants.%s=%0.4f is outside parent caps [%0.4f, %0.4f]",
            field, value, parent_min, parent_max
        )
        table.insert(errors, msg)
    end
end

local function validate_subset_band(name, band, parent_band, errors)
    if type(band) ~= "table" or type(parent_band) ~= "table" then
        return
    end
    local smin = band.min
    local smax = band.max
    local pmin = parent_band.min
    local pmax = parent_band.max
    if type(smin) ~= "number" or type(smax) ~= "number" then
        return
    end
    if type(pmin) ~= "number" or type(pmax) ~= "number" then
        return
    end
    if smin < pmin or smax > pmax then
        local msg = string.format(
            "metrics.%s band [%0.4f, %0.4f] is outside parent caps [%0.4f, %0.4f]",
            name, smin, smax, pmin, pmax
        )
        table.insert(errors, msg)
    end
end

-- Main validator
-- card: Lua table decoded from seedContractCard JSON
-- opts: optional table:
--   opts.region_caps_invariants: table with min/max for each invariant (CIC, AOS, etc.)
--   opts.region_caps_metrics: table with bands for each metric (UEC, EMD, etc.)
function M.validate_seed_contract_card(card, opts)
    local errors = {}

    if type(card) ~= "table" then
        return false, { "card must be a table (decoded JSON object)" }
    end

    -- Basic required fields (light check; JSON Schema should enforce shape)
    if card.scope ~= "seed" then
        table.insert(errors, "scope must be 'seed'")
    end
    if type(card.seedid) ~= "string" or card.seedid == "" then
        table.insert(errors, "seedid must be a non-empty string")
    end
    if type(card.styleid) ~= "string" or card.styleid == "" then
        table.insert(errors, "styleid must be a non-empty string")
    end

    -- Invariants range checks (semantic alignment with core invariants)
    local inv = card.invariants or {}
    local function check_inv(name, minv, maxv)
        local v = inv[name]
        if v == nil then
            table.insert(errors, "invariants." .. name .. " is required")
            return
        end
        if not in_range(v, minv, maxv) then
            local msg = string.format(
                "invariants.%s=%s must be within [%0.4f, %0.4f]",
                name,
                tostring(v),
                minv,
                maxv
            )
            table.insert(errors, msg)
        end
    end

    -- 0..1 invariants
    check_inv("CIC", 0.0, 1.0)
    check_inv("MDI", 0.0, 1.0)
    check_inv("AOS", 0.0, 1.0)
    check_inv("RRM", 0.0, 1.0)
    check_inv("FCF", 0.0, 1.0)
    check_inv("SPR", 0.0, 1.0)
    check_inv("RWF", 0.0, 1.0)
    check_inv("HVF", 0.0, 1.0)
    check_inv("LSG", 0.0, 1.0)
    check_inv("SHCI", 0.0, 1.0)

    -- DET 0..10 invariant
    check_inv("DET", 0.0, 10.0)

    -- Metrics bands (0..1, min <= max)
    local metrics = card.metrics or {}
    validate_metric_band("UEC", metrics.UEC, errors)
    validate_metric_band("EMD", metrics.EMD, errors)
    validate_metric_band("STCI", metrics.STCI, errors)
    validate_metric_band("CDL", metrics.CDL, errors)
    validate_metric_band("ARR", metrics.ARR, errors)

    -- Dead-Ledger reference minimal checks
    local dlr = card.deadledgerref
    if type(dlr) ~= "table" then
        table.insert(errors, "deadledgerref must be an object")
    else
        if type(dlr.proofenvelopeid) ~= "string" or dlr.proofenvelopeid == "" then
            table.insert(errors, "deadledgerref.proofenvelopeid must be a non-empty string")
        end
        if type(dlr.verifierref) ~= "string" or dlr.verifierref == "" then
            table.insert(errors, "deadledgerref.verifierref must be a non-empty string")
        end
        if type(dlr.circuittype) ~= "string" or dlr.circuittype == "" then
            table.insert(errors, "deadledgerref.circuittype must be a non-empty string")
        end
        if type(dlr.protocolversion) ~= "string" or dlr.protocolversion == "" then
            table.insert(errors, "deadledgerref.protocolversion must be a non-empty string")
        end
        if type(dlr.requiredproofs) ~= "table" or #dlr.requiredproofs == 0 then
            table.insert(errors, "deadledgerref.requiredproofs must be a non-empty array")
        end
    end

    -- Optional subset enforcement against region/policy caps
    opts = opts or {}
    local caps_inv = opts.region_caps_invariants
    local caps_met = opts.region_caps_metrics

    if type(caps_inv) == "table" then
        local function get_cap(name)
            local cap = caps_inv[name]
            if type(cap) ~= "table" then
                return nil, nil
            end
            return cap.min, cap.max
        end

        local min_cic, max_cic = get_cap("CIC")
        validate_subset_scalar("CIC", inv.CIC, min_cic, max_cic, errors)

        local min_aos, max_aos = get_cap("AOS")
        validate_subset_scalar("AOS", inv.AOS, min_aos, max_aos, errors)

        local min_det, max_det = get_cap("DET")
        validate_subset_scalar("DET", inv.DET, min_det, max_det, errors)

        local min_lsg, max_lsg = get_cap("LSG")
        validate_subset_scalar("LSG", inv.LSG, min_lsg, max_lsg, errors)

        local min_shci, max_shci = get_cap("SHCI")
        validate_subset_scalar("SHCI", inv.SHCI, min_shci, max_shci, errors)
    end

    if type(caps_met) == "table" then
        validate_subset_band("UEC", metrics.UEC, caps_met.UEC, errors)
        validate_subset_band("EMD", metrics.EMD, caps_met.EMD, errors)
        validate_subset_band("STCI", metrics.STCI, caps_met.STCI, errors)
        validate_subset_band("CDL", metrics.CDL, caps_met.CDL, errors)
        validate_subset_band("ARR", metrics.ARR, caps_met.ARR, errors)
    end

    local ok = (#errors == 0)
    return ok, errors
end

return M
