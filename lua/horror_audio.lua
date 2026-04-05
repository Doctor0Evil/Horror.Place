-- lua/horror_audio.lua
-- Horror$Place Dread Conductor – invariant-driven SFX policy layer.

local H = require("horror_invariants")

local Audio = {}

-- Internal helper: quantize invariant values into coarse bands.
local function band(value)
    if value < 0.25 then return "low" end
    if value < 0.5  then return "mid" end
    if value < 0.75 then return "high" end
    return "extreme"
end

-- Returns an abstract ambience palette description for a region/tile.
-- The engine adapter maps these tags to concrete SFX events or banks.
function Audio.sample_region_ambience(region_id, tile_id)
    local cic = H.CIC(region_id, tile_id)
    local mdi = H.MDI(region_id, tile_id)
    local aos = H.AOS(region_id, tile_id)

    local cic_band = band(cic)
    local mdi_band = band(mdi)
    local aos_band = band(aos)

    local palette = {
        region_id = region_id,
        tile_id   = tile_id,
        tags      = {
            "ambience",
            "cic_" .. cic_band,
            "mdi_" .. mdi_band,
            "aos_" .. aos_band,
        },
        density   = cic,   -- 0–1: how many layers to aim for
        weirdness = mdi,   -- 0–1: how abstract/strange vs mundane
        opacity   = aos,   -- 0–1: how submerged vs clear
    }

    return palette
end

-- Select a liminal cue when crossing thresholds.
-- Returns an abstract cue descriptor; the engine decides the actual sound.
function Audio.select_liminal_cue(from_tile, to_tile)
    local lsg = H.LSG(to_tile)
    local hvf = H.HVF(to_tile)  -- assume vec or scalar magnitude

    local lsg_band = band(lsg)
    local hvf_mag  = hvf.magnitude or hvf

    local cue = {
        kind      = "threshold",
        intensity = lsg,
        tags      = {
            "liminal",
            "lsg_" .. lsg_band,
        },
        hvf_dir   = hvf.direction or 0.0,
        hvf_mag   = hvf_mag,
    }

    return cue
end

-- Compose a spawn sequence tied to local trauma and player DET.
function Audio.compose_spawn_sequence(region_id, tile_id, player_id)
    local cic   = H.CIC(region_id, tile_id)
    local det   = H.DET(player_id)
    local hist  = H.sample_history(region_id, tile_id)  -- abstract event slice
    local spr   = H.SPR(region_id, tile_id)
    local shci  = H.SHCI(region_id, tile_id)

    local cic_band  = band(cic)
    local det_band  = band(det)
    local spr_band  = band(spr)
    local shci_band = band(shci)

    local seq = {
        kind      = "spawn",
        duration  = 1.0 + det * 1.5, -- 1–2.5 seconds
        layers    = {},
        meta      = {
            cic_band  = cic_band,
            det_band  = det_band,
            spr_band  = spr_band,
            shci_band = shci_band,
        }
    }

    table.insert(seq.layers, {
        role = "body",
        tags = {
            "spawn_core",
            "cic_" .. cic_band,
            "spr_" .. spr_band,
        }
    })

    if shci > 0.5 then
        table.insert(seq.layers, {
            role = "history_echo",
            tags = {
                "history_echo",
                hist.archetype or "generic",
                "shci_" .. shci_band,
            }
        })
    end

    if det > 0.4 then
        table.insert(seq.layers, {
            role = "tinnitus",
            tags = {
                "ear_ringing",
                "det_" .. det_band,
            }
        })
    end

    return seq
end

-- Periodic update for ambient dread tuning (UEC, EMD, ARR).
-- Returns a set of RTPC-style parameters for the engine.
function Audio.compute_dread_rtpcs(player_id, region_id, tile_id)
    local cic = H.CIC(region_id, tile_id)
    local mdi = H.MDI(region_id, tile_id)
    local aos = H.AOS(region_id, tile_id)
    local hvf = H.HVF(region_id, tile_id)
    local det = H.DET(player_id)

    local uec = H.UEC(player_id)
    local emd = H.EMD(region_id, tile_id)
    local arr = H.ARR(region_id, tile_id)

    local rtpc = {
        cic_weight      = cic,
        aos_haze        = aos,
        mythic_density  = mdi,
        haunt_mag       = hvf.magnitude or hvf,
        dread_level     = det,
        uncertainty     = uec,
        mystery_density = emd,
        resolution_bias = arr,
    }

    return rtpc
end

return Audio
