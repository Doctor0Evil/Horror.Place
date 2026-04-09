-- horrorresurrection.lua
-- Canonical resurrection helper surface under H.Resurrection.

local H = require("engine.library.horrorinvariants")

local Resurrection = {}

-- Compute a normalized drift score in [0,1] between ancestor and candidate
-- using invariant and metric vectors. This is the core "freshness" distance.
-- In a full implementation, ancestorSummary should be loaded from registry/
-- and telemetry aggregates; here we assume callers pass both tables in.
function Resurrection.computeDrift(ancestor, candidate)
    if not ancestor or not candidate then
        return 1.0
    end

    local function clamp01(x)
        if x < 0.0 then
            return 0.0
        elseif x > 1.0 then
            return 1.0
        else
            return x
        end
    end

    local function sq(x)
        return x * x
    end

    -- Sample a small, stable subset of invariants and metrics.
    local keys = {
        "CIC",
        "MDI",
        "AOS",
        "DET",
        "UEC",
        "EMD",
        "STCI",
        "CDL",
        "ARR"
    }

    local accum = 0.0
    local count = 0

    for _, k in ipairs(keys) do
        local a = ancestor[k]
        local b = candidate[k]
        if type(a) == "number" and type(b) == "number" then
            accum = accum + sq(b - a)
            count = count + 1
        end
    end

    if count == 0 then
        return 1.0
    end

    local meanSq = accum / count
    -- Normalize: assume max meaningful distance ~1.0.
    return clamp01(math.sqrt(meanSq))
end

-- Pre-flight check: determine if a resurrection candidate is allowed
-- under the given resurrectionProfile and ancestor summary.
--
-- Inputs:
--   resurrectionProfile: table conforming to resurrection-profile-v1 schema.
--   ancestorSummary:     table of invariants/metrics for originId.
--   candidateSummary:    table of invariants/metrics for proposed contract.
--
-- Returns:
--   result: table {
--     allowed = boolean,
--     reason  = string|nil,
--     drift   = number,
--     thresholds = { minDrift = ..., maxDrift = ..., cloneBand = ... }
--   }
function Resurrection.preflight(resurrectionProfile, ancestorSummary, candidateSummary)
    local result = {
        allowed = true,
        reason = nil,
        drift = 1.0,
        thresholds = {}
    }

    if not resurrectionProfile or not ancestorSummary or not candidateSummary then
        result.allowed = false
        result.reason = "MISSING_PROFILE_OR_SUMMARY"
        return result
    end

    local novelty = resurrectionProfile.novelty or {}
    local minDrift = novelty.minDrift or 0.0
    local maxDrift = novelty.maxDrift or 1.0
    local cloneBand = novelty.cloneBandThreshold or 0.05

    result.thresholds.minDrift = minDrift
    result.thresholds.maxDrift = maxDrift
    result.thresholds.cloneBand = cloneBand

    local drift = Resurrection.computeDrift(ancestorSummary, candidateSummary)
    result.drift = drift

    -- Reject near-clones.
    if drift <= cloneBand then
        result.allowed = false
        result.reason = "DRIFT_BELOW_CLONE_BAND"
        return result
    end

    -- Enforce minimum novelty.
    if drift < minDrift then
        result.allowed = false
        result.reason = "DRIFT_BELOW_MIN"
        return result
    end

    -- Enforce maximum acceptable change.
    if drift > maxDrift then
        result.allowed = false
        result.reason = "DRIFT_ABOVE_MAX"
        return result
    end

    -- Optional invariant-specific checks (HVF/LSG rotation) can be layered here
    -- by inspecting resurrectionProfile.invariantDeltas.

    return result
end

-- Runtime scheduling helper: decide whether to schedule a resurrection
-- given current budgetState and player/session metrics.
--
-- Inputs:
--   resurrectionProfile: table as above.
--   budgetState:         table { usedThisSession = int, lastSeenAt = number|nil, now = number, regionId = ..., tileClass = ... }
--   playerMetrics:       table { DET = number, UEC = number, ARR = number }
--
-- Returns:
--   allowed: boolean
--   reason:  string|nil
function Resurrection.schedule(resurrectionProfile, budgetState, playerMetrics)
    if not resurrectionProfile or not budgetState or not playerMetrics then
        return false, "MISSING_INPUT"
    end

    local pacing = resurrectionProfile.pacing or {}
    local maxPerSession = pacing.maxPerSession or math.huge
    local cooldown = pacing.cooldownSeconds or 0.0

    if budgetState.usedThisSession and budgetState.usedThisSession >= maxPerSession then
        return false, "SESSION_LIMIT_REACHED"
    end

    if budgetState.lastSeenAt and budgetState.now and (budgetState.now - budgetState.lastSeenAt) < cooldown then
        return false, "COOLDOWN_ACTIVE"
    end

    -- Use player metrics to decide whether resurrection should restore mystery.
    local metrics = resurrectionProfile.metricTargets or {}
    local arrBand = metrics.ARR or {}

    local arrMin = arrBand.min or 0.0
    local currentARR = playerMetrics.ARR or 0.0

    if currentARR >= arrMin then
        -- ARR already high enough; avoid cheap repetition.
        return false, "ARR_ALREADY_HIGH"
    end

    -- Respect DET safety caps when present.
    local safety = metrics.safetyCaps or {}
    local detCap = safety.DET
    if detCap and playerMetrics.DET and playerMetrics.DET >= detCap then
        return false, "DET_CAP_REACHED"
    end

    return true, nil
end

-- Runtime helper to block overly perfect recall.
-- SPR/SHCI are read via H.sampleAll.
function Resurrection.blockIfRecallTooPerfect(regionId, tileId, playerId, thresholds)
    thresholds = thresholds or {}
    local sprCap = thresholds.SPR or 0.95
    local shciCap = thresholds.SHCI or 0.95

    local inv = H.sampleall(regionId, tileId, playerId)
    if not inv then
        return false
    end

    local spr = inv.SPR or 0.0
    local shci = inv.SHCI or 0.0

    if spr >= sprCap and shci >= shciCap then
        return true
    end

    return false
end

return Resurrection
