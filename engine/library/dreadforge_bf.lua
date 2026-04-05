-- engine/library/dreadforge_bf.lua
local H     = require("horror_invariants")
local Audio = require("horror_audio")

local BF = {}

local CONTRACT = {
    cic_min = 0.60,
    lsg_min = 0.65,
    hvf_min = 0.40,
    uec_min = 0.55,
    emd_min = 0.60,
    arr_min = 0.70
}

local function validate_spawn_tile(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)

    if inv.CIC < CONTRACT.cic_min then
        return false, "CIC_TOO_LOW"
    end
    if inv.LSG < CONTRACT.lsg_min then
        return false, "LSG_TOO_LOW"
    end
    if inv.HVF.mag < CONTRACT.hvf_min then
        return false, "HVF_TOO_WEAK"
    end
    return true, nil
end

function BF.on_player_spawn(region_id, tile_id, player_id)
    local ok, reason = validate_spawn_tile(region_id, tile_id, player_id)
    if not ok then
        return {
            allowed  = false,
            reason   = reason,
            fallback = "RESELECT_TILE"
        }
    end

    local seq = Audio.compose_spawn_sequence(region_id, tile_id, player_id)
    return {
        allowed = true,
        audio   = seq
    }
end

return BF
