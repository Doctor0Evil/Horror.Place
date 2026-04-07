-- lua/runtime/h_safety.lua
local json = require("cjson.safe")

local H = H or {}
H.Safety = {}

local SAF_CONFIG = nil
local SAF_INDEX = {
  by_id = {},
  by_phase = {
    absolute_precheck = {},
    session_context_check = {},
    consent_gate = {},
    budget_gate = {},
    output_gate = {}
  }
}

local function load_saf_config(path)
  local f = assert(io.open(path, "r"))
  local raw = f:read("*a")
  f:close()
  local cfg, err = json.decode(raw)
  assert(cfg, "SAF config JSON decode failed: " .. tostring(err))

  SAF_CONFIG = cfg

  -- Index invariants by id and phase
  for _, inv in ipairs(cfg.invariantCatalog or {}) do
    SAF_INDEX.by_id[inv.id] = inv
    local phase = inv.binding and inv.binding.phase
    if phase and SAF_INDEX.by_phase[phase] then
      table.insert(SAF_INDEX.by_phase[phase], inv)
    end
  end
end

function H.Safety.init(opts)
  load_saf_config(opts and opts.path or "schemas/safety/chat-safety-invariants-v1.json")
end
