-- enginelibrary/h_player_envelope_fps.lua
local json = require("dkjson")
local H = require("horror_invariants")      -- canonical invariants API
local Metrics = require("horror_metrics")   -- UEC/EMD/STCI/CDL/ARR getters
local BCI = require("hpc_bci_adapter")      -- BCI metrics wrapper

local PlayerEnvelopeFPS = {}
PlayerEnvelopeFPS.__index = PlayerEnvelopeFPS

local function clamp(x, minv, maxv)
  if x < minv then return minv end
  if x > maxv then return maxv end
  return x
end

function PlayerEnvelopeFPS.new(cfg)
  local self = setmetatable({}, PlayerEnvelopeFPS)
  self.cfg = cfg
  self.dt = cfg.tickSeconds
  self.bounds = cfg.stateBounds
  self.noise = cfg.noiseBounds
  self.state = {
    v = 0.0,
    stamina = clamp(cfg.stateBounds.stamina.max, cfg.stateBounds.stamina.min, cfg.stateBounds.stamina.max),
    sanity  = clamp(cfg.stateBounds.sanity.max,  cfg.stateBounds.sanity.min,  cfg.stateBounds.sanity.max),
    R = 0.0,
    O = 0.0,
    battery = clamp(cfg.stateBounds.battery.max, cfg.stateBounds.battery.min, cfg.stateBounds.battery.max)
  }
  return self
end

local function sample_invariants(player_id)
  local region_id, tile_id = H.region_tile(player_id)
  local inv = H.sample_all(region_id, tile_id, player_id)
  return inv, region_id, tile_id
end

local function sample_metrics(player_id)
  return {
    UEC  = Metrics.UEC(player_id),
    EMD  = Metrics.EMD(player_id),
    STCI = Metrics.STCI(player_id),
    CDL  = Metrics.CDL(player_id),
    ARR  = Metrics.ARR(player_id)
  }
end

local function sample_bci(player_id)
  local frame = BCI.current_frame(player_id)
  if not frame then
    return { arousal = 0.0, overload = 0.0 }
  end
  return {
    arousal  = clamp(frame.arousal_index or 0.0, 0.0, 1.0),
    overload = clamp(frame.overload_index or 0.0, 0.0, 1.0)
  }
end

local function bounded_noise(mag)
  if mag <= 0.0 then return 0.0 end
  local r = (math.random() * 2.0) - 1.0
  return r * mag
end

local function vel_step(env, input, inv)
  local cfg = env.cfg.velocity
  local s_cfg = env.cfg.stamina
  local dt = env.dt
  local v = env.state.v

  local target = cfg.vMax * (math.abs(input.move) + cfg.alphaSprint * input.sprint)
  if target < 0.0 then target = 0.0 end
  if target > cfg.vMax then target = cfg.vMax end

  local dv = cfg.kappa * (target - v)
  dv = dv + bounded_noise(env.noise.v)

  v = v + dt * dv
  v = clamp(v, env.bounds.v.min, env.bounds.v.max)

  env.state.v = v
end

local function stamina_step(env, input, inv)
  local cfg = env.cfg.stamina
  local dt = env.dt
  local s = env.state.stamina

  local L_move = math.abs(input.move) * input.sprint
  local S_env = inv.CIC + inv.LSG + inv.HVF.mag
  if S_env > 3.0 then S_env = 3.0 end

  local ds
  if L_move > 0.0 then
    ds = -cfg.lambdaDrain * L_move * (1.0 + cfg.betaEnv * S_env)
  else
    ds = cfg.lambdaRest * (1.0 - s)
  end

  ds = ds + bounded_noise(env.noise.stamina)
  s = s + dt * ds
  s = clamp(s, env.bounds.stamina.min, env.bounds.stamina.max)

  env.state.stamina = s
end

