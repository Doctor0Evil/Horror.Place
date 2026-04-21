# godot_h_run_bridge.gd
# Called once per conversational or gameplay turn.

func next_turn(state, user_text, gdctx):
    # gdctx: { region_id, dungeon_id, node_id, player_id, dt, ... }

    # 1) Run main narrative / selector logic.
    var result = H.Run.nextTurn(state, user_text, {
        "regionId": gdctx.region_id,
        "dungeonId": gdctx.dungeon_id,
        "nodeId": gdctx.node_id,
        "playerId": gdctx.player_id,
    })

    # 2) Let Lua decide if a surprise should fire on this node.
    var surprise_ctx = {
        "runId": state.run_id,
        "regionId": gdctx.region_id,
        "dungeonId": gdctx.dungeon_id,
        "nodeId": gdctx.node_id,
        "playerId": gdctx.player_id,
    }

    var activation = H.Surprise.try_fire_one(surprise_ctx, {
        "minScore": 0.45,
        "maxPerTurn": 1,
    })

    if activation != null:
        # Engine‑specific adapter: turn an abstract activation into a scene instance.
        _apply_surprise_activation(activation, gdctx)

    return result


func _apply_surprise_activation(activation, gdctx):
    # activation might contain:
    # - mechanicId
    # - activationProfile (e.g., requires liminal threshold tile, camera offset, SFX tags)
    # - styleId / implementationDescriptor
    # Use your SurpriseAdapter manifest to spawn or animate.
    var impl_id = activation.get("implementationId", "")
    var profile = activation.get("activationProfile", {})

    SurpriseDirector.instantiate_mechanic(impl_id, profile, gdctx)
