// cpp/HorrorAudioDirector.h
// Horror$Place Dread Conductor – C++ adapter for FMOD-style middleware.

#pragma once

#include <cstdint>

struct InvariantSample
{
    float cic      = 0.0f;
    float mdi      = 0.0f;
    float aos      = 0.0f;
    float hvfMag   = 0.0f;
    float hvfDir   = 0.0f;
    float lsg      = 0.0f;
    float det      = 0.0f;
    float uec      = 0.0f;
    float emd      = 0.0f;
    float arr      = 0.0f;
};

using PlayerId = std::uint64_t;
using RegionId = std::uint32_t;
using TileId   = std::uint32_t;

class HorrorAudioDirector
{
public:
    HorrorAudioDirector();
    ~HorrorAudioDirector();

    // Called when a player moves to a new region/tile.
    void OnRegionTileChanged(PlayerId player, RegionId region, TileId tile, const InvariantSample& s);

    // Called when a player spawns.
    void OnSpawn(PlayerId player, RegionId region, TileId tile, const InvariantSample& s);

    // Called regularly (e.g., once per frame) to update RTPCs.
    void Tick(PlayerId player, float deltaSeconds, const InvariantSample& s);

private:
    // Glue into Lua horror_audio module.
    void UpdateAmbienceFromLua(RegionId region, TileId tile, const InvariantSample& s);
    void PlaySpawnSequenceFromLua(PlayerId player, RegionId region, TileId tile, const InvariantSample& s);
    void ApplyRtpcsFromLua(PlayerId player, RegionId region, TileId tile, const InvariantSample& s);

    // Engine-specific: connect to FMOD/Wwise/Godot/Unreal.
    void SetAmbienceLayers(RegionId region, TileId tile,
                           const char* const* tags, int tagCount,
                           float density, float weirdness, float opacity);

    void Play3DThresholdCue(PlayerId player,
                            const char* const* tags, int tagCount,
                            float intensity, float hvfDir, float hvfMag);

    void PlaySpawnLayered(PlayerId player,
                          const char* const* layerRoles, int layerRoleCount,
                          const char* const* layerTags,  int layerTagCount,
                          float duration);

    void SetRtpc(PlayerId player, const char* name, float value);

    // Implementation detail (Lua state, engine handles) is hidden.
    struct Impl;
    Impl* impl_;
};
