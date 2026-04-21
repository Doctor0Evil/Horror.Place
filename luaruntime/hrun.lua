-- luaruntime/hrun.lua
local Contracts = require "horrorcontracts"

local Run = {}

function Run.getDifficultyBands(runId, difficultyName)
  local runCard = Contracts.run(runId)
  if not runCard then
    return { ok = false, error = { code = "RUN_NOT_FOUND" } }
  end
  local diff = runCard.difficultyProfile and runCard.difficultyProfile[difficultyName]
  if not diff then
    return { ok = false, error = { code = "DIFFICULTY_NOT_FOUND" } }
  end
  return {
    ok = true,
    data = {
      skillBands      = diff.skillBands,
      worldInvariants = diff.worldInvariants,
      metricTargets   = diff.metricTargets
    }
  }
end

H.Run = Run
