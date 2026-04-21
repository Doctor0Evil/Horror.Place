-- h_surprise.lua
-- Target repo: Horror.Place core runtime
-- Suggested path: hpc-core/src/h_surprise.lua

local H        = H or {}
local Dungeon  = require("h_dungeon")          -- your existing helper
local Selector = require("h_selector")         -- same scoring spine as H.Node.choose_next
local Memory   = require("h_dungeon_memory")   -- thin DungeonMemory facade
local Metrics  = require("h_metrics")          -- UEC, EMD, STCI, CDL, ARR snapshots
local Invars   = require("h_invariants")       -- CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI
local Surprise = {}

-- Internal: score a surprise candidate using invariant + metric alignment,
-- reusing the same pattern as your historySelectorPattern scoring.
local function score_candidate(ctx, candidate, snapshot)
  -- ctx: { runId, regionId, dungeonId, nodeId, playerId }
  -- candidate: surpriseMechanicContract row + runtime decorations
  -- snapshot: { invariants = {...}, metrics = {...}, invariantAlignment = number }

  -- Basic ingredient bundles
  local inv   = snapshot.invariants or {}
  local metr  = snapshot.metrics or {}
  local bands = candidate.invariantPreconditions or {}
  local mint  = candidate.metricIntent or {}

  -- 1) Invariant match score (same idea as H.Dungeon.score_invariants)
  local inv_score = 0.0
  local inv_count = 0
  local function band_score(value, band)
    if not band then return 0.0 end
    local mid  = 0.5 * (band.min + band.max)
    local span = band.max - band.min
    if span <= 0.0 then span = 1.0 end
    local dist = math.abs((value or mid) - mid)
    local norm = 1.0 - math.min(dist / span, 1.0)
    return norm
  end

  local fields = { "CIC","MDI","AOS","RRM","FCF","SPR","RWF","DET","LSG","SHCI" }
  for _, name in ipairs(fields) do
    local band = bands[name]
    local val  = inv[name]
    if band and val ~= nil then
      inv_score = inv_score + band_score(val, band)
      inv_count = inv_count + 1
    end
  end
  if inv_count > 0 then
    inv_score = inv_score / inv_count
  end

  -- 2) Entertainment metric intent score (does this mechanic push toward run targets?)
  local metric_score = 0.0
  local metric_count = 0
  local mr = metr or {}
  for name, band in pairs(mint) do
    local val = mr[name]
    if type(band) == "table" and #band == 2 and val ~= nil then
      local mid  = 0.5 * (band[1] + band[2])
      local span = band[2] - band[1]
      if span <= 0.0 then span = 1.0 end
      local dist = math.abs(val - mid)
      local norm = 1.0 - math.min(dist / span, 1.0)
      metric_score = metric_score + norm
      metric_count = metric_count + 1
    end
  end
  if metric_count > 0 then
    metric_score = metric_score / metric_count
  end

  -- 3) Tile alignment score already computed by H.Dungeon.sample_tile
  local tile_score = snapshot.invariantAlignment or 0.0

  -- 4) Optional per‑mechanic weight or priority
  local weight = candidate.selectorWeight or 1.0

  -- Selector‑pattern style weighted sum
  local base = 0.5 * inv_score + 0.3 * metric_score + 0.2 * tile_score
  return base * weight
end

-- Internal: filter mechanics by invariant + metric preconditions.
local function filter_by_contract(ctx, snapshot, mechanics)
  local eligible = {}

  for _, mech in ipairs(mechanics) do
    -- At‑most‑once per run, enforced via DungeonMemory.
    if Memory.has_fired(ctx.runId, mech.id) then
      -- skip
    else
      local ok = true

      -- Invariant gates (simple band checks)
      local inv   = snapshot.invariants or {}
      local bands = mech.invariantPreconditions or {}
      for name, band in pairs(bands) do
        local v = inv[name]
        if v ~= nil and (v < band.min or v > band.max) then
          ok = false
          break
        end
      end

      -- Metric intent + safety caps (e.g., DET, ARR behavior envelopes)
      if ok and mech.detCaps then
        local det = (snapshot.invariants or {}).DET or 0.0
        if det > mech.detCaps.max then
          ok = false
        end
      end

      if ok then
        table.insert(eligible, mech)
      end
    end
  end

  return eligible
