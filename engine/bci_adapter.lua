-- engine/bciadapter.lua
--
-- Lua API for Brain-Computer Interface (BCI) feedback.
-- This module provides a Lua interface to interact with BCI hardware/software
-- to read physiological data (e.g., fear levels, heart rate, EEG patterns).
-- It allows other Lua scripts (e.g., surprisedirector.lua, trajectoryscare.lua)
-- to modulate events based on real-time user state.
-- This is a placeholder implementation; actual BCI integration requires specific SDKs.

-- Placeholder state for BCI data
local bci_data = {
    fear = 0.0,           -- Normalized fear level (0.0 to 1.0)
    heart_rate = 70,      -- Beats per minute (bpm)
    eeg_alpha = 0.0,      -- Alpha brain wave activity (placeholder)
    eeg_beta = 0.0,       -- Beta brain wave activity (placeholder)
    -- ... other metrics
}

-- The BCI. API namespace
BCI = {}

-- --- Core BCI. API Functions ---

-- Get a normalized fear level estimate from the BCI
function BCI.get_fear()
    -- This function would interface with the actual BCI hardware/SDK
    -- to retrieve the current fear estimation.
    -- For now, it returns a simulated value or the last stored value.
    print("BCI.get_fear(): Simulated call. Returning stored value: " .. bci_data.fear)
    return bci_data.fear
end

-- Get the current heart rate
function BCI.get_heart_rate()
    print("BCI.get_heart_rate(): Simulated call. Returning stored value: " .. bci_data.heart_rate)
    return bci_data.heart_rate
end

-- Get alpha brain wave activity (placeholder for more complex metrics)
function BCI.get_eeg_alpha()
    print("BCI.get_eeg_alpha(): Simulated call. Returning stored value: " .. bci_data.eeg_alpha)
    return bci_data.eeg_alpha
end

-- Get beta brain wave activity (placeholder)
function BCI.get_eeg_beta()
    print("BCI.get_eeg_beta(): Simulated call. Returning stored value: " .. bci_data.eeg_beta)
    return bci_data.eeg_beta
end

-- --- Functions to Update BCI Data from External Source ---
-- In a real implementation, these might be callbacks triggered by the BCI SDK,
-- or polled regularly by the engine.

-- Function to update BCI data (called by the engine/core when new data arrives)
function BCI.update_from_sdk(new_data)
    if new_data and type(new_data) == "table" then
        bci_data.fear = new_data.fear or bci_data.fear
        bci_data.heart_rate = new_data.heart_rate or bci_data.heart_rate
        bci_data.eeg_alpha = new_data.eeg_alpha or bci_data.eeg_alpha
        bci_data.eeg_beta = new_data.eeg_beta or bci_data.eeg_beta
        print("BCI.update_from_sdk: Updated internal state from SDK data.")
    else
        print("BCI.update_from_sdk: Invalid data received from SDK.")
    end
end

-- Function to simulate updating BCI data for testing
function BCI.simulate_update(new_fear, new_hr)
    bci_data.fear = new_fear or bci_data.fear
    bci_data.heart_rate = new_hr or bci_data.heart_rate
    print(string.format("BCI.simulate_update: Set fear to %.2f, HR to %d", bci_data.fear, bci_data.heart_rate))
end

-- --- Utility Functions ---

-- Check if the user is in a high fear state
function BCI.is_high_fear(threshold)
    threshold = threshold or 0.7 -- Default threshold
    return BCI.get_fear() >= threshold
end

-- Check if the user's heart rate is elevated
function BCI.is_elevated_hr(threshold)
    threshold = threshold or 85 -- Default threshold in bpm
    return BCI.get_heart_rate() >= threshold
end

-- --- Example Usage ---
-- This would typically be called by the main engine loop or a BCI polling routine.
-- BCI.update_from_sdk({ fear = 0.65, heart_rate = 82 })

print("BCI. API (Lua) loaded.")
