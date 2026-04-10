-- engine/library/horror_audio.lua
-- Horror.Place audio policy layer (Hellscape Mixer).
-- Maps invariants (CIC, AOS, LSG, HVF, etc.) to abstract audio descriptors
-- and RTPC bundles. Never calls engine-specific audio APIs directly.

local H      = require("engine.library.horror_invariants")
local AudioR = require("engine.library.audio_rtpc")   -- thin C/Rust bridge

local Audio = {}

-- Internal helper: quantize invariant values into coarse bands.
local function _band(value)
    if not value then return "unknown" end
    if value < 0.25 then return "low" end
    if value < 0.50 then return "mid" end
    if value < 0.75 then return "high" end
    return "extreme"
end

----------------------------------------------------------------------
-- Hellscape style contract plumbing
----------------------------------------------------------------------

-- Cache current Hellscape style contract (parsed JSON).
local current_style = nil

--- Load an audio-landscape-style.v1 contract.
-- @param style_def table
function Audio.load_style(style_def)
    current_style = style_def
end

local function resolve_role(inv)
    -- Minimal role resolution; real projects should use tile metadata.
    if inv.LSG and inv.LSG >= 0.75 then
        return "liminaltile"
    elseif inv.CIC and inv.CIC >= 0.70 then
        return "battlefronttile"
    else
        return "spawntile"
    end
end

local function derive_metrics(inv)
    -- Placeholder; in production, metrics come from Spectral/telemetry.
    return {
        UEC  = inv.UEC or 0.7,
        ARR  = inv.ARR or 0.8,
        EMD  = inv.EMD or 0.6,
        STCI = inv.STCI or 0.6,
        CDL  = inv.CDL or 0.5
    }
end

local function eval_param(param_def, inv, metrics)
    -- Build an input sample and delegate curve math + safety to AudioR.
    local sample = {
        CIC    = inv.CIC,
        LSG    = inv.LSG,
        HVFmag = inv.HVF and inv.HVF.mag or 0.0,
        AOS    = inv.AOS or 0.0,
        DET    = inv.DET or 0.0,
        UEC    = metrics.UEC,
        ARR    = metrics.ARR,
        EMD    = metrics.EMD,
        STCI   = metrics.STCI,
        CDL    = metrics.CDL
    }

    return AudioR.evaluate_param(param_def, sample)
end

----------------------------------------------------------------------
-- Spawn sequence (descriptor-oriented)
----------------------------------------------------------------------

--- Compose a spawn audio sequence based on local invariants and mood context.
-- @param region_id number
-- @param tile_id number
-- @param player_id number
-- @param context table? { mood_id, role }
-- @return table abstract_sequence { pattern_id, layers[], duration, meta }
function Audio.compose_spawn_sequence(region_id, tile_id, player_id, context)
    local inv = H.sample_all(region_id, tile_id, player_id)
    if not inv then return nil end

    local mood = (context and context.mood_id) or "unknown"
    local role = (context and context.role)    or "spawntile"

    local cic_band  = _band(inv.CIC)
    local lsg_band  = _band(inv.LSG)
    local det_band  = _band(inv.DET)
    local shci_band = _band(inv.SHCI)

    local seq = {
        pattern_id = string.format("%s_%s_spawn", mood, role),
        duration   = 1.0 + (inv.DET or 0.0) * 1.5,  -- 1.0–2.5 seconds
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
        weight = inv.CIC or 0.0
    })

    -- Historical echo layer (if SHCI is high enough).
    if inv.SHCI and inv.SHCI > 0.50 then
        table.insert(seq.layers, {
            role = "history_echo",
            tags = {
                "history_echo",
                "shci_" .. shci_band,
                "region_" .. tostring(region_id)
            },
            weight = inv.SHCI
        })
    end

    -- Tinnitus/ear-ringing layer (if DET is elevated).
    if inv.DET and inv.DET > 0.40 then
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
    if inv.LSG and inv.LSG > 0.65 then
        table.insert(seq.layers, {
            role = "liminal_filter",
            tags = {
                "threshold_bend",
                "lsg_" .. lsg_band
            },
            rtpc = {
                filter_cutoff = 1200.0 + (inv.LSG * 800.0),
                reverb_mix    = 0.3 + (inv.LSG * 0.4)
            }
        })
    end

    return seq
end

----------------------------------------------------------------------
-- Region ambience (Hellscape RTPC + descriptor palette)
----------------------------------------------------------------------

