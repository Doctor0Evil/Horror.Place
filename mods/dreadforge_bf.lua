local H = require("horror_invariants")
local Director = require("surprise_director")

function onPlayerSpawn(spawnPointID)
    local inv = H.get("bf_spawn_" .. spawnPointID)
    if inv.CIC > 0.8 and inv.LSG > 0.7 then
        Director.queue_event({
            type = "spectral_echo",
            target = spawnPointID,
            hvf = inv.HVF,
            duration = 4.0
        })
    end
end
