-- engine/library/horror_invariants.lua
-- Canonical H. invariants + metrics runtime surface (Tier 1)
-- All invariant getters should read from promoted bundles or the engine bridge.
-- Never hardcode values; always delegate to the history layer or telemetry.

local H = {}

-- Optional engine bridge (implemented in C++ adapter or engine host).
-- The host is responsible for providing:
--   request_invariants(region_id, tile_id) -> table
--   get_player_metric(player_id, metric_name) -> number
--   log_violation(entry) -> ()
H.EngineBridge = H.EngineBridge or {}

-- Internal cache for invariant bundles (region/tile keyed).
local _bundle_cache = {}

-- Internal state for per-player metrics snapshots (optional).
local _players = {}

----------------------------------------------------------------
-- Cache key helpers
----------------------------------------------------------------

local function _key(region_id, tile_id)
    -- region_id and tile_id are typically numeric; stringify defensively.
    return tostring(region_id) .. ":" .. tostring(tile_id)
end

local function _get_bundle(region_id, tile_id)
    local key = _key(region_id, tile_id)
    local bundle = _bundle_cache[key]

    if not bundle and H.EngineBridge and H.EngineBridge.request_invariants then
        bundle = H.EngineBridge.request_invariants(region_id, tile_id) or {}
        _bundle_cache[key] = bundle
    end

    return bundle or {}
end

----------------------------------------------------------------
-- Registration / hydration
----------------------------------------------------------------

--- Install or update a region/tile invariant bundle in the cache.
--- bundle is expected to carry:
---   CIC, MDI, AOS, RRM, FCF, SPR, SHCI, HVF, LSG, DET, RWF,
---   EMD, STCI, ARR, and optional DET_player map.
function H.load_bundle(region_id, tile_id, bundle)
    local key = _key(region_id, tile_id)
    _bundle_cache[key] = bundle or {}
end

--- Install or update a player experience metrics snapshot.
--- data: table with fields uec, emd, stci, cdl, arr
function H.register_player(player_id, data)
    assert(type(player_id) == "string" or type(player_id) == "number", "player_id must be id-like")
    assert(type(data) == "table", "data must be table")
    _players[player_id] = {
        uec  = data.uec  or 0.0,
        emd  = data.emd  or 0.0,
        stci = data.stci or 0.0,
        cdl  = data.cdl  or 0.0,
        arr  = data.arr  or 0.0,
    }
end

local function _player(player_id)
    return _players[player_id]
end

----------------------------------------------------------------
-- Canonical geo-historical invariant getters
----------------------------------------------------------------

function H.CIC(region_id, tile_id)
    return _get_bundle(region_id, tile_id).CIC or 0.0
end

function H.MDI(region_id, tile_id)
    return _get_bundle(region_id, tile_id).MDI or 0.0
end

function H.AOS(region_id, tile_id)
    return _get_bundle(region_id, tile_id).AOS or 0.0
end

function H.RRM(region_id, tile_id)
    return _get_bundle(region_id, tile_id).RRM or 0.0
end

function H.FCF(region_id, tile_id)
    return _get_bundle(region_id, tile_id).FCF or 0.0
end

function H.SPR(region_id, tile_id)
    return _get_bundle(region_id, tile_id).SPR or 0.0
end

function H.SHCI(region_id, tile_id)
    return _get_bundle(region_id, tile_id).SHCI or 0.0
end

function H.LSG(region_id, tile_id)
    return _get_bundle(region_id, tile_id).LSG or 0.0
end

-- Haunt Vector Field: returns a table { mag = 0.0-1.0, dir = { x, y, z } }.
function H.HVF(region_id, tile_id)
    local bundle = _get_bundle(region_id, tile_id)
    return bundle.HVF or { mag = 0.0, dir = { x = 0, y = 0, z = 0 } }
end

-- Reliability Weighting Factor for local sources.
function H.RWF(region_id, tile_id)
    return _get_bundle(region_id, tile_id).RWF or 1.0
end

----------------------------------------------------------------
-- Experience metrics (per-player / per-tile)
----------------------------------------------------------------

-- Dread Exposure Threshold may be player-specific; fall back to tile default.
function H.DET(region_id, tile_id, player_id)
    local bundle = _get_bundle(region_id, tile_id)
    if player_id and bundle.DET_player then
        local per_player = bundle.DET_player[player_id]
        if per_player ~= nil then
            return per_player
        end
    end
    return bundle.DET or 0.0
