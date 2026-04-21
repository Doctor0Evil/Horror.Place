-- lua/hpc_node.lua
-- Target repo: Horror.Place
-- Purpose: Provide a small, stable API to inspect dungeon-node contracts
--          so AI-Chat and tools can perform node walkthroughs without
--          touching raw tables.

local H = require("hpcruntime")

local Node = {}

-- Resolve a dungeon-node contract by nodeId.
-- nodeId is assumed to be globally unique or resolvable via a registry.
local function load_node_contract(nodeId)
  -- H.Contract.load is a conceptual helper that should:
  -- - Look up the contract in registries
  -- - Validate schemaRef and objectKind
  -- - Return a decoded Lua table or nil, err
  return H.Contract.load("dungeonNodeContract", nodeId)
end

-- Describe a node in terms that are safe and useful for AI-Chat:
-- - Static: role, topology, liminalTags, invariant bands, metricTargets
-- - Dynamic: sampled invariants and metrics for the current session/context
--
-- sessionId and regionRef help us query live invariants/metrics snapshots.
-- tileRef is optional; pass nil if not applicable.
function Node.describe(nodeId, sessionId, regionRef, tileRef)
  local contract, err = load_node_contract(nodeId)
  if not contract then
    return {
      ok = false,
      error = "node_not_found",
      message = err or ("No dungeonNodeContract for nodeId=" .. tostring(nodeId))
    }
  end

  -- Sample live invariants for this region/tile if available.
  local invariantsSnapshot = nil
  if regionRef then
    invariantsSnapshot = H.Invariants.sample_region(regionRef, tileRef)
  end

  -- Sample current session metrics, if any.
  local metricsSnapshot = nil
  if sessionId then
    metricsSnapshot = H.Metrics.current_bands(sessionId)
  end

  return {
    ok = true,

    nodeId = contract.nodeId,
    name = contract.name,
    role = contract.role,

    regionRef = contract.regionRef,
    tileRef = contract.tileRef,

    topology = contract.topology or {},
    liminalTags = contract.liminalTags or {},

    invariantBands = contract.invariantBands or {},
    metricTargets = contract.metricTargets or {},

    mechanicHooks = contract.mechanicHooks or {},
    telemetryHints = contract.telemetryHints or {},

    -- Live snapshots (may be nil if not available in this context)
    invariantsSnapshot = invariantsSnapshot,
    metricsSnapshot = metricsSnapshot
  }
end

-- Optional helper to describe multiple nodes in one call.
function Node.describe_many(nodeIds, sessionId, regionRef, tileRef)
  local result = {}
  for _, nodeId in ipairs(nodeIds or {}) do
    table.insert(result, Node.describe(nodeId, sessionId, regionRef, tileRef))
  end
  return result
end

return {
  describe = Node.describe,
  describe_many = Node.describe_many
}
