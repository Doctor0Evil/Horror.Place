-- horror_api.lua (public core contract surface)

local H = {}
local Director = {}
local Persona = {}

-- H: history, invariants, metrics -----------------------------------------

-- Fetches the invariant bundle for a region or tile.
-- Returns a read-only table: { CIC=..., MDI=..., AOS=..., RRM=..., FCF=..., SPR=..., RWF=..., DET=..., HVF=..., LSG=..., SHCI=... }
function H.invariants(region_id, tile_id) end

-- Convenience accessors that internally call H.invariants(...)
function H.CIC(region_id, tile_id)  end
function H.MDI(region_id, tile_id)  end
function H.AOS(region_id, tile_id)  end
function H.SPR(region_id, tile_id)  end
function H.DET(region_id, tile_id)  end
function H.HVF(region_id, tile_id)  end
function H.LSG(region_id, tile_id)  end
function H.SHCI(region_id, tile_id) end

-- Entertainment metrics (UEC, EMD, STCI, CDL, ARR) as tracked for a player/session.
function H.session_metrics(session_id) end

-- Director: pacing, events, encounters -----------------------------------

-- Query which events are eligible at a location, given current history and session metrics.
function Director.query_events(args)
    -- args: { region_id=..., tile_id=..., session_id=..., target_UEC=..., target_EMD=..., min_ARR=... }
end

-- Schedule an event by ID, returning an opaque handle that the engine binds to scenes/VFX/audio.
function Director.schedule_event(session_id, event_id, params) end

-- High-level helper: ask Director to propose a \"next beat\" that nudges metrics toward targets.
function Director.next_beat(args)
    -- args: { session_id=..., region_id=..., tile_id=..., target_UEC=..., target_STCI=..., max_CDL=..., min_ARR=... }
end

-- Persona: Archivist/Witness/Echo/Threshold/Process ----------------------

-- Instantiate a persona instance bound to a style/persona contract.
function Persona.spawn(persona_id, context)
    -- context: { session_id=..., region_id=..., seed=..., style_id=... }
end

-- Tick/update a persona; returns a high-level intent (\"hint\", \"withhold\", \"contradict\", etc.).
function Persona.tick(handle, dt, sensory_telemetry)
    -- sensory_telemetry may include recent scares, HRV, player choices, etc.
end

-- Request a text/audio hint or description constrained by style and invariants.
function Persona.request_utterance(handle, channel, topic)
    -- channel: \"text\", \"voice\", \"ui\"
end

return {
    H = H,
    Director = Director,
    Persona = Persona,
}
