-- File: src/bci_haptics/machine_canyon_mapping.lua

local MachineBCI = {}

function MachineBCI.apply_bci_haptics(style_decision, inv, metrics, bci_data)
    if style_decision.style_id ~= "MACHINE_CANYON_BIOMECH_BCI" then
        return
    end

    local arousal  = bci_data.arousal  or 0.5
    local anxiety  = bci_data.anxiety  or 0.5
    local attention = bci_data.attention or 0.5

    local base_rumble = inv.cic * 0.4 + inv.shci * 0.2
    local floor_vibration = base_rumble * (0.5 + anxiety * 0.5)

    local cable_tension = attention * 0.6 + anxiety * 0.3
    local breath_pulse = (1.0 - arousal) * 0.5 + anxiety * 0.5

    Haptics.set("haptic_floor_vibration", floor_vibration)
    Haptics.set("haptic_cable_tension",   cable_tension)
    Haptics.set("haptic_breath_chest",    breath_pulse)
end

return MachineBCI
