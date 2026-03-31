-- engine/horror_invariants.lua
local H = {}

local regions = {
    ["marsh_01"] = {
        CIC = 0.88, MDI = 0.76, AOS = 0.91,
        RRM = 0.67, FCF = 0.82, RWF = 0.54,
        DET = 0.72, SPR = 0.0, HVF = {mag = 0.81, dir = "NE"},
        LSG = 0.79, SHCI = 0.93
    },
    -- ... more regions
}

function H.get(region_id)
    return regions[region_id]
end

function H.CIC(region_id)
    return regions[region_id] and regions[region_id].CIC or 0.0
end

function H.SPR(region_id)
    return regions[region_id] and regions[region_id].SPR or 0.0
end

function H.LSG(region_id)
    return regions[region_id] and regions[region_id].LSG or 0.0
end

function H.HVF(region_id)
    return regions[region_id] and regions[region_id].HVF or {mag = 0.0, dir = "NONE"}
end

function H.SHCI(region_id)
    return regions[region_id] and regions[region_id].SHCI or 0.0
end

return H
