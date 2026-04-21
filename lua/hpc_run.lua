-- lua/hpc_run.lua
-- Purpose: Canonical H.Run interface for session state machine.
--          All run progression logic flows through these narrow APIs.

local H = require("hpcruntime")
local Run = {}
Run.__index = Run

-- Internal state registry (keyed by sessionId)
local sessions = {}

-- Load and validate run + persona contracts, bind consent/budget, return descriptor.
function Run.start(runContractId, personaContractId, sessionId)
  -- Validate inputs
  if not runContractId or not personaContractId or not sessionId then
    return {
      ok = false,
      error = { code = "MISSING_REQUIRED_ARG", message = "runContractId, personaContractId, and sessionId required" }
    }
  end

  -- Load contracts via canonical loader
  local runCard = H.Contract.load("runContract", runContractId)
  local personaCard = H.Contract.load("directorPersonaContract", personaContractId)
  if not runCard or not personaCard then
    return {
      ok = false,
      error = { code = "CONTRACT_LOAD_FAILED", message = "Failed to load run or persona contract" }
    }
  end

  -- Bind consent and budget modules
  local consentState = H.Consent.bindSession(sessionId, runCard.consentProfileRef)
  local budgetState = H.Budget.initSession(sessionId, consentState)

  -- Compute initial stage from runContract curve
  local initialStage = runCard.defaultStageCurve and runCard.defaultStageCurve[1] or "OuterThreshold"

  -- Register session state
  sessions[sessionId] = {
    runContractId = runContractId,
    personaContractId = personaContractId,
    currentStage = initialStage,
    stepIndex = 0,
    metricsHistory = {},
    consentState = consentState,
    budgetState = budgetState
  }

  return {
    ok = true,
    data = {
      runId = runCard.id,
      initialStage = initialStage,
      allowedDifficulties = runCard.difficultyProfile and H.Keys(runCard.difficultyProfile) or {"Standard"}
    }
  }
end

-- Core per-turn function: apply selector/director, advance stage, emit snapshot.
function Run.step(sessionId, userInput, engineContext)
  local state = sessions[sessionId]
  if not state then
    return { ok = false, error = { code = "SESSION_NOT_FOUND" } }
  end

  -- Get current consent/budget snapshots
  local consentSnap = H.Consent.currentState(sessionId)
  local budgetSnap = H.Budget.snapshot(sessionId)

  -- Apply selector pattern (simplified; real impl uses H.Selector.selectPattern)
  local selectorCtx = {
    sessionId = sessionId,
    regionId = state.regionId,
    consentTier = consentSnap.tier,
    budgetSnapshot = budgetSnap,
    stage = state.currentStage
  }
  local selectorResult = H.Selector.selectPattern(sessionId, state.regionId, selectorCtx)
  if not selectorResult.ok then
    return selectorResult
  end

  -- Apply director safety decision
  local safetyDecision = H.Safety.evaluateTurn(sessionId, userInput, { stage = state.currentStage })
  local directorResult = H.Director.applySafetyDecision(sessionId, safetyDecision, budgetSnap)
  if not directorResult.ok then
    return directorResult
  end

  -- Advance stage according to runContract curve
  state.stepIndex = state.stepIndex + 1
  local runCard = H.Contract.load("runContract", state.runContractId)
  local curve = runCard.defaultStageCurve or {"OuterThreshold", "Locus", "Rupture", "Fallout"}
  local nextStageIdx = math.min(state.stepIndex + 1, #curve)
  state.currentStage = curve[nextStageIdx]

  -- Snapshot metrics
  local metricsSnap = H.Metrics.snapshot(sessionId)

  -- Record in history
  table.insert(state.metricsHistory, {
    step = state.stepIndex,
    stage = state.currentStage,
    metrics = metricsSnap,
    selectorPatternId = selectorResult.data.selectorPatternId,
    directorStrategy = directorResult.data.strategy
  })

  return {
    ok = true,
    data = {
      stage = state.currentStage,
      metricsSnapshot = metricsSnap,
      directorStrategy = directorResult.data.strategy,
      imageHelperPayload = H.ImageHelper.describe and H.ImageHelper.describe({
        sessionId = sessionId,
        stage = state.currentStage,
        metrics = metricsSnap
      })
    }
  }
end

-- Return current canonical stage for session.
function Run.currentStage(sessionId)
  local state = sessions[sessionId]
  if not state then return nil end
  return state.currentStage
end

-- Check if run has reached terminal stage per contract rules.
function Run.isComplete(sessionId)
  local state = sessions[sessionId]
  if not state then return false end
  local runCard = H.Contract.load("runContract", state.runContractId)
  local terminalStages = runCard.terminalStages or {"Fallout"}
  for _, term in ipairs(terminalStages) do
    if state.currentStage == term then return true end
  end
  return false
end

-- Optional: get difficulty bands for a run.
function Run.getDifficultyBands(runId, difficultyName)
  local runCard = H.Contract.load("runContract", runId)
  if not runCard or not runCard.difficultyProfile then
    return { ok = false, error = { code = "DIFFICULTY_PROFILE_NOT_FOUND" } }
  end
  local diff = runCard.difficultyProfile[difficultyName]
  if not diff then
    return { ok = false, error = { code = "DIFFICULTY_NOT_FOUND" } }
  end
  return {
    ok = true,
    data = {
      skillBands = diff.skillBands,
      worldInvariants = diff.worldInvariants,
      metricTargets = diff.metricTargets
    }
  }
end

-- Optional: get normalized progress (0-1) and recent stages.
function Run.getProgress(sessionId)
  local state = sessions[sessionId]
  if not state then return { ok = false, error = { code = "SESSION_NOT_FOUND" } } end
  local runCard = H.Contract.load("runContract", state.runContractId)
  local curve = runCard.defaultStageCurve or {"OuterThreshold", "Locus", "Rupture", "Fallout"}
  local progress = math.min(state.stepIndex / (#curve - 1), 1.0)
  local recent = {}
  for i = math.max(1, #state.metricsHistory - 2), #state.metricsHistory do
    table.insert(recent, { stage = state.metricsHistory[i].stage, step = state.metricsHistory[i].step })
  end
  return {
    ok = true,
    data = { progress = progress, recentStages = recent }
  }
end

H.Run = Run
return Run
