// cpp/adapters/HorrorAudioDirector.h
#pragma once

#include <memory>
#include <string>
#include "LuaState.h"

struct RegionTileRef {
    int regionId;
    int tileId;
};

struct PlayerRef {
    int playerId;
};

class HorrorAudioDirector {
public:
    HorrorAudioDirector();
    ~HorrorAudioDirector();

    void Tick(float deltaSeconds);

    void OnPlayerSpawn(const RegionTileRef& spawnTile,
                       const PlayerRef& player);

    void OnRegionChanged(const RegionTileRef& newTile,
                         const PlayerRef& player);

    void SetInvariantSnapshot(const RegionTileRef& tile,
                              const PlayerRef& player,
                              const std::string& jsonSnapshot);

private:
    struct Impl;
    std::unique_ptr<Impl> Pimpl;

    void ApplySpawnSequenceFromLua();
    void UpdateAmbienceFromLua();
};
