// surprise_system.cpp

void SurpriseSystem::tick(const RunState& run,
                          const PlayerContext& player_ctx,
                          float dt)
{
    LuaRef h_surprise = lua.get_global("H").get("Surprise");

    LuaRef ctx = lua.new_table();
    ctx["runId"]     = run.id;
    ctx["regionId"]  = player_ctx.region_id;
    ctx["dungeonId"] = player_ctx.dungeon_id;
    ctx["nodeId"]    = player_ctx.node_id;
    ctx["playerId"]  = player_ctx.player_id;

    LuaRef opts = lua.new_table();
    opts["minScore"]   = 0.45;
    opts["maxPerTurn"] = 1;

    LuaRef activation = h_surprise.call<LuaRef>("try_fire_one", ctx, opts);

    if (!activation.is_nil()) {
        SurpriseActivation spec = decode_activation(activation);
        apply_surprise_activation(spec, player_ctx);
    }
}

SurpriseActivation SurpriseSystem::decode_activation(const LuaRef& activation)
{
    SurpriseActivation spec;
    spec.mechanic_id   = activation["mechanicId"].cast<std::string>();
    spec.impl_id       = activation["implementationId"].cast<std::string>();
    spec.score         = activation["score"].cast<float>();
    spec.tile_class    = activation["tileClass"].cast<std::string>();
    spec.style_profile = activation["styleProfileId"].cast<std::string>();

    // Optional invariant/metric snapshots for debug and telemetry.
    // These are read‑only; all authoritative history lives in DungeonMemory and Dead-Ledger.
    return spec;
}

void SurpriseSystem::apply_surprise_activation(const SurpriseActivation& spec,
                                               const PlayerContext& player_ctx)
{
    // Adapter resolves impl_id → actual engine behavior (spawn, SFX, camera warp).
    engine_surprise_adapter.instantiate_mechanic(spec, player_ctx);
}
