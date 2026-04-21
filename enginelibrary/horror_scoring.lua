-- enginelibrary/horror_scoring.lua
local Scoring = {}

-- patternConfig: history-selector-pattern config
-- candidate: table with fields from contracts/invariants, e.g.
--   liminalTags, mechanicHooks, SHCI, CIC, AOS, etc.
function Scoring.scoreCandidate(patternConfig, candidate)
  local score = 0.0

  -- Liminal bias
  local liminalPrefs = patternConfig.liminalTagPreferences or {}
  local liminalTags  = candidate.liminalTags or {}
  -- ... compute liminal contribution using weights and tags ...

  -- Mechanic hook bias
  local hookPrefs = patternConfig.mechanicHookPreferences or {}
  local hooks     = candidate.mechanicHooks or {}
  -- ... compute mechanic contribution ...

  -- History coupling (SHCI)
  local hc   = patternConfig.historyCoupling or {}
  local shci = candidate.SHCI or 0.0
  -- ... apply minSHCI, preferredBand, inside/outside weights ...

  -- Optional entertainment targets / metric alignment
  local et = patternConfig.entertainmentTargets
  if et and candidate.metrics then
    -- e.g. reward being inside UEC/CDL bands
    -- ... compute contribution ...
  end

  return score
end

return Scoring
