-- engine/bci_adapter.lua
local BCI = {
    fear_level = 0.0,   -- 0.0–1.0 normalized
    arousal    = 0.0,
    valence    = 0.0,
    last_update = 0.0
}

function BCI.update_from_eeg(eeg_payload)
    -- eeg_payload: { fear = 0.73, arousal = 0.64, valence = -0.22, t = timestamp }
    BCI.fear_level = eeg_payload.fear or BCI.fear_level
    BCI.arousal    = eeg_payload.arousal or BCI.arousal
    BCI.valence    = eeg_payload.valence or BCI.valence
    BCI.last_update = eeg_payload.t or BCI.last_update
end

function BCI.update_from_face(face_payload)
    -- face_payload: { fear_prob = 0.81, disgust_prob = 0.12, t = timestamp }
    local fear_prob = face_payload.fear_prob or 0.0
    -- combine with existing fear_level for robustness
    BCI.fear_level = (BCI.fear_level * 0.6) + (fear_prob * 0.4)
    BCI.last_update = face_payload.t or BCI.last_update
end

function BCI.get_fear()
    return BCI.fear_level
end

return BCI
