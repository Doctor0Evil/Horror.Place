-- engine/library/horror_invariants.lua
local H = {}

-- Geo-historical invariants
function H.CIC(region_id, tile_id) end
function H.MDI(region_id, tile_id) end
function H.AOS(region_id, tile_id) end
function H.RRM(region_id, tile_id) end
function H.HVF(region_id, tile_id) end -- returns {mag = 0.0-1.0, dir = {x,y}}

function H.LSG(region_id, tile_id) end
function H.SPR(region_id, tile_id) end
function H.SHCI(region_id, tile_id) end

-- Experience metrics (per-player)
function H.DET(player_id) end
function H.UEC(player_id) end
function H.EMD(player_id) end
function H.STCI(player_id) end
function H.CDL(player_id) end
function H.ARR(player_id) end

-- History sampling
function H.sample_history(region_id, tile_id) end
function H.sample_all(region_id, tile_id, player_id) end

return H
