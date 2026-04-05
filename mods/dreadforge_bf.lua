-- mods/dreadforge_bf.lua
local H = require("horror_invariants")
local Director = require("surprise_director")

function onPlayerSpawn(spawnPointID)
    local inv = H.get("battlefield_" .. spawnPointID)
    if inv.CIC > 0.8 and inv.LSG > 0.7 then
        -- Trigger Vanish.Dissipation! chain
        Director.queue_event({
            type = "spectral_echo",
            target = spawnPointID,
            hvf = H.HVF("battlefield_" .. spawnPointID),
            duration = 4.2,  -- tuned to break camping rhythm
            bci_aware = true
        })
    end
end
