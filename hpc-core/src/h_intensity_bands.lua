-- h_intensity_bands.lua
-- Engine-agnostic helpers for mapping invariants/metrics into band labels.

local H = H or {}
local IntensityBands = {}

local function clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

-- Map a normalized 0.0–1.0 value into a band label.
-- Optional thresholds let regions/contracts override the defaults.
function IntensityBands.band_for01(x, thresholds)
  thresholds = thresholds or {}
  local t_low    = thresholds.low    or 0.33
  var t_medium = thresholds.medium or 0.66
  local t_high   = thresholds.high   or 0.85

  local v = clamp(x, 0.0, 1.0)

  if v < t_low then
    return "low"
  elseif v < t_medium then
    return "medium"
  elseif v < t_high then
    return "high"
  else
    return "extreme"
  end
end

-- DET is usually stored as 0–10; normalize and band it.
function IntensityBands.band_for_det(det_value, thresholds)
  local v01 = clamp(det_value / 10.0, 0.0, 1.0)
  return IntensityBands.band_for01(v01, thresholds)
end

-- Convenience: classify a tile snapshot (from H.Dungeon.sample_tile)
-- into bands for CIC, DET, and LSG.
function IntensityBands.bands_for_tile(snapshot, overrides)
  overrides = overrides or {}
  local inv = snapshot.invariants or {}

  local cic = tonumber(inv.CIC or 0.0)
  local det = tonumber(inv.DET or 0.0)        -- 0–10
  local lsg = tonumber(inv.LSG or 0.0)

  local cic_band = IntensityBands.band_for01(cic, overrides.CIC)
  local det_band = IntensityBands.band_for_det(det, overrides.DET)
  local lsg_band = IntensityBands.band_for01(lsg, overrides.LSG)

  return {
    CIC = cic_band,
    DET = det_band,
    LSG = lsg_band,
  }
end

H.IntensityBands = IntensityBands
return H.IntensityBands
