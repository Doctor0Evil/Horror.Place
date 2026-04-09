-- scripts/validate_player_envelope_fps.lua
-- CI check: verify envelope parameters respect analytic safety bounds
-- and DET-linked excursion limits over a session horizon.

local json = require("dkjson")

local function read_all(path)
  local f, err = io.open(path, "r")
  if not f then
    return nil, "open_failed:" .. tostring(err)
  end
  local txt = f:read("*a")
  f:close()
  return txt
end

local function load_cfg(path)
  local txt, err = read_all(path)
  if not txt then
    return nil, err
  end
  local obj, pos, jerr = json.decode(txt, 1, nil)
  if not obj then
    return nil, "json_error:" .. tostring(pos) .. ":" .. tostring(jerr)
  end
  return obj
end

local function fail(msg)
  io.stderr:write("[H.PlayerEnvelope.FPS] ", msg, "\n")
end

local function check_stamina(cfg, horizon_sec)
  local s_bounds = cfg.stateBounds.stamina
  local nb = cfg.noiseBounds
  local stam_cfg = cfg.stamina

  local s0 = s_bounds.max
  local s_min = s_bounds.min

  local S_env_max = 3.0
  local max_drate = stam_cfg.lambdaDrain * (1.0 + stam_cfg.betaEnv * S_env_max) + nb.stamina

  local delta = horizon_sec * max_drate
  if s0 - delta < s_min then
    fail("stamina worst-case excursion violates floor: s0 - T*dmax < s_min")
    return false
  end
  return true
end

local function check_sanity(cfg, horizon_sec)
  local san_bounds = cfg.stateBounds.sanity
  local nb = cfg.noiseBounds
  local san_cfg = cfg.sanity

  local s0 = san_bounds.max
  local s_min = san_bounds.min

  local S_horror_max =
      san_cfg.wCIC  +
      san_cfg.wDET  +
      san_cfg.wLSG  +
      san_cfg.wHVF  +
      san_cfg.wUEC  +
      san_cfg.wEMD  +
      san_cfg.wCDL  +
      san_cfg.wARR

  local det_cap = 1.0 + san_cfg.gammaArousal + san_cfg.gammaOverload
  local max_drate = san_cfg.lambdaDecay * S_horror_max * det_cap + nb.sanity

  local delta = horizon_sec * max_drate
  if s0 - delta < s_min then
    fail("sanity worst-case excursion violates floor: s0 - T*dmax < s_min")
    return false
  end
  return true
end

local function check_battery(cfg, horizon_sec)
  local b_bounds = cfg.stateBounds.battery
  local nb = cfg.noiseBounds
  local b_cfg = cfg.battery

  local b0 = b_bounds.max
  local b_min = b_bounds.min

  local L_max = 1.0 * (1.0 + b_cfg.phiCIC)
  local max_drate = b_cfg.lambdaDrain * L_max + nb.battery

  local delta = horizon_sec * max_drate
  if b0 - delta < b_min then
    fail("battery worst-case excursion violates floor: b0 - T*dmax < b_min")
    return false
  end
  return true
end

local function main()
  local cfg_path = arg[1] or "schemas/player-envelope-fps-standard.json"
  local horizon_sec = tonumber(arg[2] or "3600")

  local cfg, err = load_cfg(cfg_path)
  if not cfg then
    fail("load failed: " .. tostring(err))
    os.exit(1)
  end

  local ok = true
  if not check_stamina(cfg, horizon_sec) then ok = false end
  if not check_sanity(cfg, horizon_sec) then ok = false end
  if not check_battery(cfg, horizon_sec) then ok = false end

  if not ok then
    os.exit(1)
  end

  io.stdout:write("H.PlayerEnvelope.FPS safety validation OK\n")
  os.exit(0)
end

main()
