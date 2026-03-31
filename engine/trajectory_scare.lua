-- engine/trajectory_scare.lua
local Traj = {}

-- Predict where the player will be after dt seconds (assuming constant velocity).
function Traj.predict_position(player, dt)
    local px, py, pz = player:get_position()
    local vx, vy, vz = player:get_velocity()
    return px + vx * dt, py + vy * dt, pz + vz * dt
end

-- Schedule a physics object to intersect the player's future path.
function Traj.schedule_falling_object(obj, player, dt, gravity)
    local tx, ty, tz = Traj.predict_position(player, dt)
    local ox, oy, oz = obj:get_position()

    -- Simple vertical timing: choose initial vertical velocity so object reaches ty at time dt.
    local vy0 = (ty - oy + 0.5 * gravity * dt * dt) / dt

    obj:set_velocity(0, vy0, 0)
    obj:set_active(true)
end

return Traj