end

-- Uncertainty Engagement Coefficient is typically telemetry-derived.
function H.UEC(player_id)
    local p = _player(player_id)
    if p and p.uec ~= nil then
        return p.uec
    end
    if H.EngineBridge and H.EngineBridge.get_player_metric then
        return H.EngineBridge.get_player_metric(player_id, "UEC") or 0.5
    end
    return 0.5
end

-- Evidential Mystery Density; prefer per-player snapshot, fall back to bundle.
function H.EMD(region_id, tile_id, player_id)
    local p = player_id and _player(player_id) or nil
    if p and p.emd ~= nil then
        return p.emd
    end
    return _get_bundle(region_id, tile_id).EMD or 0.5
end

-- Safe-Threat Contrast Index.
function H.STCI(region_id, tile_id, player_id)
    local p = player_id and _player(player_id) or nil
    if p and p.stci ~= nil then
        return p.stci
    end
    return _get_bundle(region_id, tile_id).STCI or 0.5
end

-- Cognitive Dissonance Load, per-player metric.
function H.CDL(player_id)
    local p = _player(player_id)
    if p and p.cdl ~= nil then
        return p.cdl
    end
    if H.EngineBridge and H.EngineBridge.get_player_metric then
        return H.EngineBridge.get_player_metric(player_id, "CDL") or 0.5
    end
    return 0.5
end

-- Ambiguous Resolution Ratio; player snapshot beats bundle.
function H.ARR(region_id, tile_id, player_id)
    local p = player_id and _player(player_id) or nil
    if p and p.arr ~= nil then
        return p.arr
    end
    return _get_bundle(region_id, tile_id).ARR or 0.7
end

----------------------------------------------------------------
-- Sampling helpers (for AI-chat, PCG, and diagnostics)
----------------------------------------------------------------

-- Returns a shallow snapshot of the geo-historical invariants only.
function H.sample_history(region_id, tile_id)
    local bundle = _get_bundle(region_id, tile_id)
    return {
        CIC  = bundle.CIC or 0.0,
        MDI  = bundle.MDI or 0.0,
        AOS  = bundle.AOS or 0.0,
        RRM  = bundle.RRM or 0.0,
        FCF  = bundle.FCF or 0.0,
        SPR  = bundle.SPR or 0.0,
        SHCI = bundle.SHCI or 0.0,
        LSG  = bundle.LSG or 0.0,
        RWF  = bundle.RWF or 1.0,
        HVF  = bundle.HVF or { mag = 0.0, dir = { x = 0, y = 0, z = 0 } },
    }
end

-- Sample all invariants + metrics for a region/tile/player in one call.
function H.sample_all(region_id, tile_id, player_id)
    local bundle = _get_bundle(region_id, tile_id)
    local p = player_id and _player(player_id) or nil

    return {
        CIC  = bundle.CIC or 0.0,
        MDI  = bundle.MDI or 0.0,
        AOS  = bundle.AOS or 0.0,
        RRM  = bundle.RRM or 0.0,
        FCF  = bundle.FCF or 0.0,
        SPR  = bundle.SPR or 0.0,
        SHCI = bundle.SHCI or 0.0,
        LSG  = bundle.LSG or 0.0,
        DET  = H.DET(region_id, tile_id, player_id),
        RWF  = bundle.RWF or 1.0,
        HVF  = bundle.HVF or { mag = 0.0, dir = { x = 0, y = 0, z = 0 } },

        UEC  = player_id and H.UEC(player_id) or 0.5,
        EMD  = H.EMD(region_id, tile_id, player_id),
        STCI = H.STCI(region_id, tile_id, player_id),
        CDL  = player_id and H.CDL(player_id) or 0.5,
        ARR  = H.ARR(region_id, tile_id, player_id),
    }
end

----------------------------------------------------------------
-- Telemetry / CI audit helpers
----------------------------------------------------------------

-- Log a violation for telemetry/CI audit.
-- entry: { mood_id, violation, region_id, tile_id, player_id?, reason?, invariant_snapshot? }
function H.log_violation(entry)
    if H.EngineBridge and H.EngineBridge.log_violation then
        H.EngineBridge.log_violation(entry)
    else
        local mood_id = entry.mood_id or "unknown_mood"
        local reason  = entry.reason or "unknown"
        print(string.format("[Horror.Place VIOLATION] %s: %s", mood_id, reason))
    end
end

return H
