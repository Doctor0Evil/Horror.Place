# Failure Atlas: Common Design Flaws & Invariant Root Causes

**Version:** 1.0.0  
**Purpose:** Map observed player/design failures to specific invariant violations, enabling targeted fixes via Horror$Place contracts.

---

## 1. The "Sterile Spawn" Problem
**Symptom:** Players camp spawn points indefinitely; zero tension upon respawning.  
**Root Invariant Failure:** `LSG < 0.40`, `CIC < 0.50`, `HVF_mag = 0.0`  
**Why it happens:** Spawns are treated as neutral geometry rather than historically contested space.  
**Horror$Place Fix:** Enforce `DreadForge_Resonance.Contract` spawn thresholds. Inject `on_player_spawn` audio sequence with tinnitus + historical echo. Apply HVF vector pressure to nudge players into engagement lanes.  
**Reference:** Battlefield-style flat maps vs. Darkwood's hideout tension (nightfall DET curve).

---

## 2. The "Predictable AI" Loop
**Symptom:** Enemies patrol set paths; players learn routines and exploit sightlines.  
**Root Invariant Failure:** `RRM = 0.0` (no ritual residue), `MDI = 0.20` (low mythic uncertainty)  
**Why it happens:** Behavior trees ignore historical pressure; pathfinding uses static navmeshes.  
**Horror$Place Fix:** Train neural pathfinding on `RRM` and `HVF` fields. High RRM zones trigger erratic, "ritual-mocking" AI behaviors. Low MDI forces system to inject audio/visual anomalies to break player prediction models.  
**Reference:** Ice-Pick Lodge's intentional discomfort via scarcity + unpredictable threat pacing.

---

## 3. The "Flat Corridor" Syndrome
**Symptom:** Transition zones feel like loading screens; zero dread accumulation.  
**Root Invariant Failure:** `LSG = 0.10`, `AOS = 0.30`, `STCI < 0.40`  
**Why it happens:** Thresholds lack environmental stress gradients; audio remains static.  
**Horror$Place Fix:** Apply `Liminal Stress` audio filter (reverb spike, stereo narrowing) at tile boundaries. Inject `AOS`-driven redacted audio (bit-crushed whispers, muffled radio) to raise `UEC`.  
**Reference:** Darkwood's biome transitions (Dry Meadow → Silent Forest) use density shifts to create threshold anxiety.

---

## 4. The "Lore Dump" Fatigue
**Symptom:** Players skip notes; environmental storytelling feels disconnected from gameplay.  
**Root Invariant Failure:** `ARR < 0.50`, `EMD = 0.0` (no evidential mystery)  
**Why it happens:** Lore is presented as exposition, not interactive evidence.  
**Horror$Place Fix:** Tie lore fragments to `Spectral-Probability Index` (SPI). Only reveal records when player crosses high-`AOS` zones. Use `EMD` to space clues; never resolve all threads in one area. Maintain `ARR > 0.70` for sustained mystery.  
**Reference:** Aral Sea bioweapon history: real-world gaps in Soviet records mirror in-game `AOS`-driven mystery.

---

## 5. The "Adrenaline Crash" (Burnout)
**Symptom:** Player becomes desensitized after 15 mins of constant combat/scare loops.  
**Root Invariant Failure:** `STCI > 0.90` sustained, `CDL > 0.95`, no `DET` recovery  
**Why it happens:** Horror systems ignore pacing ceilings; no quiet valleys enforced.  
**Horror$Place Fix:** Implement `Dread Exposure Threshold` (DET) decay curves. After 120s of high-CIC exposure, force `Liminal_Sedation.Writ` mood: lower overt threat, raise background wrongness. Allow telemetry to cap `CDL` and reset `STCI` contrast.  
**Reference:** Ice-Pick Lodge's "no hand-holding" philosophy requires deliberate tension valleys to maintain player engagement.

---

## 6. The "Asset Clash" (Tone Breaker)
**Symptom:** Cosmic horror monsters spawn in grounded war zones; breaks immersion.  
**Root Invariant Failure:** `RWF < 0.40` on asset, `SPR` mismatch with region `CIC/MDI`  
**Why it happens:** No validation between asset type and historical attribution.  
**Horror$Place Fix:** Enforce `The Realism-Threshold (RT)` in CI. If `SPR` of entity > region `SPR` by 0.30, reject spawn. Use `Veracity-Variance (VV)` tags to scale monster appearance (mutated animal vs. glitch/uncanny).  
**Reference:** Hyper-realistic folklore mining: horror must emerge from verifiable geographic facts, not random placement.

---

## Validation Protocol
When auditing a build:
1. Run `scripts/validate_invariants.lua` on region seeds.
2. Generate heatmap via `scripts/generate_report.py`.
3. Cross-reference low-`UEC`/high-`CDL` telemetry zones with invariant logs.
4. If failure matches atlas entry, apply corresponding contract fix and re-test.

*Atlas is versioned alongside `core/schemas/`. Submit new failures via GitHub Issue tagged `failure-atlas`.*
