-- lua/hpc_run_state_machine.lua
-- Target repo: Horror.Place
--
-- Deterministic run loop that binds runContract + personaContract + imageHelper
-- into a single H.Run.* surface for CHAT_DIRECTOR and engine runtimes.

local H = require("hpc_runtime")  -- thin umbrella that re-exports H.* helpers

local Run = {}
Run.__index = Run

-- Factory: create a run state from a validated runContract payload.
function Run.new(run_contract, persona_contract, session_id)
  local self = {
    session_id       = session_id,
    run_id           = run_contract.id,
    tier             = run_contract.tier,
    region_ref       = run_contract.regionRef,
    seed_ref         = run_contract.seedRef,
    event_bundle_refs = run_contract.eventBundleRefs or {},
    persona_ref      = run_contract.personaContractRef,
    persona_role     = run_contract.personaRole,
    style_envelope   = run_contract.styleEnvelope or {},
    budget_envelope  = run_contract.budgetEnvelope or {},
    safety_envelope  = run_contract.safetyEnvelope or {},
    selector_env     = run_contract.historySelectorEnvelope or {},
    metrics_envelope = run_contract.metricsEnvelope or {},
    image_helper     = run_contract.imageHelper or {},
    persona_contract = persona_contract,
    terminated       = false
  }

  setmetatable(self, Run)

  -- Initialize metrics and budget from invariants + envelopes.
  H.Metrics.init_session(self.session_id, self.metrics_envelope)
  H.Budget.init_session(self.session_id, self.budget_envelope, self.tier)
  H.Banter.init_session(self.session_id, self.safety_envelope.banterPolicyRef, self.tier)
  H.Safety.init_session(self.session_id, self.safety_envelope.chatSafetyRulesetId, self.tier)
  H.Selector.init_session(self.session_id, self.selector_env.selectorPolicyRef)

  return self
end

