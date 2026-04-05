-- horror_audio.lua

local H = require("horror_invariants")   -- canonical invariants API
local Audio = {}

function Audio.update_region_ambience(region_id, tile_id)
    local cic = H.CIC(region_id, tile_id)
    local aos = H.AOS(region_id, tile_id)
    local mdi = H.MDI(region_id, tile_id)

    local palette = H.Audio.sample_palette(region_id, tile_id, cic, mdi, aos)
    H.EngineAudio.set_ambience_layers(region_id, tile_id, palette)
end

function Audio.on_threshold_cross(player_id, from_tile, to_tile)
    local lsg = H.LSG(to_tile)
    local hvf = H.HVF(to_tile)

    local cue = H.Audio.select_liminal_cue(lsg, hvf)
    H.EngineAudio.play_3d_cue(player_id, cue)
end

function Audio.on_spawn(player_id, spawn_id, context)
    local cic = H.CIC(context.region_id, context.tile_id)
    local det = H.DET(player_id)
    local history = H.sample_history(context.region_id, context.tile_id)

    local seq = H.Audio.compose_spawn_sequence(cic, det, history)
    H.EngineAudio.play_sequence(player_id, seq)
end

return Audio
