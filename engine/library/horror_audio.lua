-- engine/library/horror_audio.lua
-- Horror.Place audio policy layer.
-- Maps invariants (CIC, AOS, LSG, HVF, etc.) to abstract audio descriptors.
-- Never calls engine-specific audio APIs directly; returns tags/RTPC bundles.

local H = require("engine.library.horror_invariants")

local Audio = {}

-- Internal helper: quantize invariant values into coarse bands.
local function _band(value)
    if value < 0.25 then return "low" end
    if value < 0.50 then return "mid" end
    if value < 0.75 then return "high" end
    return "extreme"
end

-- Compose a spawn audio sequence based on local invariants and mood context.
-- @param region_id number
-- @param tile_id number
-- @param player_id number
-- @param context table? { mood_id, role }
-- @return table abstract_sequence { pattern_id, layers[], duration, meta }
function Audio.compose_spawn_sequence(region_id, tile_id, player_id, context)
    local inv = H.sample_all(region_id, tile_id, player_id)
    local mood = context and context.mood_id or "unknown"
    local role = context and context.role or "spawn_tile"

    local cic_band = _band(inv.CIC)
    local lsg_band = _band(inv.LSG)
    local det_band = _band(inv.DET)
    local shci_band = _band(inv.SHCI)

    local seq = {
        pattern_id = string.format("%s_%s_spawn", mood, role),
        duration   = 1.0 + inv.DET * 1.5,  -- 1.0–2.5 seconds
        layers     = {},
        meta       = {
            cic_band  = cic_band,
            lsg_band  = lsg_band,
            det_band  = det_band,
            shci_band = shci_band
        }
    }

    -- Core trauma echo layer (always present).
    table.insert(seq.layers, {
        role = "core_trauma",
        tags = {
            "spawn_core",
            "cic_" .. cic_band,
            "role_" .. role
        },
        weight = inv.CIC
    })

    -- Historical echo layer (if SHCI is high enough).
    if inv.SHCI > 0.50 then
        table.insert(seq.layers, {
            role = "history_echo",
            tags = {
                "history_echo",
                "shci_" .. shci_band,
                "region_" .. region_id
            },
            weight = inv.SHCI
        })
    end

    -- Tinnitus/ear-ringing layer (if DET is elevated).
    if inv.DET > 0.40 then
        table.insert(seq.layers, {
            role = "tinnitus",
            tags = {
                "ear_ringing",
                "det_" .. det_band
            },
            weight = inv.DET * 0.5
        })
    end

    -- Liminal stress filter (if LSG is high).
    if inv.LSG > 0.65 then
        table.insert(seq.layers, {
            role = "liminal_filter",
            tags = {
                "threshold_bend",
                "lsg_" .. lsg_band
            },
            rtpc = {
                filter_cutoff = 1200 + (inv.LSG * 800),
                reverb_mix    = 0.3 + (inv.LSG * 0.4)
            }
        })
    end

    return seq
end

-- Update region ambience based on invariants and player state.
-- @param region_id number
-- @param tile_id number
-- @param player_id number
-- @param options table? { mood_id, pressure_factor }
function Audio.sample_region_ambience(region_id, tile_id, player_id, options)
    local inv = H.sample_all(region_id, tile_id, player_id)
    local opts = options or {}
    local pressure = opts.pressure_factor or 1.0

    local cic_band = _band(inv.CIC)
    local aos_band = _band(inv.AOS)
    local mdi_band = _band(inv.MDI)

    local palette = {
        region_id = region_id,
        tile_id   = tile_id,
        tags      = {
            "ambience",
            "cic_" .. cic_band,
            "aos_" .. aos_band,
            "mdi_" .. mdi_band
        },
        density   = math.min(1.0, inv.CIC * pressure),
        weirdness = inv.MDI,
        opacity   = inv.AOS,
        rtpc      = {
            cic_weight      = inv.CIC,
            aos_haze        = inv.AOS,
            mythic_density  = inv.MDI,
            haunt_mag       = inv.HVF.mag,
            dread_level     = inv.DET,
            uncertainty     = H.UEC(player_id),
            mystery_density = inv.EMD,
            resolution_bias = inv.ARR
        }
    }

    -- Dispatch to engine bridge for actual audio layer activation.
    if H.EngineAudio and H.EngineAudio.set_ambience_layers then
        H.EngineAudio.set_ambience_layers(region_id, tile_id, palette)
    end

    return palette
end

-- Apply HVF-aware directional audio cue (for anti-camping pressure).
-- @param player_id number
-- @param hvf table { mag, dir { x, y, z } }
-- @param options table? { fade_rate }
function Audio.apply_hvf_directional_cue(player_id, hvf, options)
    local opts = options or {}
    local cue = {
        kind      = "hvf_directional",
        intensity = hvf.mag,
        direction = hvf.dir,
        tags      = {
            "haunt_vector",
            "directional_whisper"
        },
        rtpc      = {
            pan_speed = (opts.fade_rate or 0.02) * hvf.mag,
            doppler   = hvf.mag * 0.3
        }
    }

    if H.EngineAudio and H.EngineAudio.play_3d_cue then
        H.EngineAudio.play_3d_cue(player_id, cue)
    end

    return cue
end

-- Compute RTPC bundle for engine audio middleware (FMOD/Wwise/etc.).
-- @param player_id number
-- @param region_id number
-- @param tile_id number
-- @return table rtpc_bundle { name: value, ... }
function Audio.compute_dread_rtpcs(player_id, region_id, tile_id)
    local inv = H.sample_all(region_id, tile_id, player_id)

    return {
        cic_weight       = inv.CIC,
        aos_haze         = inv.AOS,
        mythic_density   = inv.MDI,
        haunt_mag        = inv.HVF.mag,
        dread_level      = inv.DET,
        uncertainty      = H.UEC(player_id),
        mystery_density  = inv.EMD,
        resolution_bias  = inv.ARR,
        liminal_stress   = inv.LSG,
        ritual_residue   = inv.RRM
    }
end

return Audio