-- Core step: process a single user turn and return an engine-safe reply.
function Run:step(user_text)
  if self.terminated then
    return {
      kind = "system",
      text = "Run already terminated.",
      meta = { terminated = true }
    }
  end

  -- 1. Classify input via Banter -> labels + intent.
  local labels = H.Banter.classify_turn(user_text, { sessionId = self.session_id })

  -- 2. Update session-level banter state.
  H.Banter.update_session_state(self.session_id, labels)

  -- 3. Query invariants for current region/tile for history selector.
  local invariants = H.Invariants.sample_region(self.region_ref, self.seed_ref)

  -- 4. Choose pattern from history selector based on invariants + intent.
  local selector_result = H.Selector.choose_pattern(
    self.region_ref,
    self.seed_ref,
    {
      sessionId = self.session_id,
      userIntent = labels.intentTags or {},
      tier = self.tier,
      invariantsSnapshot = invariants
    }
  )

  -- Conflict policies in selector may already deny/soften/reroute.
  if selector_result.resolutionStrategy == "deny" then
    return self:_deny_from_selector(selector_result)
  end

  -- 5. Compute current budget and metrics snapshot.
  local metrics_snapshot = H.Metrics.current_bands(self.session_id)
  local budget_state = H.Budget.compute(self.session_id, {
    invariants = invariants,
    metrics    = metrics_snapshot,
    tier       = self.tier
  })

  -- 6. Ask budget module if we should downshift before generating.
  local should_downshift, downshift_hints = H.Budget.should_downshift(self.session_id, budget_state)

  -- 7. Compose a persona + style prompt surface for the LLM.
  local llm_context = self:_build_llm_context(labels, selector_result, metrics_snapshot, should_downshift, downshift_hints)

  -- 8. Call persona-specific generation hook (engine-side).
  local raw_model_output = H.Persona.generate(self.persona_contract, llm_context)

  -- 9. Estimate modality deltas from the raw model output for budget.
  local modality_deltas = H.Budget.estimate_modality_deltas(raw_model_output, labels, selector_result)

  -- 10. Consume budget and get updated over-budget state.
  local new_budget_state, over_budget_state = H.Budget.consume(self.session_id, modality_deltas)

  -- 11. Apply over-budget behavior (imply/soften/refuse) if needed.
  local adjusted_output, budget_behavior = H.Budget.apply_overbudget_behavior(
    raw_model_output,
    over_budget_state,
    {
      tier = self.tier,
      personaRole = self.persona_role
    }
  )

  -- 12. Evaluate chat-safety invariants and rulesets on the adjusted output.
  local safety_vector = H.Safety.compute_invariants(adjusted_output, labels)
  local safety_decision, safety_hints = H.Safety.evaluate(
    adjusted_output,
    {
      sessionId = self.session_id,
      tier = self.tier,
      safetyVector = safety_vector
    }
  )

  local final_text
  local safety_mode

  if safety_decision.mode == "allow" then
    final_text = adjusted_output
    safety_mode = "allow"
  elseif safety_decision.mode == "soften" or safety_decision.mode == "imply" then
    final_text = H.Safety.soften_output(adjusted_output, safety_hints)
    safety_mode = safety_decision.mode
  else -- "refuse"
    final_text = H.Safety.refusal_message(safety_hints)
    safety_mode = "refuse"
  end

  -- 13. Image helper: decide whether to emit an image prompt or suppress.
  local image_payload = nil
  if self.image_helper.enabled then
    image_payload = H.Images.plan(
      final_text,
      {
        sessionId = self.session_id,
        stylePacks = self.image_helper.stylePacks or {},
        maxImagesPerRun = self.image_helper.maxImagesPerRun or 0,
        safetyProfileRef = self.image_helper.safetyProfileRef,
        safetyVector = safety_vector,
        budgetState = new_budget_state
      }
    )
  end

  -- 14. Telemetry: log metrics, budget, selector decision, safety result.
  H.Metrics.record_event(self.session_id, {
    runId = self.run_id,
    regionRef = self.region_ref,
    seedRef = self.seed_ref,
    labels = labels,
    selectorResult = selector_result,
    metrics = metrics_snapshot,
    budgetState = new_budget_state,
    budgetBehavior = budget_behavior,
    safetyVector = safety_vector,
    safetyDecision = safety_decision,
    safetyMode = safety_mode
  })

  H.Selector.log_decision(self.session_id, selector_result)

  -- 15. Termination checks (optional: based on budget or explicit signals).
  if H.Budget.should_terminate(self.session_id, new_budget_state) then
    self.terminated = true
  end

  return {
    kind = "assistant",
    text = final_text,
    images = image_payload,
    meta = {
      runId = self.run_id,
      safetyMode = safety_mode,
      overBudget = over_budget_state ~= nil,
      selectorPatternId = selector_result.patternId,
      personaRole = self.persona_role
    }
  }
end

function Run:_build_llm_context(labels, selector_result, metrics_snapshot, should_downshift, downshift_hints)
  return {
    sessionId = self.session_id,
    runId = self.run_id,
    personaRef = self.persona_ref,
    personaRole = self.persona_role,
    tier = self.tier,
    styleId = self.style_envelope.styleId,
    metricBands = self.style_envelope.metricBands or {},
    safetyIntent = self.style_envelope.safetyIntent or {},
    labels = labels,
    patternId = selector_result.patternId,
    patternExplicitnessBand = selector_result.explicitnessBand or "implied",
    allowedEventTypes = selector_result.allowedEventTypes or {},
    forbiddenEventTypes = selector_result.forbiddenEventTypes or {},
    metricsSnapshot = metrics_snapshot,
    downshift = {
      active = should_downshift,
      hints = downshift_hints
    }
  }
end

function Run:_deny_from_selector(selector_result)
  local msg = H.Selector.denial_message(selector_result, {
    tier = self.tier,
    regionRef = self.region_ref
  })

  H.Selector.log_decision(self.session_id, selector_result)

  return {
    kind = "assistant",
    text = msg,
    meta = {
      runId = self.run_id,
      deniedBy = "history-selector",
      selectorPatternId = selector_result.patternId,
      resolutionStrategy = selector_result.resolutionStrategy
    }
  }
end

-- Public API: H.Run.start and H.Run.step to be imported via hpc_runtime.
local M = {}

function M.start(run_contract, persona_contract, session_id)
  return Run.new(run_contract, persona_contract, session_id)
end

return M
