-- engine/trajectoryscare.lua
--
-- The Trajectory Scare module handles the physics and timing of
-- Vanish.Dissipation! sequences. It calculates trajectories for
-- vanishing entities or dissipation effects, potentially modulated
-- by BCI feedback to ensure the scare aligns with the user's state.
-- This provides an abstraction layer for complex, timed scare events.

local Traj = {}

----------------------------------------------------------------------
-- Simple kinematic helpers (for physical scare objects)
----------------------------------------------------------------------

-- Predict where the player will be after dt seconds (assuming constant velocity).
function Traj.predict_position(player, dt)
    local px, py, pz = player:get_position()
    local vx, vy, vz = player:get_velocity()
    return px + vx * dt, py + vy * dt, pz + vz * dt
end

-- Schedule a physics object to intersect the player's future vertical path.
-- This is a minimal, implication‑safe abstraction: the object falls to
-- coincide with where the player's y‑position will be after dt.
function Traj.schedule_falling_object(obj, player, dt, gravity)
    local _, ty, _ = Traj.predict_position(player, dt)
    local _, oy, _ = obj:get_position()

    -- Choose initial vertical velocity so object reaches ty at time dt:
    -- ty = oy + vy0 * dt - 0.5 * g * dt^2  ⇒  vy0 = (ty - oy + 0.5 * g * dt^2) / dt
    local vy0 = (ty - oy + 0.5 * gravity * dt * dt) / dt

    obj:set_velocity(0, vy0, 0)
    obj:set_active(true)
end

----------------------------------------------------------------------
-- Vanish.Dissipation! trajectory sequences
----------------------------------------------------------------------

-- Structure for defining Vanish.Dissipation! sequences.
-- Keys are sequence_id → sequence definition.
local VanishDissipationDefinition = {
    -- Example (see example_seq at bottom):
    -- ["vanish_dissipation_aral_basin"] = {
    --     stages = {
    --         { name = "approach",   duration = 3.5, tension_curve = "linear",
    --           bci_trigger = "fear > 0.6" },
    --         { name = "vanish",     duration = 0.8,
    --           visual_effect = "spectral_static",
    --           audio_effect  = "low_frequency_drone" },
    --         { name = "dissipation", duration = 5.0,
    --           tension_curve = "exponential_decay",
    --           bci_feedback  = "update_face_fear" }
    --     },
    --     metrics_impact = { STCI = 0.2, CDL = 0.1 }
    -- }
}

local ActiveTrajectories = {}

----------------------------------------------------------------------
-- Internal helpers
----------------------------------------------------------------------

local function finish_trajectory(instance)
    instance.state = "finished"
    print("Trajectory Scare: Finished sequence '" .. instance.id .. "'.")
    -- TODO: hook into metrics system (STCI/CDL deltas) and cleanup.
    ActiveTrajectories[instance.id] = nil
end

local function execute_stage(instance)
    local stage = instance.definition.stages[instance.current_stage_index]
    if not stage then
        print("Trajectory Scare: No stage found for sequence '" .. instance.id ..
                  "', index " .. tostring(instance.current_stage_index))
        finish_trajectory(instance)
        return
    end

    print("Trajectory Scare: Executing stage '" .. stage.name ..
              "' for sequence '" .. instance.id .. "'.")

    -- Handle BCI trigger/check if defined for this stage.
    if stage.bci_trigger and BCI and BCI.get_fear then
        -- Expect patterns like "fear > 0.6"
        local required_fear = tonumber(stage.bci_trigger:match("fear%s*>%s*(%d+%.?%d*)"))
        if required_fear and BCI.get_fear() < required_fear then
            print("Trajectory Scare: Stage '" .. stage.name ..
                      "' BCI trigger not met, delaying or soft‑skipping.")
            -- For now we simply delay by re‑arming next_stage_time later.
            -- More advanced behavior can be encoded via DSL/contract.
        end
    end

    -- Apply visual/audio effects if defined.
    if stage.visual_effect then
        print("Trajectory Scare: Applying visual effect: " .. stage.visual_effect)
        -- Renderer.apply_effect(stage.visual_effect, instance.params)
    end
    if stage.audio_effect then
        print("Trajectory Scare: Playing audio effect: " .. stage.audio_effect)
        -- AudioSystem.play_sound(stage.audio_effect)
    end

    -- Optional BCI feedback hook.
    if stage.bci_feedback and BCI then
        if stage.bci_feedback == "update_face_fear" and BCI.update_from_face then
            BCI.update_from_face("fear")
        end
        -- Other feedback patterns can be added here or moved into a DSL.
    end

    -- Schedule next stage based on duration.
    instance.next_stage_time = instance.stage_start_time + (stage.duration or 0)
end

----------------------------------------------------------------------
-- Public Vanish.Dissipation! API
----------------------------------------------------------------------

-- Registers a new Vanish.Dissipation! sequence definition.
function Traj.register_trajectory_sequence(def)
    if def and def.sequence_id and def.stages then
        VanishDissipationDefinition[def.sequence_id] = def
        print("Registered Vanish.Dissipation! Sequence: " .. def.sequence_id)
    else
        print("ERROR: Cannot register invalid Vanish.Dissipation! sequence definition.")
    end
end

-- Starts a Vanish.Dissipation! sequence.
function Traj.start_trajectory_sequence(sequence_id, target_params)
    local seq_def = VanishDissipationDefinition[sequence_id]
    if not seq_def then
        print("Trajectory Scare: Unknown sequence ID '" .. sequence_id .. "'.")
        return false
    end

    if ActiveTrajectories[sequence_id] then
        print("Trajectory Scare: Sequence '" .. sequence_id .. "' is already active.")
        return false
    end

    local instance = {
        id = sequence_id,
        definition = seq_def,
        params = target_params or {}, -- e.g., target_position, initial_velocity
        current_stage_index = 1,
        stage_start_time = os.clock(),
        next_stage_time = os.clock(),
        state = "running"
    }

    ActiveTrajectories[sequence_id] = instance
    print("Trajectory Scare: Started sequence '" .. sequence_id .. "'.")

    execute_stage(instance)
    return true
end

-- Updates all active trajectories; call once per frame with dt.
function Traj.update_trajectories(dt)
    local current_time = os.clock()
    for seq_id, instance in pairs(ActiveTrajectories) do
        if instance.state == "running" then
            if current_time >= (instance.next_stage_time or current_time) then
                instance.current_stage_index = instance.current_stage_index + 1
                if instance.current_stage_index > #instance.definition.stages then
                    finish_trajectory(instance)
                else
                    instance.stage_start_time = current_time
                    execute_stage(instance)
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- Example (contract‑driven in production)
----------------------------------------------------------------------

local example_seq = {
    sequence_id = "vanish_dissipation_aral_basin",
    stages = {
        {
            name = "approach",
            duration = 3.5,
            tension_curve = "linear",
            bci_trigger = "fear > 0.6"
        },
        {
            name = "vanish",
            duration = 0.8,
            visual_effect = "spectral_static",
            audio_effect = "low_frequency_drone"
        },
        {
            name = "dissipation",
            duration = 5.0,
            tension_curve = "exponential_decay",
            bci_feedback = "update_face_fear"
        }
    },
    metrics_impact = { STCI = 0.2, CDL = 0.1 }
}

Traj.register_trajectory_sequence(example_seq)

print("Trajectory Scare (Lua) loaded.")

return Traj