--- Update region ambience based on invariants and player state.
-- Returns a descriptor palette and pushes RTPCs via AudioR.
-- @param region_id number
-- @param tile_id number
-- @param player_id number
-- @param options table? { mood_id, pressure_factor }
function Audio.sample_region_ambience(region_id, tile_id, player_id, options)
    local inv = H.sample_all(region_id, tile_id, player_id)
    if not inv then return nil end

    local opts     = options or {}
    local pressure = opts.pressure_factor or 1.0

    local metrics = derive_metrics(inv)
    local role    = resolve_role(inv)

    local cic_band = _band(inv.CIC)
    local aos_band = _band(inv.AOS)
    local mdi_band = _band(inv.MDI)

    local palette = {
        region_id = region_id,
        tile_id   = tile_id,
        role      = role,
        tags      = {
            "ambience",
            "cic_" .. cic_band,
            "aos_" .. aos_band,
            "mdi_" .. mdi_band
        },
        density   = math.min(1.0, (inv.CIC or 0.0) * pressure),
        weirdness = inv.MDI or 0.0,
        opacity   = inv.AOS or 0.0,
        rtpc      = {}  -- filled below
    }

    -- If a Hellscape style is loaded, compute RTPCs through AudioR.
    if current_style and current_style.rtpcMappings
        and current_style.rtpcMappings.parameters
    then
        local rtpc_frame = {}

        for _, p in ipairs(current_style.rtpcMappings.parameters) do
            local value = eval_param(p, inv, metrics)
            if value then
                rtpc_frame[p.name] = value
                palette.rtpc[p.name] = value
            end
        end

        AudioR.apply_rtpc_frame(player_id, rtpc_frame)
    else
        -- Fallback RTPCs derived directly from invariants/metrics.
        palette.rtpc = {
            cic_weight       = inv.CIC or 0.0,
            aos_haze         = inv.AOS or 0.0,
            mythic_density   = inv.MDI or 0.0,
            haunt_mag        = (inv.HVF and inv.HVF.mag) or 0.0,
            dread_level      = inv.DET or 0.0,
            uncertainty      = H.UEC and H.UEC(player_id) or 0.7,
            mystery_density  = inv.EMD or 0.0,
            resolution_bias  = inv.ARR or 0.0,
            liminal_stress   = inv.LSG or 0.0,
            ritual_residue   = inv.RRM or 0.0
        }
    end

    return palette
end

----------------------------------------------------------------------
-- HVF-aware directional cues (descriptor only)
----------------------------------------------------------------------

--- Build an HVF-aware directional audio cue (for anti-camping pressure).
-- @param player_id number
-- @param hvf table { mag, dir = { x, y, z } }
-- @param options table? { fade_rate }
-- @return table cue descriptor
function Audio.apply_hvf_directional_cue(player_id, hvf, options)
    local opts = options or {}
    local mag  = hvf and hvf.mag or 0.0

    local cue = {
        player_id = player_id,
        kind      = "hvf_directional",
        intensity = mag,
        direction = hvf and hvf.dir or { x = 0.0, y = 0.0, z = 1.0 },
        tags      = {
            "haunt_vector",
            "directional_whisper"
        },
        rtpc      = {
            pan_speed = (opts.fade_rate or 0.02) * mag,
            doppler   = mag * 0.3
        }
    }

    return cue
end

----------------------------------------------------------------------
-- Hellscape-style ambience tick helpers
----------------------------------------------------------------------

--- Hellscape-style region ambience tick.
function Audio.update_region_ambience(region_id, tile_id, player_id)
    -- Just delegate to sample_region_ambience; engine chooses how to use palette.
    return Audio.sample_region_ambience(region_id, tile_id, player_id, nil)
end

--- Spawn hook: always sample invariants and update ambience.
function Audio.on_spawn(region_id, tile_id, player_id, context)
    -- Ensure invariants are consulted; palette/seq are returned for engine use.
    local _ = H.sample_all(region_id, tile_id, player_id)
    Audio.update_region_ambience(region_id, tile_id, player_id)
    -- Engine may separately call compose_spawn_sequence if desired.
end

--- Threshold-cross hook: tick ambience based on destination tile.
function Audio.on_threshold_cross(player_id, from_region, from_tile, to_region, to_tile)
    local _ = H.sample_all(to_region, to_tile, player_id)
    Audio.update_region_ambience(to_region, to_tile, player_id)
end

----------------------------------------------------------------------
-- RTPC bundle helper
----------------------------------------------------------------------

--- Compute a simple dread RTPC bundle from invariants.
-- @param player_id number
-- @param region_id number
-- @param tile_id number
-- @return table rtpc_bundle { name = value, ... }
function Audio.compute_dread_rtpcs(player_id, region_id, tile_id)
    local inv = H.sample_all(region_id, tile_id, player_id)
    if not inv then return {} end

    return {
        cic_weight       = inv.CIC or 0.0,
        aos_haze         = inv.AOS or 0.0,
        mythic_density   = inv.MDI or 0.0,
        haunt_mag        = (inv.HVF and inv.HVF.mag) or 0.0,
        dread_level      = inv.DET or 0.0,
        uncertainty      = H.UEC and H.UEC(player_id) or 0.7,
        mystery_density  = inv.EMD or 0.0,
        resolution_bias  = inv.ARR or 0.0,
        liminal_stress   = inv.LSG or 0.0,
        ritual_residue   = inv.RRM or 0.0
    }
end

return Audio
