-- engine/library/horror_audio.lua
local H     = require("horror_invariants")
local Audio = {}

function Audio.compose_spawn_sequence(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    local seq = {
        layers = {},
        rtpc   = {}
    }

    -- Example policy: trauma bed from CIC
    if inv.CIC > 0.6 then
        table.insert(seq.layers, {
            tag      = "trauma_bed",
            weight   = inv.CIC,
            spatial  = true,
            falloff  = "medium"
        })
    end

    -- Liminal tinnitus if DET high
    if inv.DET > 0.7 then
        table.insert(seq.layers, {
            tag    = "liminal_tinnitus",
            weight = inv.DET,
            spatial = false
        })
    end

    -- Archival glitches from AOS
    if inv.AOS > 0.5 then
        table.insert(seq.layers, {
            tag    = "archival_static",
            weight = inv.AOS,
            spatial = true
        })
    end

    -- RTPC envelope from UEC/EMD/ARR
    seq.rtpc["dread_intensity"] = math.max(inv.CIC, inv.DET)
    seq.rtpc["cue_clarity"]     = 1.0 - inv.UEC

    return seq
end

function Audio.sample_region_ambience(region_id, tile_id, player_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    local ambience = {
        beds   = {},
        motifs = {},
        rtpc   = {}
    }

    if inv.CIC > 0.4 then table.insert(ambience.beds, "low_drones") end
    if inv.RRM > 0.5 then table.insert(ambience.motifs, "ritual_bells") end
    if inv.HVF.mag > 0.4 then ambience.rtpc["whisper_pan"] = inv.HVF.dir.x end

    return ambience
end

return Audio
