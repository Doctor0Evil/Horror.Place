-- public-api/hdirector.lua
local H = H or {}

-- Request that the runtime execute a surprise/relief beat.
-- The real implementation lives in private vault / engine repos.
function H.Director.requestBeat(sessionId, context)
    -- context is a table with regionId, tileId, metrics snapshot, etc.
    -- In public core, this is a stub; it MUST NOT contain decision heuristics.
    return {
        ok = false,
        data = nil,
        error = {
            code = "DIRECTOR_NOT_IMPLEMENTED",
            message = "Director implementation is provided by private vaults."
        }
    }
end

-- Engine calls this to notify that a director instruction was executed.
function H.Director.logDecision(sessionId, decisionEnvelope)
    -- decisionEnvelope must validate against director-decision-eventv1 schema.
    -- Public stub: no-op for now, but defines the shape for telemetry.
    return { ok = true, data = {}, error = nil }
end

return H
