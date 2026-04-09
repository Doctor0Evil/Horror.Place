-- moods/HauntedReservoir.ResurrectionEcho.Contract.lua

local H            = require("engine.library.horrorinvariants")
local Metrics      = require("engine.library.horrormetrics")
local Resurrection = require("engine.library.horrorresurrection")

local M = {}

-- Configurable policy for this mood/event family.
local POLICY = {
    noveltyThreshold = 0.18,
    maxResurrectionsPerSession = 3,
}

-- Example state; in a real engine this lives in a Director table keyed by session.
local session_resurrections = {}

local function get_session_key(session_id, origin_id)
    return (session_id or "anon") .. "::" .. (origin_id or "unknown")
end

function M.onEventAttempt(ctx)
    -- ctx: { sessionId, regionId, tileId, playerId, originId, candidateProfile }
    local key = get_session_key(ctx.sessionId, ctx.originId)
    local count = session_resurrections[key] or 0
    if count >= POLICY.maxResurrectionsPerSession then
        return {
            allowed = false,
            reason  = "RESURRECTION_BUDGET_EXCEEDED",
            fallback = "USE_ARCHIVIST_VARIANT",
        }
    end

    local ancestor_profile = Resurrection.sample_ancestor_profile(
        ctx.regionId,
        ctx.tileId,
        ctx.playerId,
        ctx.originId
    )

    local gate = Resurrection.gate_resurrection{
        ancestorProfile   = ancestor_profile,
        candidateProfile  = ctx.candidateProfile,
        noveltyThreshold  = POLICY.noveltyThreshold,
    }

    if not gate.allowed then
        return {
            allowed  = false,
            reason   = gate.reason,
            distance = gate.distance,
            summary  = gate.summary,
            fallback = "USE_MISDIRECTED_TESTIMONY",
        }
    end

    session_resurrections[key] = count + 1

    return {
        allowed  = true,
        reason   = "OK",
        distance = gate.distance,
        summary  = gate.summary,
        -- high-level intent for engine adapters:
        audio    = { cue = "resurrection_echo", intensity = 0.8 },
        visuals  = { styleId = "SPECTRALENGRAVINGDARKSUBLIME", mode = "echo" },
        metrics  = { UECdelta = 0.12, EMDdelta = 0.15, ARRmin = 0.78 },
    }
end

return M
