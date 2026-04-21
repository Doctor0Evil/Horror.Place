-- h_surprise_adapter.lua
-- Target repo: Horror.Place core runtime
-- Suggested path: hpc-core/src/h_surprise_adapter.lua

local H        = H or {}
local Invars   = require("h_invariants")
local Dungeon  = require("h_dungeon")
local SurpriseAdapter = {}

-- Internal: derive a generic activation profile from the mechanic contract
-- and current tile snapshot, without touching engine types.
local function build_activation_profile(mech, context, snapshot, score)
  -- mech: surpriseMechanicContract row
  -- context: { regionId, dungeonId, nodeId, playerId }
  -- snapshot: result of H.Dungeon.sample_tile
  -- score: selector score from H.Surprise

  local tileClass = snapshot.tileClass or "unknown"

  -- Basic skeleton; fields are intentionally engine‑agnostic.
  local profile = {
    mechanicId          = mech.id,
    implementationId    = mech.implementationId or nil, -- engine will resolve this
    category            = mech.category,
    regionId            = context.regionId,
    dungeonId           = context.dungeonId,
    nodeId              = context.nodeId,
    playerId            = context.playerId,
    tileClass           = tileClass,
    score               = score,
    invariantSnapshot   = snapshot.invariants or {},
    metricSnapshot      = snapshot.metrics or {},
    activationProfile   = {
      -- Example hints based on category and tileClass; adapters interpret these.
      requiresLiminal   = (tileClass == "liminal"),
      visibilityMode    = (mech.category == "PerceptualMisdirection") and "peripheral" or "direct",
      preferredIntensityBand = mech.intensityBand or "moderate",
    },
  }

  return profile
end

-- Public: create an activation spec for a scored mechanic.
-- H.Surprise calls this; engines receive the resulting table and wire it to scenes/entities.
function SurpriseAdapter.instantiate(mech, runtimeCtx)
  -- runtimeCtx: { regionId, dungeonId, nodeId, playerId, score }

  local ctx = {
    regionId  = runtimeCtx.regionId,
    dungeonId = runtimeCtx.dungeonId,
    nodeId    = runtimeCtx.nodeId,
    playerId  = runtimeCtx.playerId,
  }

  local snapshot = Dungeon.sample_tile{
    regionId  = ctx.regionId,
    dungeonId = ctx.dungeonId,
    nodeId    = ctx.nodeId,
    playerId  = ctx.playerId,
  }

  local activation = build_activation_profile(mech, ctx, snapshot, runtimeCtx.score or 0.0)

  -- Optionally include invariants/metrics explicitly on the top level
  activation.invariantsSnapshot = snapshot.invariants
  activation.metricsBefore      = snapshot.metrics

  return activation
end

H.SurpriseAdapter = SurpriseAdapter
return H.SurpriseAdapter