end

-- Core query: return a scored list of surprise mechanics that could fire on this tile.
-- ctx must carry: { runId, regionId, dungeonId, nodeId, playerId }.
function Surprise.query_candidates(ctx)
  -- Step 1: ask Dungeon for tile snapshot (invariants + metrics, already aligned to dungeonRunContract)
  local tile_snapshot = Dungeon.sample_tile{
    regionId  = ctx.regionId,
    dungeonId = ctx.dungeonId,
    nodeId    = ctx.nodeId,
    playerId  = ctx.playerId,
  }

  -- Step 2: pull mechanics for this region/dungeon from registries (NDJSON → runtime tables).
  -- This loader should already have filtered by region/tier/intensityBand.
  local mechanics = H.Registry.surprise_mechanics_for_region(ctx.regionId, ctx.dungeonId)

  -- Step 3: filter out consumed or out‑of‑band mechanics using contract preconditions.
  local eligible = filter_by_contract(ctx, tile_snapshot, mechanics)
  if #eligible == 0 then
    return {}
  end

  -- Step 4: score using selector‑pattern style scoring.
  local scored = {}
  for _, mech in ipairs(eligible) do
    local score = score_candidate(ctx, mech, tile_snapshot)
    if score > 0.0 then
      table.insert(scored, { mechanic = mech, score = score })
    end
  end

  -- Step 5: sort descending by score.
  table.sort(scored, function(a, b) return a.score > b.score end)
  return scored
end

-- Try to fire one surprise mechanic on this tile.
-- Returns either nil (no fire) or an activation spec the engine adapter must realize.
function Surprise.try_fire_one(ctx, opts)
  opts = opts or {}
  local min_score   = opts.minScore   or 0.4
  local max_per_turn = opts.maxPerTurn or 1

  local scored = Surprise.query_candidates(ctx)
  if #scored == 0 then
    return nil
  end

  local fired = 0
  local chosen = nil

  for _, entry in ipairs(scored) do
    if entry.score < min_score then
      break
    end
    local mech = entry.mechanic

    -- Double‑check at‑most‑once just before commit (race‑safe if Memory is atomic).
    if not Memory.has_fired(ctx.runId, mech.id) then
      -- Build an abstract activation spec; engine adapters translate this into scenes/blueprints.
      local activation = H.SurpriseAdapter.instantiate(mech, {
        regionId  = ctx.regionId,
        dungeonId = ctx.dungeonId,
        nodeId    = ctx.nodeId,
        playerId  = ctx.playerId,
        score     = entry.score,
      })

      -- Commit to DungeonMemory first, so replay is deterministic.
      Memory.record_fire(ctx.runId, {
        mechanicId  = mech.id,
        regionId    = ctx.regionId,
        dungeonId   = ctx.dungeonId,
        nodeId      = ctx.nodeId,
        playerId    = ctx.playerId,
        score       = entry.score,
        invariants  = activation.invariantsSnapshot or {},
        metricsBefore = activation.metricsBefore or Metrics.snapshot_for_player(ctx.playerId),
        timestamp   = os.time(),
      })

      -- Telemetry hook for UEC/EMD/STCI/CDL/ARR deltas.
      H.Telemetry.log_surprise_activation(ctx.runId, mech.id, activation)

      fired   = fired + 1
      chosen  = activation

      if fired >= max_per_turn then
        break
      end
    end
  end

  return chosen
end

H.Surprise = Surprise
return H.Surprise
