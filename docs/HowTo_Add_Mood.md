# How to Add a New Mood Contract

**Target Audience:** Developers, AI Co-Designers, QA Engineers.

This guide details the step-by-step process for creating a new mood profile that complies with the DreadForge Standard.

### Step 1: Define the Invariant Bands (JSON Schema)

Ensure you understand the constraints. Open `core/schemas/mood_contract_v1.json` to verify the required fields.

Create a new file: `moods/mood.<your_mood_name>.v1.json`.

**Example Skeleton:**
```json
{
  "mood_id": "mood.your_mood_name.v1",
  "version": "1.0.0",
  "tile_profiles": [ ... ],
  "experience_targets": { ... }
}
```

*Validation:* Run `ajv validate -s core/schemas/mood_contract_v1.json -d moods/mood.<your_mood_name>.v1.json`.

### Step 2: Implement the Lua Behavior

Create a new file: `moods/<Your_Mood_Name>.Contract.lua`.

**Requirements:**
1.  It must return a table containing the required hooks.
2.  It must require `engine.library.horror_invariants` and `engine.library.horror_audio`.
3.  Hooks must match those registered in Step 3.

**Example:**
```lua
local M = {}
function M.on_player_spawn(...) end
function M.on_tick(...) end
return M
```

### Step 3: Register the Mood

Open `registry/moods.json` and add your entry:

```json
{
  "mood.your_mood_name.v1": {
    "path": "moods/mood.<your_mood_name>.v1.json",
    "lua_module": "moods.Your_Mood_Name.Contract",
    "requires_hooks": ["on_player_spawn", "on_tick"]
  }
}
```

### Step 4: CI Validation

Before merging:
1.  **JSON Lint:** Ensure valid JSON.
2.  **Schema Lint:** Run the `validate-moods` workflow.
3.  **Lua Lint:** Run `lua scripts/mood_lint.lua registry/moods.json`.
    *   This script will check if your Lua module actually exports the functions promised in the registry.

### Step 5: (Optional) Constellation Wiring

If this mood is intended for use in external projects (e.g., Unreal/Godot adapters), add a reference to `HorrorPlace-Constellation-Contracts/registry/contracts.json`.
