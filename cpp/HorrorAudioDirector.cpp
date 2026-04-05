// cpp/HorrorAudioDirector.cpp

#include "HorrorAudioDirector.h"

// Include your Lua binding headers here.
#include "LuaBindings.h"
// Include your audio engine headers here.
// #include "FmodWrapper.h" etc.

struct HorrorAudioDirector::Impl
{
    LuaState* L = nullptr;
};

HorrorAudioDirector::HorrorAudioDirector()
: impl_(new Impl())
{
    impl_->L = CreateLuaState();
    LoadLuaModule(impl_->L, "horror_audio");
}

HorrorAudioDirector::~HorrorAudioDirector()
{
    DestroyLuaState(impl_->L);
    delete impl_;
}

void HorrorAudioDirector::OnRegionTileChanged(PlayerId player, RegionId region, TileId tile, const InvariantSample& s)
{
    UpdateAmbienceFromLua(region, tile, s);
}

void HorrorAudioDirector::OnSpawn(PlayerId player, RegionId region, TileId tile, const InvariantSample& s)
{
    PlaySpawnSequenceFromLua(player, region, tile, s);
}

void HorrorAudioDirector::Tick(PlayerId player, float deltaSeconds, const InvariantSample& s)
{
    (void)deltaSeconds;
    ApplyRtpcsFromLua(player, 0, 0, s);
}

// ---------- Lua bridge helpers ----------

void HorrorAudioDirector::UpdateAmbienceFromLua(RegionId region, TileId tile, const InvariantSample& s)
{
    LuaState* L = impl_->L;

    BeginLuaCall(L, "horror_audio", "sample_region_ambience");
    PushInteger(L, static_cast<int>(region));
    PushInteger(L, static_cast<int>(tile));
    if (!PCallFunction(L, 2, 1))
        return;

    // Expect a table with fields: tags (array), density, weirdness, opacity.
    std::vector<const char*> tags;
    float density   = 0.0f;
    float weirdness = 0.0f;
    float opacity   = 0.0f;

    int tableIndex = GetTop(L);

    density   = GetFieldNumber(L, tableIndex, "density");
    weirdness = GetFieldNumber(L, tableIndex, "weirdness");
    opacity   = GetFieldNumber(L, tableIndex, "opacity");

    int tagsIndex = GetFieldTable(L, tableIndex, "tags");
    if (tagsIndex != 0)
    {
        int len = GetTableLength(L, tagsIndex);
        tags.reserve(len);
        for (int i = 1; i <= len; ++i)
        {
            const char* tag = GetTableString(L, tagsIndex, i);
            if (tag)
                tags.push_back(tag);
        }
        Pop(L); // pop tags table
    }

    Pop(L); // pop result table

    if (!tags.empty())
    {
        SetAmbienceLayers(region, tile,
                          tags.data(), static_cast<int>(tags.size()),
                          density, weirdness, opacity);
    }

    (void)s;
}

void HorrorAudioDirector::PlaySpawnSequenceFromLua(PlayerId player, RegionId region, TileId tile, const InvariantSample& s)
{
    LuaState* L = impl_->L;

    BeginLuaCall(L, "horror_audio", "compose_spawn_sequence");
    PushInteger(L, static_cast<int>(region));
    PushInteger(L, static_cast<int>(tile));
    PushInteger(L, static_cast<int>(player));

    if (!PCallFunction(L, 3, 1))
        return;

    // Expect table with fields: duration, layers (array of { role, tags }).
    std::vector<const char*> roles;
    std::vector<const char*> tags;
    float duration = GetFieldNumber(L, GetTop(L), "duration");

    int layersIndex = GetFieldTable(L, GetTop(L), "layers");
    if (layersIndex != 0)
    {
        int len = GetTableLength(L, layersIndex);
        for (int i = 1; i <= len; ++i)
        {
            int layerIndex = GetTableTable(L, layersIndex, i);
            if (layerIndex == 0)
                continue;

            const char* role = GetFieldString(L, layerIndex, "role");
            if (role)
                roles.push_back(role);

            int tagsIndex = GetFieldTable(L, layerIndex, "tags");
            if (tagsIndex != 0)
            {
                int tlen = GetTableLength(L, tagsIndex);
                for (int t = 1; t <= tlen; ++t)
                {
                    const char* tag = GetTableString(L, tagsIndex, t);
                    if (tag)
                        tags.push_back(tag);
                }
                Pop(L); // pop tags
            }

            Pop(L); // pop layer
        }
        Pop(L); // pop layers
    }

    Pop(L); // pop seq

    if (!roles.empty())
    {
        PlaySpawnLayered(player,
                         roles.data(), static_cast<int>(roles.size()),
                         tags.data(),  static_cast<int>(tags.size()),
                         duration);
    }

    (void)s;
}

void HorrorAudioDirector::ApplyRtpcsFromLua(PlayerId player, RegionId region, TileId tile, const InvariantSample& s)
{
    LuaState* L = impl_->L;

    BeginLuaCall(L, "horror_audio", "compute_dread_rtpcs");
    PushInteger(L, static_cast<int>(player));
    PushInteger(L, static_cast<int>(region));
    PushInteger(L, static_cast<int>(tile));

    if (!PCallFunction(L, 3, 1))
        return;

    int tableIndex = GetTop(L);

    const char* names[] = {
        "cic_weight",
        "aos_haze",
        "mythic_density",
        "haunt_mag",
        "dread_level",
        "uncertainty",
        "mystery_density",
        "resolution_bias"
    };

    for (const char* name : names)
    {
        float value = GetFieldNumber(L, tableIndex, name);
        SetRtpc(player, name, value);
    }

    Pop(L); // result
    (void)s;
}

// ---------- Engine-specific stubs ----------

void HorrorAudioDirector::SetAmbienceLayers(RegionId region, TileId tile,
                                            const char* const* tags, int tagCount,
                                            float density, float weirdness, float opacity)
{
    (void)region;
    (void)tile;
    (void)tags;
    (void)tagCount;
    (void)density;
    (void)weirdness;
    (void)opacity;

    // Map tags + density/weirdness/opacity to engine events/banks and RTPCs.
}

void HorrorAudioDirector::Play3DThresholdCue(PlayerId player,
                                             const char* const* tags, int tagCount,
                                             float intensity, float hvfDir, float hvfMag)
{
    (void)player;
    (void)tags;
    (void)tagCount;
    (void)intensity;
    (void)hvfDir;
    (void)hvfMag;

    // Select and play a 3D cue based on tags and vector info.
}

void HorrorAudioDirector::PlaySpawnLayered(PlayerId player,
                                           const char* const* layerRoles, int layerRoleCount,
                                           const char* const* layerTags,  int layerTagCount,
                                           float duration)
{
    (void)player;
    (void)layerRoles;
    (void)layerRoleCount;
    (void)layerTags;
    (void)layerTagCount;
    (void)duration;

    // Map roles+tags to layered events, schedule lifetime via duration.
}

void HorrorAudioDirector::SetRtpc(PlayerId player, const char* name, float value)
{
    (void)player;
    (void)name;
    (void)value;

    // Pass name/value into your audio middleware RTPC or parameter system.
}
