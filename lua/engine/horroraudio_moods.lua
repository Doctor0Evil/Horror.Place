-- horroraudio_moods.lua
-- Mood-aware audio helper for Horror.Place.
-- Loads moodcontractv1 instances, snaps RTPC targets into declared bands,
-- and delegates to H.Audio RTPC setters for key moods.

local HorroraudioMoods = {}

-- Internal cache of parsed mood contracts, keyed by moodId.
local _mood_cache = {}

-- Lightweight JSON adapter; in-engine you should bind this to your canonical JSON lib.
local Json = Json or require("json")

-- Filesystem adapter; replace with engine-specific virtual FS if needed.
local function read_file(path)
    local f, err = io.open(path, "r")
    if not f then
        return nil, err
    end
    local content = f:read("*a")
    f:close()
    return content, nil
end

local function clamp(v, min_v, max_v)
    if v < min_v then return min_v end
    if v > max_v then return max_v end
    return v
end

-- Expect a global H table with H.Audio.* RTPC setters.
local H = H or {}

----------------------------------------------------------------------
-- Contract loading
----------------------------------------------------------------------

local function load_mood_contract_from_path(path)
    local content, err = read_file(path)
    if not content then
        return nil, ("failed to read mood contract '%s': %s"):format(path, tostring(err))
    end

    local ok, decoded = pcall(Json.decode, content)
    if not ok then
        return nil, ("failed to decode mood contract '%s': %s"):format(path, tostring(decoded))
    end

    if type(decoded) ~= "table" or type(decoded.moodId) ~= "string" then
        return nil, ("invalid moodcontractv1 body at '%s' (missing moodId)"):format(path)
    end

    return decoded, nil
end

-- Public: preload known moods. Call this once during engine startup.
function HorroraudioMoods.preload_defaults(base_path)
    -- base_path should point at the root where schemas/mood/ lives.
    local root = base_path or "schemas/mood/"

    local files = {
        subdued_dread    = root .. "moodcontract.subdued_dread.v1.json",
        constant_pressure = root .. "moodcontract.constant_pressure.v1.json",
        combat_nightmare = root .. "moodcontract.combat_nightmare.v1.json"
    }

    for label, path in pairs(files) do
        local contract, err = load_mood_contract_from_path(path)
        if contract then
            _mood_cache[contract.moodId] = contract
        else
            -- In production, prefer your logging facility over print.
            print(("[HorroraudioMoods] %s not loaded: %s"):format(label, err or "unknown error"))
        end
    end
end

-- Public: fetch a mood contract by id, if loaded.
function HorroraudioMoods.get_mood(mood_id)
    return _mood_cache[mood_id]
end

----------------------------------------------------------------------
-- RTPC snapping helpers
----------------------------------------------------------------------

local function apply_rtpc_band(rtpc_name, band, requested_value)
    if not band then
        return
    end

    local v = requested_value or ((band.min + band.max) * 0.5)
    v = clamp(v, band.min or 0.0, band.max or 1.0)

    if H.Audio and type(H.Audio.set_rtpc) == "function" then
        H.Audio.set_rtpc(rtpc_name, v)
    elseif H.Audio and H.Audio[rtpc_name] and type(H.Audio[rtpc_name]) == "function" then
        -- Fallback: support H.Audio.pressure(value)-style APIs.
        H.Audio[rtpc_name](v)
    else
        -- No RTPC setter bound; log and continue.
        print(("[HorroraudioMoods] No RTPC setter for '%s'"):format(rtpc_name))
    end
end

local function apply_mood_rtpcs(mood_contract, overrides)
    local bands = mood_contract.rtpcBands or {}
    local o = overrides or {}

    -- Map canonical RTPC names used in contracts to H.Audio surfaces.
    if bands.pressure then
        apply_rtpc_band("pressure", bands.pressure, o.pressure)
    end

    if bands.whisperDensity then
        apply_rtpc_band("whisperDensity", bands.whisperDensity, o.whisperDensity)
    end

    if bands.hissLevel then
        apply_rtpc_band("hissLevel", bands.hissLevel, o.hissLevel)
    end

    if bands.staticBed then
        apply_rtpc_band("staticBed", bands.staticBed, o.staticBed)
    end

    if bands.archivalVoices then
        apply_rtpc_band("archivalVoices", bands.archivalVoices, o.archivalVoices)
    end

    if bands.ritualMotif then
        apply_rtpc_band("ritualMotif", bands.ritualMotif, o.ritualMotif)
    end
end

----------------------------------------------------------------------
-- Public mood application API
----------------------------------------------------------------------

-- Generic entry point: apply any moodcontractv1 by moodId.
-- overrides is an optional table of requested RTPC targets, e.g. { pressure = 0.6 }.
function HorroraudioMoods.apply_mood(mood_id, overrides)
    local mood = _mood_cache[mood_id]
    if not mood then
        print(("[HorroraudioMoods] mood '%s' not loaded"):format(tostring(mood_id)))
        return
    end

    apply_mood_rtpcs(mood, overrides)
end

-- Convenience wrappers for the three canonical moods.

function HorroraudioMoods.apply_subdued_dread(overrides)
    HorroraudioMoods.apply_mood("mood.subdued_dread.v1", overrides)
end

function HorroraudioMoods.apply_constant_pressure(overrides)
    HorroraudioMoods.apply_mood("mood.constant_pressure.v1", overrides)
end

function HorroraudioMoods.apply_combat_nightmare(overrides)
    HorroraudioMoods.apply_mood("mood.combat_nightmare.v1", overrides)
end

----------------------------------------------------------------------
-- Optional: tick-based smoothing hooks
----------------------------------------------------------------------

-- If you want to enforce per-second velocity caps from the mood contract safety block
-- inside Lua (instead of or in addition to Rust), you can extend this module with a
-- small stateful smoother keyed by RTPC name. For now we expose a stub hook that
-- horroraudio.lua can call every frame if needed.

local _rtpc_state = {}

local function _smooth_step(name, target, max_delta, dt)
    local s = _rtpc_state[name]
    if not s then
        _rtpc_state[name] = { value = target }
        return target
    end

    local current = s.value or target
    local delta = target - current
    local max_step = (max_delta or 1.0) * dt

    if delta > max_step then
        delta = max_step
    elseif delta < -max_step then
        delta = -max_step
    end

    local next_value = current + delta
    s.value = next_value
    return next_value
end

-- Example smoother entry point (not wired by default):
-- HorroraudioMoods.smooth_and_apply("pressure", targetValue, maxDeltaPerSecond, dtSeconds)
function HorroraudioMoods.smooth_and_apply(rtpc_name, target_value, max_delta_per_second, dt_seconds)
    local v = _smooth_step(rtpc_name, target_value, max_delta_per_second, dt_seconds)
    apply_rtpc_band(rtpc_name, { min = 0.0, max = 1.0 }, v)
end

return HorroraudioMoods
