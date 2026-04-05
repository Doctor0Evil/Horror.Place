-- library/seed_generator.lua
local Seed = {}
local H = require("engine.horror_invariants")

function Seed.generate_region(region_id, archetype, cic_bias, mdi_bias)
    local base = H.get(archetype) or {CIC=0.5, MDI=0.5, AOS=0.7}
    base.CIC = math.clamp(base.CIC * cic_bias, 0.1, 0.95)
    base.MDI = math.clamp(base.MDI * mdi_bias, 0.1, 0.95)
    -- Tag-based history spine construction
    local spine = StorySpine.build_from_tags({
        "industrial_disaster", "failed_ritual", "redacted_coverup"
    }, base)
    -- Export placemap-ready tileset metadata
    return {
        invariant = base,
        placemap_seed = procedural_wfc_seed_from_spine(spine),
        texture_pack = TexturePack.match_rrm(base.RRM),
        lore_export = spine.to_markdown()  -- for movie pre-viz or UI
    }
end

-- Usage in any engine: local seed = Seed.generate_region("battlefield_spawn_07", "war_trauma", 0.92, 0.65)
