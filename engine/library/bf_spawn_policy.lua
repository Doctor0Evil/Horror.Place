-- engine/library/bf_spawn_policy.lua
local H  = require("horror_invariants")
local BF = {}

function BF.score_spawn_tile(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)

    local safety_score = 1.0 - inv.CIC
    local dread_score  = inv.CIC + inv.LSG + inv.HVF.mag

    local camping_risk = safety_score * (1.0 - inv.UEC)

    return {
        dread_score   = dread_score,
        camping_risk  = camping_risk,
        valid_for_df  = (inv.CIC > 0.6 and inv.LSG > 0.65)
    }
end

return BF
