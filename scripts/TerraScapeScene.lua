-- Horror.Place/scripts/TerraScapeScene.lua
-- TerraScape – horror artstyle scene descriptor for PromptLang-Lua

local TerraScapeScene = {}

TerraScapeScene.metrics = {
  TDI = 0.85,   -- TerraDread Index
  FAF = 0.90,   -- FruitAnxiety Factor
  STG = 0.80,   -- SapTime Gradient
  OMP = 0.75,   -- OracleMoon Presence
  VPS = 0.88,   -- VoidProximity Score
  PSR = 0.70,   -- ParticleStillness Ratio
  FEC = 0.92,   -- FolkloreEnigma Coefficient
  BAV = 0.60,   -- BranchAggression Vector
  FTD = 0.85,   -- FruitTension Density
  CFL = 0.72,   -- CrustFracture Load
  VDR = 0.80,   -- VoidDominance Ratio
  OGA = 0.50,   -- OracleGaze Alignment (0 = fruits, 0.5 = tree, 1.0 = viewer)
  LWI = 0.88,   -- LoreWhisper Intensity
  DOF = 0.65,   -- DecayOrbit Function
  MSQ = 0.90,   -- MythicSilence Quotient
  WIM = 1.00,   -- WitnessIsolation Metric
}

TerraScapeScene.cameras = {
  cinematic_wide = {
    id          = "cinematic_wide",
    lens_mm     = 35,
    fov         = 60,
    angle       = "slightly_low",
    description = "wide establishing shot of half-destroyed planet and sentient tree, void below, dark green sky and jaundiced moon above"
  },
  fixed_side_orbit = {
    id          = "fixed_side_orbit",
    lens_mm     = 55,
    fov         = 45,
    angle       = "side_orbit",
    description = "fixed-camera horror plate, orbiting one side of the planet so the void looms behind the tree"
  },
  low_ground_up = {
    id          = "low_ground_up",
    lens_mm     = 24,
    fov         = 75,
    angle       = "ground_low_up",
    description = "low-angle view from near the pond, looking up at the furious tree and worried fruits overhead"
  },
  top_down_oracle = {
    id          = "top_down_oracle",
    lens_mm     = 35,
    fov         = 70,
    angle       = "top_down",
    description = "high, near-top-down oracle view showing more of the planet surface and fractures"
  },
  void_gaze_inversion = {
    id          = "void_gaze_inversion",
    lens_mm     = 18,
    fov         = 85,
    angle       = "from_below",
    description = "shot from beneath the planet, looking up through dripping glass-sand sap toward the silhouetted tree"
  }
}

local function choose_camera(m)
  if m.CFL > 0.8 or m.VDR > 0.85 then
    return TerraScapeScene.cameras.void_gaze_inversion
  end
  if m.BAV > 0.7 or m.FAF > 0.85 then
    return TerraScapeScene.cameras.low_ground_up
  end
  if m.WIM >= 1.0 and m.MSQ > 0.85 then
    return TerraScapeScene.cameras.fixed_side_orbit
  end
  if m.TDI < 0.6 then
    return TerraScapeScene.cameras.top_down_oracle
  end
  return TerraScapeScene.cameras.cinematic_wide
end

local function build_prompt(m, cam)
  return table.concat({
    "A hand-painted dark horror landscape, ",
    cam.description, ", ",
    "half-destroyed earth-like planet floating in a black void, lower half crumbling away with soil, rock, and glowing fragments falling off, ",
    "at the center a massive sentient tree with a god-like furious face carved into diseased bark, branches like many-armed hands clutching and threatening worried fruits, ",
    "each fruit with anxious, fearful expressions as if aware of their fate, ",
    "dark green sky filled with distant galaxies and star-mist, a jaundiced moon glaring from afar with glowing oracle clouds casting sickly yellow light, ",
    "glass-sand sap dripping from fractures along the planet’s underside like an hourglass into endless darkness, ",
    "filthy, layered textures: vein-scarred bark, gnawed crust, ash halos, bruised translucent fruit skin, oily pond reflecting the tree and moon, ",
    "hand-painted mixed-media style, visible brushstrokes, dark desaturated palette with deep greens, browns, and charred earth tones, ",
    "cinematic horror lighting, eerie, foreboding, otherworldly."
  })
end

function TerraScapeScene.generate()
  local cam = choose_camera(TerraScapeScene.metrics)
  local prompt = build_prompt(TerraScapeScene.metrics, cam)
  return {
    metrics = TerraScapeScene.metrics,
    camera  = cam,
    prompt  = prompt
  }
end

return TerraScapeScene
