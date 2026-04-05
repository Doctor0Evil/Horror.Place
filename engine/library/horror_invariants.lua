-- engine/library/horror_invariants.lua
-- Horror.Place invariant query API.
-- All invariant getters should read from the master registry or cached bundles.
-- Never hardcode values; always delegate to the history layer.

local H = {}

-- Placeholder for engine bridge (implemented in C++ adapter or engine host).
-- The host is responsible for providing:
--   request_invariants(region_id, tile_id) -> table
--   get_player_metric(player_id, metric_name) -> number
--   log_violation(entry) -> ()
H.EngineBridge = H.EngineBridge or {}

-- Internal cache for invariant bundles (populated by H.load_bundle or engine bridge).
local _bundle_cache = {}

-- Compose a stable cache key for a region/tile pair.
local function _key(region_id, tile_id)
    return string.format("%d:%d", region_id, tile_id)
end

-- Load invariant bundle for a region/tile into cache.
-- @param region_id number
-- @param tile_id number
-- @param bundle table { CIC, MDI, AOS, RRM, FCF, SPR, SHCI, HVF, LSG, DET, RWF, EMD, STCI, ARR, ... }
function H.load_bundle(region_id, tile_id, bundle)
    local key = _key(region_id, tile_id)
    _bundle_cache[key] = bundle or {}
end

-- Get invariant bundle from cache or request from engine/host layer.
-- @param region_id number
-- @param tile_id number
-- @return table invariant_bundle
local function _get_bundle(region_id, tile_id)
    local key = _key(region_id, tile_id)
    local bundle = _bundle_cache[key]

    if not bundle and H.EngineBridge and H.EngineBridge.request_invariants then
        bundle = H.EngineBridge.request_invariants(region_id, tile_id) or {}
        _bundle_cache[key] = bundle
    end

    return bundle or {}
end

-------------------------------------------------------------------------------
-- Canonical geo-historical invariant getters
-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------
-- Experience metrics (per-player / per-tile)
-------------------------------------------------------------------------------

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
    if H.EngineBridge and H.EngineBridge.get_player_metric then
        return H.EngineBridge.get_player_metric(player_id, "UEC") or 0.5
    end
    return 0.5
end

-- Evidential Mystery Density is usually bound to region/tile history.
function H.EMD(region_id, tile_id)
    return _get_bundle(region_id, tile_id).EMD or 0.5
end

-- Safe-Threat Contrast Index, region/tile-level by default.
function H.STCI(region_id, tile_id)
    return _get_bundle(region_id, tile_id).STCI or 0.5
end

-- Cognitive Dissonance Load, per-player metric.
function H.CDL(player_id)
    if H.EngineBridge and H.EngineBridge.get_player_metric then
        return H.EngineBridge.get_player_metric(player_id, "CDL") or 0.5
    end
    return 0.5
end

-- Ambiguous Resolution Ratio, region/tile-level by default.
function H.ARR(region_id, tile_id)
    return _get_bundle(region_id, tile_id).ARR or 0.7
end

-------------------------------------------------------------------------------
-- History sampling helpers
-------------------------------------------------------------------------------

-- Returns a shallow snapshot of the geo-historical invariants only.
-- @return table { CIC, MDI, AOS, RRM, FCF, SPR, SHCI, HVF, LSG, RWF }
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
-- @param player_id number|nil
-- @return table {
--   CIC, MDI, AOS, RRM, FCF, SPR, SHCI, LSG, DET, RWF, HVF,
--   UEC, EMD, STCI, CDL, ARR
-- }
function H.sample_all(region_id, tile_id, player_id)
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
        DET  = H.DET(region_id, tile_id, player_id),
        RWF  = bundle.RWF or 1.0,
        HVF  = bundle.HVF or { mag = 0.0, dir = { x = 0, y = 0, z = 0 } },
        UEC  = player_id and H.UEC(player_id) or 0.5,
        EMD  = bundle.EMD or 0.5,
        STCI = bundle.STCI or 0.5,
        CDL  = player_id and H.CDL(player_id) or 0.5,
        ARR  = bundle.ARR or 0.7,
    }
end

-------------------------------------------------------------------------------
-- Telemetry / CI audit helpers
-------------------------------------------------------------------------------

-- Log a violation for telemetry/CI audit.
-- @param entry table
--   { mood_id, violation, region_id, tile_id, player_id?, reason?, invariant_snapshot? }
function H.log_violation(entry)
    if H.EngineBridge and H.EngineBridge.log_violation then
        H.EngineBridge.log_violation(entry)
    else
        -- Fallback: print to console for dev builds.
        local mood_id = entry.mood_id or "unknown_mood"
        local reason  = entry.reason or "unknown"
        print(string.format("[Horror.Place VIOLATION] %s: %s", mood_id, reason))
    end
end

return H
