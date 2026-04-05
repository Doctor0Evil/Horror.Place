-- moods/DreadForge_Resonance.Contract.lua
-- DreadForge_Resonance mood: spawn/battlefront/liminal integrity hooks.

local H     = require("engine.library.horror_invariants")
local Audio = require("engine.library.horror_audio")

local M = {}

-- Internal helper: check tile invariants against mood bands.
local function validate_tile(role, inv)
    -- In a full implementation, these ranges would be loaded
    -- from moods/mood.dreadforge_resonance.v1.json at build time.
    if role == "spawn_tile" then
        return inv.CIC >= 0.60 and inv.LSG >= 0.65 and inv.HVF.mag >= 0.40
    elseif role == "battlefront_tile" then
        return inv.CIC >= 0.70 and inv.HVF.mag >= 0.50
    elseif role == "liminal_tile" then
        return inv.LSG >= 0.75
    end
    return true
end

-- Called when a player is about to spawn into a tile governed by DreadForge_Resonance.
-- Returns a table describing whether spawn is allowed and which audio sequence to play.
function M.on_player_spawn(region_id, tile_id, player_id, role)
    local inv = H.sample_all(region_id, tile_id, player_id)

    if not validate_tile(role or "spawn_tile", inv) then
        return {
            allowed  = false,
            reason   = "DREADFORGE_SPAWN_INVARIANT_VIOLATION",
            fallback = "RESELECT_TILE"
        }
    end

    local seq = Audio.compose_spawn_sequence(region_id, tile_id, player_id)

    return {
        allowed = true,
        audio   = seq
    }
end

-- Called every frame or at a fixed tick while this mood is active.
-- Intended for ambience updates and soft pressure against camping.
function M.on_tick(delta_seconds, region_id, player_state)
    if not region_id or not player_state or not player_state.tile_id then
        return
    end

    local inv = H.sample_all(region_id, player_state.tile_id, player_state.player_id)

    -- Example: escalate ambience if player lingers in high-CIC spawn tiles.
    if inv.CIC >= 0.60 and inv.LSG >= 0.65 then
        Audio.sample_region_ambience(region_id, player_state.tile_id, player_state.player_id)
    end
end

return M
