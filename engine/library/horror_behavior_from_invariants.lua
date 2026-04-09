-- engine/library/horror_behavior_from_invariants.lua
-- Behavior helpers that derive spectral behavior from H. invariants.

local H = require("engine.library.horror_invariants")

local B = {}

--- Compute a local Spectral-History Coupling Index band and
--- basic manifestation mode for an entity in region.
--- Returns table { shci_band, mode } where:
--- shci_band: "low" | "medium" | "high"
--- mode: "rumor" | "glitch" | "full-apparition"
function B.compute_shci_mode(region_id)
    local shci = H.SHCI(region_id)
    if shci < 0.33 then
        return { shci_band = "low", mode = "rumor" }
    elseif shci < 0.66 then
        return { shci_band = "medium", mode = "glitch" }
    else
        return { shci_band = "high", mode = "full-apparition" }
    end
end

--- Decide whether a manifestation is allowed at a liminal edge
--- for a given player, clamped by DET and current CDL.
--- Returns table { allowed, intensity }.
function B.can_manifest_at_threshold(region_id, player_id)
    local det = H.DET(region_id)
    local cdl = H.CDL(player_id)
    local hvf_mag, _ = H.HVF(region_id)
    local lsg = H.LSG(region_id)

    -- Basic rule: higher CDL and lower DET reduce intensity
    local base = hvf_mag * lsg
    local safety = math.max(0.0, 1.0 - cdl)
    local intensity = base * safety

    if intensity <= 0.05 or det <= 0.1 then
        return { allowed = false, intensity = 0.0 }
    end

    -- Clamp to DET so exposure never exceeds local threshold.
    if intensity > det then
        intensity = det
    end

    return { allowed = true, intensity = intensity }
end

--- Composite helper used by AI agents:
--- Given region + player, returns a recommended manifestation
--- envelope: { mode, intensity } consistent with SHCI and DET.
function B.manifestation_envelope(region_id, player_id)
    local mode_info = B.compute_shci_mode(region_id)
    local edge = B.can_manifest_at_threshold(region_id, player_id)

    if not edge.allowed then
        return {
            mode = "none",
            intensity = 0.0,
        }
    end

    return {
        mode = mode_info.mode,
        intensity = edge.intensity,
    }
end

return B
