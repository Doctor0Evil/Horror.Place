-- engine/metrics.lua
-- Canonical entertainment metrics surface for Horror.Place.
-- This module exposes a narrow API used by directors, AI, and tools
-- to read current and recent values for UEC, EMD, STCI, CDL, and ARR,
-- plus simple deltas and band checks aligned with the entertainment
-- metrics schema.

local Metrics = {}

-- Internal storage for current metric snapshot and simple history.
local _current = {
  UEC  = 0.0,
  EMD  = 0.0,
  STCI = 0.0,
  CDL  = 0.0,
  ARR  = 0.0,
}

local _previous = {
  UEC  = 0.0,
  EMD  = 0.0,
  STCI = 0.0,
  CDL  = 0.0,
  ARR  = 0.0,
}

-- Optional simple ring buffer for short history windows.
local _history = {
  -- each entry: { t = number, UEC = number, EMD = number, STCI = number, CDL = number, ARR = number }
  buffer = {},
  max_size = 64,
}

local function _clamp01(v)
  if v < 0.0 then
    return 0.0
  elseif v > 1.0 then
    return 1.0
  end
  return v
end

local function _push_history(sample)
  local buf = _history.buffer
  buf[#buf + 1] = sample
  if #buf > _history.max_size then
    table.remove(buf, 1)
  end
end

--- Update the current metrics snapshot.
-- Call this from telemetry or director code after computing new values.
-- All fields are clamped into [0.0, 1.0] to match the schema.
-- @param t       number  engine time or monotonic timestamp
-- @param values  table   { UEC = number?, EMD = number?, STCI = number?, CDL = number?, ARR = number? }
function Metrics.update(t, values)
  if not values then
    return
  end

  -- move current into previous before applying updates
  _previous.UEC  = _current.UEC
  _previous.EMD  = _current.EMD
  _previous.STCI = _current.STCI
  _previous.CDL  = _current.CDL
  _previous.ARR  = _current.ARR

  if values.UEC ~= nil then
    _current.UEC = _clamp01(values.UEC)
  end
  if values.EMD ~= nil then
    _current.EMD = _clamp01(values.EMD)
  end
  if values.STCI ~= nil then
    _current.STCI = _clamp01(values.STCI)
  end
  if values.CDL ~= nil then
    _current.CDL = _clamp01(values.CDL)
  end
  if values.ARR ~= nil then
    _current.ARR = _clamp01(values.ARR)
  end

  _push_history({
    t    = t or 0.0,
    UEC  = _current.UEC,
    EMD  = _current.EMD,
    STCI = _current.STCI,
    CDL  = _current.CDL,
    ARR  = _current.ARR,
  })
end

-- Simple getters for current values.

function Metrics.UEC()
  return _current.UEC
end

function Metrics.EMD()
  return _current.EMD
end

function Metrics.STCI()
  return _current.STCI
end

function Metrics.CDL()
  return _current.CDL
end

function Metrics.ARR()
  return _current.ARR
end

-- Deltas vs previous snapshot. These are useful for pacing logic and
-- Surprise.Events! scheduling that care about rising or falling curves.

function Metrics.delta_UEC()
  return _current.UEC - _previous.UEC
end

function Metrics.delta_EMD()
  return _current.EMD - _previous.EMD
end

function Metrics.delta_STCI()
  return _current.STCI - _previous.STCI
end

function Metrics.delta_CDL()
  return _current.CDL - _previous.CDL
end

function Metrics.delta_ARR()
  return _current.ARR - _previous.ARR
end

--- Return a shallow copy of the current snapshot.
-- This is convenient for logging, telemetry, or contract checks.
function Metrics.snapshot()
  return {
    UEC  = _current.UEC,
    EMD  = _current.EMD,
    STCI = _current.STCI,
    CDL  = _current.CDL,
    ARR  = _current.ARR,
  }
end

--- Iterate over recent history samples (newest last).
-- @return table history buffer (do not mutate from callers if possible)
function Metrics.history()
  return _history.buffer
end

--- Check whether the current metrics fall inside a target band.
-- The band object is expected to match the entertainment metrics schema:
-- {
--   UEC  = { min = number?, max = number? },
--   EMD  = { min = number?, max = number? },
--   STCI = { min = number?, max = number? },
--   CDL  = { min = number?, max = number? },
--   ARR  = { min = number?, max = number? },
-- }
-- Missing fields are treated as unconstrained.
-- @return boolean ok
function Metrics.in_target_band(band)
  if not band then
    return true
  end

  local function check_one(value, spec)
    if not spec then
      return true
    end
    if spec.min ~= nil and value < spec.min then
      return false
    end
    if spec.max ~= nil and value > spec.max then
      return false
    end
    return true
  end

  if not check_one(_current.UEC,  band.UEC)  then return false end
  if not check_one(_current.EMD,  band.EMD)  then return false end
  if not check_one(_current.STCI, band.STCI) then return false end
  if not check_one(_current.CDL,  band.CDL)  then return false end
  if not check_one(_current.ARR,  band.ARR)  then return false end

  return true
end

--- Convenience helper: compute a simple scalar "intensity" score
-- from current metrics, which directors can use as a heuristic.
-- Weightings are intentionally simple; engines may override or extend.
function Metrics.intensity_score(weights)
  local w = weights or {}
  local wUEC  = w.UEC  or 0.25
  local wEMD  = w.EMD  or 0.20
  local wSTCI = w.STCI or 0.25
  local wCDL  = w.CDL  or 0.15
  local wARR  = w.ARR  or 0.15

  local score =
    _current.UEC  * wUEC  +
    _current.EMD  * wEMD  +
    _current.STCI * wSTCI +
    _current.CDL  * wCDL  +
    _current.ARR  * wARR

  return _clamp01(score)
end

return Metrics
