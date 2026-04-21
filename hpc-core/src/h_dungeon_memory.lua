-- h_dungeon_memory.lua
-- Target repo: Horror.Place core runtime
-- Suggested path: hpc-core/src/h_dungeon_memory.lua

local H        = H or {}
local DungeonMemory = {}

-- In‑memory structure (process-local; engine can persist/replicate externally):
-- runs[runId] = {
--   fired = {
--     [mechanicId] = true,
--   },
--   events = {
--     -- chronological log
--     {
--       mechanicId   = "...",
--       regionId     = "...",
--       dungeonId    = "...",
--       nodeId       = "...",
--       playerId     = "...",
--       score        = number,
--       invariants   = { ... },
--       metricsBefore = { ... },
--       metricsAfter  = { ... }, -- optional, engine can backfill
--       timestamp    = number,
--     },
--   },
-- }
local runs = {}

local function ensure_run(runId)
  local r = runs[runId]
  if not r then
    r = {
      fired  = {},
      events = {},
    }
    runs[runId] = r
  end
  return r
end

-- Called by engine when a new dungeon run starts.
function DungeonMemory.begin_run(runId, context)
  -- context may include regionId, dungeonId, seedIds, etc., if needed.
  if runs[runId] then
    -- Optionally clear or error; here we reset for determinism.
    runs[runId] = {
      fired  = {},
      events = {},
    }
  else
    runs[runId] = {
      fired  = {},
      events = {},
    }
  end
end

-- Called when a run is completed or abandoned.
function DungeonMemory.end_run(runId)
  runs[runId] = nil
end

-- At‑most‑once query: has this mechanic already fired in this run?
function DungeonMemory.has_fired(runId, mechanicId)
  local r = runs[runId]
  if not r then
    return false
  end
  return r.fired[mechanicId] == true
end

-- Record that a mechanic has fired and log a history event.
-- payload is a small, schema‑aligned table, typically built by H.Surprise.
function DungeonMemory.record_fire(runId, payload)
  local r = ensure_run(runId)

  -- Defensive: require mechanicId.
  if not payload or not payload.mechanicId then
    return false, "MISSING_MECHANIC_ID"
  end

  -- Mark at‑most‑once.
  r.fired[payload.mechanicId] = true

  -- Append to events log in canonical shape.
  local event = {
    mechanicId    = payload.mechanicId,
    regionId      = payload.regionId,
    dungeonId     = payload.dungeonId,
    nodeId        = payload.nodeId,
    playerId      = payload.playerId,
    score         = payload.score or 0.0,
    invariants    = payload.invariants or {},
    metricsBefore = payload.metricsBefore or {},
    metricsAfter  = payload.metricsAfter or nil,
    timestamp     = payload.timestamp or os.time(),
  }

  table.insert(r.events, event)

  -- Optional: push into telemetry immediately.
  if H.Telemetry and H.Telemetry.log_dungeon_surprise_event then
    H.Telemetry.log_dungeon_surprise_event(runId, event)
  end

  return true, nil
end

-- Read‑side API: get all surprise events for this run (for AI, debug, or telemetry).
function DungeonMemory.list_events(runId)
  local r = runs[runId]
  if not r then
    return {}
  end
  return r.events
end

-- Optional: check whether any surprise has fired on this node in this run.
function DungeonMemory.has_any_on_node(runId, nodeId)
  local r = runs[runId]
  if not r then
    return false
  end
  for _, ev in ipairs(r.events) do
    if ev.nodeId == nodeId then
      return true
    end
  end
  return false
end

-- Optional: export a replay‑safe summary for Dead‑Ledger / NDJSON.
function DungeonMemory.export_run_summary(runId)
  local r = runs[runId]
  if not r then
    return nil
  end

  local summary = {
    runId   = runId,
    events  = r.events,
    fired   = r.fired,
  }

  return summary
end

H.DungeonMemory = DungeonMemory
return H.DungeonMemory
