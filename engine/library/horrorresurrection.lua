-- engine/library/horrorresurrection.lua
-- Resurrection helpers: compute novelty, gate reuse, and surface diffs.

local H       = require("engine.library.horrorinvariants")
local Metrics = require("engine.library.horrormetrics")   -- thin wrapper over UEC/EMD/STCI/CDL/ARR
local json    = require("dkjson")                         -- or your preferred JSON lib

local Resurrection = {}

-- Internal: compute a simple invariant+metric distance between ancestor and candidate.
local function compute_distance(a, b)
    if not a or not b then
        return 1.0
    end
    local keys = {
        "CIC","MDI","AOS","RRM","FCF","SPR","RWF","DET","LSG","SHCI",
        "UEC","EMD","STCI","CDL","ARR"
    }
    local acc, count = 0.0, 0
    for _, k in ipairs(keys) do
        local av = a[k]
        local bv = b[k]
        if type(av) == "number" and type(bv) == "number" then
            local d = math.abs(av - bv)
            acc   = acc + d * d
            count = count + 1
        end
    end
    if count == 0 then
        return 1.0
    end
    return math.sqrt(acc / count)
end

-- Query ancestor profile from history layer + telemetry.
-- Contract: returns a flat table of invariants + metrics.
function Resurrection.sample_ancestor_profile(region_id, tile_id, player_id, ancestor_id)
    -- You can later route ancestor_id into Atrocity-Seeds / Dead-Ledger.
    local inv = H.sampleAll(region_id, tile_id, player_id)
    local met = Metrics.samplePlayer(player_id)
    local out = {}
    out.CIC  = inv.CIC
    out.MDI  = inv.MDI
    out.AOS  = inv.AOS
    out.RRM  = inv.RRM
    out.FCF  = inv.FCF
    out.SPR  = inv.SPR
    out.RWF  = inv.RWF
    out.DET  = inv.DET
    out.HVF  = inv.HVF and inv.HVF.mag or nil
    out.LSG  = inv.LSG
    out.SHCI = inv.SHCI

    out.UEC  = met.UEC
    out.EMD  = met.EMD
    out.STCI = met.STCI
    out.CDL  = met.CDL
    out.ARR  = met.ARR

    return out
end

-- Decide whether a resurrection is allowed given ancestor + candidate bands.
-- novelty_threshold is a scalar in [0,1]; higher = demand bigger change.
function Resurrection.allow(ancestor_profile, candidate_profile, novelty_threshold)
    local dist = compute_distance(ancestor_profile, candidate_profile)
    local allowed = dist >= (novelty_threshold or 0.15)
    return {
        allowed = allowed,
        distance = dist,
        noveltyThreshold = novelty_threshold or 0.15,
    }
end

-- Convenience: compute and log a resurrection diff summary for CI / telemetry.
function Resurrection.diff_summary(ancestor_profile, candidate_profile)
    local keys = {
        "CIC","AOS","HVF","LSG","DET","UEC","EMD","STCI","CDL","ARR","SHCI"
    }
    local rows = {}
    for _, k in ipairs(keys) do
        local a = ancestor_profile[k]
        local c = candidate_profile[k]
        if type(a) == "number" and type(c) == "number" then
            table.insert(rows, {
                key      = k,
                ancestor = a,
                current  = c,
                delta    = c - a,
            })
        end
    end
    return rows
end

-- Runtime gate used by mood/event/seed logic.
-- Returns { allowed=bool, reason=string, summary=table }.
function Resurrection.gate_resurrection(args)
    local ancestor   = args.ancestorProfile
    local candidate  = args.candidateProfile
    local threshold  = args.noveltyThreshold or 0.15
    local res        = Resurrection.allow(ancestor, candidate, threshold)
    local summary    = Resurrection.diff_summary(ancestor, candidate)

    local reason
    if not res.allowed then
        reason = "RESURRECTION_TOO_SIMILAR"
    else
        reason = "OK"
    end

    return {
        allowed  = res.allowed,
        reason   = reason,
        distance = res.distance,
        summary  = summary,
    }
end

-- Helper to pretty-print diffs in a dev console or CI log.
function Resurrection.pretty_print_summary(summary, out_fn)
    local write = out_fn or print
    write("=== Resurrection diff summary ===")
    for _, row in ipairs(summary) do
        write(string.format(
            "%-4s: ancestor=%.3f current=%.3f delta=%+.3f",
            row.key, row.ancestor, row.current, row.delta
        ))
    end
end

return Resurrection
