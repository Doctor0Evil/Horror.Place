-- File: rivers_of_blood.lua

function UpdateRivers(region_id, dt)
    local cic = H.CIC(region_id)
    local aos = H.AOS(region_id)
    local hvf = H.HVF(region_id)
    local flux = (cic * aos) * (hvf + 0.1)
    -- Adjust flow density and spectral resonance
    H.emit("blood_flux", flux)
    if flux > 0.75 then
        H.spawn_spirit("Hemophage", region_id, { shci = H.SHCI(region_id) })
    end
end

function OnInvestigatorEnter(entity, region_id)
    local det = H.DET(region_id)
    if det < 0.7 then
        H.apply_sanity_damage(entity, det * 0.3)
        H.log("Investigator feels arterial pull in the soil.")
    end
end
