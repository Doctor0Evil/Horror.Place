extends Node

class_name ResurrectionDirector

var lua_state     # FFI handle to embedded Lua
var mood_module   # cached Lua module

func _ready():
    lua_state = HorrorLua.new()
    lua_state.require("engine.library.horrorinvariants")
    lua_state.require("engine.library.horrormetrics")
    lua_state.require("engine.library.horrorresurrection")
    mood_module = lua_state.require("moods.HauntedReservoir.ResurrectionEcho.Contract")

func attempt_resurrection(origin_id: String, candidate_profile: Dictionary) -> Dictionary:
    var ctx = {
        "sessionId": HorrorTelemetry.current_session_id(),
        "regionId":  HorrorWorld.current_region_id(),
        "tileId":    HorrorWorld.current_tile_id(),
        "playerId":  HorrorWorld.current_player_id(),
        "originId":  origin_id,
        "candidateProfile": candidate_profile,
    }
    var result = lua_state.call(mood_module, "onEventAttempt", ctx)
    # Map abstract descriptors to concrete Godot behavior.
    if not result.allowed:
        HorrorLog.info("Resurrection blocked: %s (distance=%.3f)" % [result.reason, result.distance])
        return result

    if result.has("audio"):
        HorrorAudio.play_cue(result.audio.cue, result.audio.intensity)
    if result.has("visuals"):
        HorrorStyles.apply_style(result.visuals.styleId, result.visuals.mode)

    HorrorTelemetry.record_resurrection(origin_id, result.distance, result.metrics)
    return result