local function sanity_step(env, input, inv, met, bci)
  local cfg = env.cfg.sanity
  local dt = env.dt
  local sa = env.state.sanity

  local S_horror =
      cfg.wCIC  * inv.CIC +
      cfg.wDET  * inv.DET +
      cfg.wLSG  * inv.LSG +
      cfg.wHVF  * inv.HVF.mag +
      cfg.wUEC  * met.UEC +
      cfg.wEMD  * met.EMD +
      cfg.wCDL  * met.CDL +
      cfg.wARR  * (1.0 - met.ARR)

  if S_horror < 0.0 then S_horror = 0.0 end

  local G_bci = 1.0 + cfg.gammaArousal * bci.arousal + cfg.gammaOverload * bci.overload
  local det_cap = H.DET_cap(env.cfg.safetyTier)
  if G_bci > det_cap then G_bci = det_cap end

  local m_dead = 1.0 - cfg.deadlanternMask * input.deadlantern

  local ds = -cfg.lambdaDecay * S_horror * G_bci * m_dead + cfg.lambdaRecover * (1.0 - sa)
  ds = ds + bounded_noise(env.noise.sanity)

  sa = sa + dt * ds
  sa = clamp(sa, env.bounds.sanity.min, env.bounds.sanity.max)

  env.state.sanity = sa
end

local function horror_step(env, input, inv)
  local cfg = env.cfg.horrorExposure
  local dt = env.dt
  local R = env.state.R

  local Hstim =
      cfg.thetaCIC  * inv.CIC * input.flash +
      cfg.thetaAOS  * inv.AOS * (1.0 - input.flash) +
      cfg.thetaLSG  * inv.LSG +
      cfg.thetaHVF  * inv.HVF.mag

  local dR = cfg.lambda * (Hstim - R) + bounded_noise(env.noise.R)
  R = R + dt * dR
  R = clamp(R, env.bounds.R.min, env.bounds.R.max)

  env.state.R = R
end

local function opacity_step(env, input, inv, met, bci)
  local cfg = env.cfg.opacity
  local dt = env.dt
  local O = env.state.O

  local O_target =
      cfg.thetaAOS * inv.AOS +
      cfg.thetaSTCI * (1.0 - met.STCI) +
      cfg.thetaOverload * bci.overload

  local dO = cfg.lambda * (O_target - O) + bounded_noise(env.noise.O)
  O = O + dt * dO
  O = clamp(O, env.bounds.O.min, env.bounds.O.max)

  env.state.O = O
end

local function battery_step(env, input, inv)
  local cfg = env.cfg.battery
  local dt = env.dt
  local B = env.state.battery

  local L_bat = input.flash * (1.0 + cfg.phiCIC * inv.CIC)

  local dB = -cfg.lambdaDrain * L_bat + cfg.lambdaRecover * (1.0 - input.flash) * (1.0 - B)
  dB = dB + bounded_noise(env.noise.battery)

  B = B + dt * dB
  B = clamp(B, env.bounds.battery.min, env.bounds.battery.max)

  env.state.battery = B
end

function PlayerEnvelopeFPS:tick(player_id, input)
  local inv, region_id, tile_id = sample_invariants(player_id)
  local met = sample_metrics(player_id)
  local bci = sample_bci(player_id)

  vel_step(self, input, inv)
  stamina_step(self, input, inv)
  sanity_step(self, input, inv, met, bci)
  horror_step(self, input, inv)
  opacity_step(self, input, inv, met, bci)
  battery_step(self, input, inv)

  self:log_telemetry(player_id, region_id, tile_id, inv, met, bci, input)
  return self.state
end

function PlayerEnvelopeFPS:log_telemetry(player_id, region_id, tile_id, inv, met, bci, input)
  local rec = {
    t = os.clock(),
    playerId = player_id,
    regionId = region_id,
    tileId = tile_id,
    state = self.state,
    invariants = inv,
    metrics = met,
    bci = bci,
    input = input
  }
  HorrorTelemetry.write_ndjson("player-envelope-fps", rec)
end

return PlayerEnvelopeFPS
