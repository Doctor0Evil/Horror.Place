-- File: rivers_of_blood.lua

local H = require("engine.horror_invariants")

local Rivers = {}

function Rivers.update(region_id, dt)
    local cic = H.CIC(region_id)
    local aos = H.AOS(region_id)
    local hvf = H.HVF(region_id).mag or 0.0
    local shci = H.SHCI(region_id)

    -- flux: how hard history is pushing through the substrate
    local flux = (cic * aos) * (hvf + 0.1)

    H.emit("blood_flux", flux)

    if flux > 0.75 and shci > 0.9 then
        H.spawn_spirit("hemophage", region_id, { shci = shci, source = "rivers_of_blood" })
    end
end

function Rivers.on_investigator_enter(entity_id, region_id)
    local det = H.DET(region_id)
    if det < 0.7 then
        local sanity_damage = det * 0.3
        H.apply_sanity_damage(entity_id, sanity_damage)
        H.log("Investigator notes: The soil pulls, as if arterial.")
    end
end

return Rivers
