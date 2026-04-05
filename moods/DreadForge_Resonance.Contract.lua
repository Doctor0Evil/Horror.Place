-- moods/DreadForge_Resonance.Contract.lua
-- DreadForge_Resonance mood: spawn/battlefront/liminal integrity hooks.
-- Version: 1.0.0
-- Canonical ID: mood.dreadforge_resonance.v1
-- Requires: engine.library.horror_invariants, engine.library.horror_audio

local H     = require("engine.library.horror_invariants")
local Audio = require("engine.library.horror_audio")

local M = {}

-- Internal helper: quantize invariant values into coarse bands for logging.
local function _band(value)
    if value < 0.25 then return "low" end
    if value < 0.50 then return "mid" end
    if value < 0.75 then return "high" end
    return "extreme"
end

-- Internal helper: validate tile invariants against mood bands.
-- Returns: boolean valid, string? reason
local function _validate_tile(role, inv, mood_config)
    local config = mood_config or {
        spawn_tile = {
            cic_min = 0.60, lsg_min = 0.65, hvf_min = 0.40
        },
        battlefront_tile = {
            cic_min = 0.70, hvf_min = 0.50
        },
        liminal_tile = {
            lsg_min = 0.75
        }
    }

    if role == "spawn_tile" then
        local c = config.spawn_tile
        if inv.CIC < c.cic_min then
            return false, string.format("CIC %.2f < %.2f (min)", inv.CIC, c.cic_min)
        end
        if inv.LSG < c.lsg_min then
            return false, string.format("LSG %.2f < %.2f (min)", inv.LSG, c.lsg_min)
        end
        if inv.HVF.mag < c.hvf_min then
            return false, string.format("HVF.mag %.2f < %.2f (min)", inv.HVF.mag, c.hvf_min)
        end
        return true, nil

    elseif role == "battlefront_tile" then
        local c = config.battlefront_tile
        if inv.CIC < c.cic_min then
            return false, string.format("CIC %.2f < %.2f (min)", inv.CIC, c.cic_min)
        end
        if inv.HVF.mag < c.hvf_min then
            return false, string.format("HVF.mag %.2f < %.2f (min)", inv.HVF.mag, c.hvf_min)
        end
        return true, nil

    elseif role == "liminal_tile" then
        local c = config.liminal_tile
        if inv.LSG < c.lsg_min then
            return false, string.format("LSG %.2f < %.2f (min)", inv.LSG, c.lsg_min)
        end
        return true, nil
    end

    -- Unknown role: pass through with warning logged upstream.
    return true, nil
end

-- Called when a player is about to spawn into a tile governed by DreadForge_Resonance.
-- Returns a table describing whether spawn is allowed and which audio sequence to play.
-- @param region_id number
-- @param tile_id number
-- @param player_id number
-- @param role string? one of "spawn_tile", "battlefront_tile", "liminal_tile"
-- @return table { allowed: boolean, audio?: table, reason?: string, fallback?: string }
function M.on_player_spawn(region_id, tile_id, player_id, role)
    assert(region_id and tile_id and player_id, "on_player_spawn requires region_id, tile_id, player_id")

    local inv = H.sample_all(region_id, tile_id, player_id)
    local role_key = role or "spawn_tile"
    local valid, reason = _validate_tile(role_key, inv)

    if not valid then
        -- Log violation for telemetry/CI audit.
        H.log_violation({
            mood_id      = "mood.dreadforge_resonance.v1",
            violation    = "INVARIANT_BAND_FAILURE",
            region_id    = region_id,
            tile_id      = tile_id,
            player_id    = player_id,
            role         = role_key,
            reason       = reason,
            invariant_snapshot = inv
        })

        return {
            allowed  = false,
            reason   = "DREADFORGE_SPAWN_INVARIANT_VIOLATION: " .. (reason or "unknown"),
            fallback = "RESELECT_TILE"
        }
    end

    -- Compose audio sequence based on local invariants.
    local seq = Audio.compose_spawn_sequence(region_id, tile_id, player_id, {
        mood_id = "mood.dreadforge_resonance.v1",
        role    = role_key
    })

    return {
        allowed = true,
        audio   = seq,
        meta    = {
            cic_band = _band(inv.CIC),
            lsg_band = _band(inv.LSG),
            hvf_band = _band(inv.HVF.mag)
        }
    }
end

-- Called every frame or at a fixed tick while this mood is active.
-- Intended for ambience updates and soft pressure against camping.
-- @param delta_seconds number
-- @param region_id number
-- @param player_state table { player_id, tile_id, position?, velocity? }
function M.on_tick(delta_seconds, region_id, player_state)
    if not region_id or not player_state or not player_state.tile_id then
        return
    end

    local inv = H.sample_all(region_id, player_state.tile_id, player_state.player_id)

    -- Escalate ambience if player lingers in high-CIC spawn tiles (anti-camping).
    if inv.CIC >= 0.60 and inv.LSG >= 0.65 then
        Audio.sample_region_ambience(region_id, player_state.tile_id, player_state.player_id, {
            mood_id = "mood.dreadforge_resonance.v1",
            pressure_factor = math.min(1.0, inv.CIC * inv.LSG)
        })
    end

    -- Optional: nudge player away from spawn perimeters via HVF-aware audio cues.
    if inv.HVF.mag >= 0.40 and inv.HVF.dir then
        Audio.apply_hvf_directional_cue(player_state.player_id, inv.HVF, {
            fade_rate = 0.02 * delta_seconds
        })
    end
end

-- Optional debug helper for CI/test harnesses.
function M.get_mood_config()
    return {
        mood_id = "mood.dreadforge_resonance.v1",
        version = "1.0.0",
        required_hooks = { "on_player_spawn", "on_tick" }
    }
end

return M
