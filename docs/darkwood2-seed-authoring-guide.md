# Seed Authoring Guide for Darkwood 2
Horror.Place × Acid Wizard × Ice‑Pick Lodge

## 1. What a “Seed” Is in This Pipeline

In the Schema Spine, a **seed** is a contract, not a vibe. For Darkwood 2, every seed you author must be expressible as:

1. **Geo‑Historical Invariant Pack** – numeric “bone structure” of a biome, corridor, or chapter.
2. **Style Contract Binding** – the look/sound/narrative envelope the seed must obey.
3. **Entertainment Metric Targets** – the fear curve we want the player to ride.
4. **Dead‑Ledger Attestation Hook** – how this seed will later be tied to ZKP‑backed safety/compliance.

Implementation details (PCG rules, AI behavior, audio routing) live in your own repos (e.g., `Darkwood2-Seeds`, Atrocity‑Seeds). The contracts live in Horror.Place and are enforced by CI.

---

## 2. Step 1 – Define Your Seed Concept

Start with a small, focused concept:

- One **biome or sub‑biome** (e.g., “Rotten Orchard at the Forest Edge”).
- Or one **chapter‑scale situation** (“Night Watch at the Salt Station”).
- Or one **liminal corridor** (“The Lane Between the Two Sick Houses”).

Give it a stable ID:

- For Darkwood 2 biomes: `darkwood2-{region}-{slug}-{version}`
  - Example: `darkwood2-aral-basin-01`, `darkwood2-rotten-orchard-01`.

Write a one‑sentence intent you can defend later:

> “Slow‑burn dread at the edge of the forest where the map feels wrong and nothing fully resolves.”

Keep this sentence – you’ll use it to sanity‑check your numbers.

---

## 3. Step 2 – Fill Out the Invariant Pack

Use the 11 invariants as your bone structure. Typical Darkwood‑adjacent ranges:

- **CIC** (Catastrophic Imprint): 0.6–0.9 – how strongly a real catastrophe shapes this place.
- **AOS** (Archival Opacity): 0.5–0.9 – how contradictory/hidden the history is.
- **RRM** (Ritual Residue): 0.2–0.7 – how much ritual echo there is.
- **MDI/FCF** (Myth/Folklore): 0.4–0.9 – how much local story has accumulated here.
- **SPR** (Spectral Plausibility): 0.6–0.95 – how “hauntable” this feels.
- **RWF** (Reliability): 0.3–0.9 – how trustworthy the evidence is.
- **DET** (Dread Exposure Threshold): 0–10 – how hard we are allowed to push escalation.
- **HVF** (Haunt Vector Field): 0–1 – how strongly dread “flows” through this region.
- **LSG** (Liminal Stress Gradient): 0.4–0.95 – how tense thresholds and borders feel.
- **SHCI** (Spectral‑History Coupling): 0.6–0.98 – how tightly any haunt must follow history.

For each seed, decide:

- Where is the catastrophe? (CIC/HVF/SHCI)
- Where is the confusion? (AOS/RWF/MDI/FCF)
- Where are the thresholds? (LSG)
- How hard are we allowed to push? (DET upper bound)

You do not need every field perfect; you must pick values you’re willing to live with as constraints. CI will later enforce that your implementation matches these ranges.

---

## 4. Step 3 – Bind to a Style Contract

Choose or define a **style contract** in Horror.Place:

- Visual: palette, grain, aspect, lighting profile.
- Audio: soundscape reference, mix profile, frequency bias.
- Narrative: tone, POV, pacing contract.

Examples for Darkwood‑like horror:

- `styleid: STY-DARKWOOD-FOREST-V1` – monochrome‑leaning forest, heavy grain, silence‑heavy audio, second‑person or unreliable POV.
- `styleid: STY-DESICCATED-COAST-V1` – the Aral‑basin style you already prototyped.

When you author a seed:

- Reference an existing **styleid** where possible.
- If you must create a new style, add a style contract to `registry/styles.json` and ensure it passes style schema + CI.

Remember: style contracts also define **permitted evidence types** (e.g., “disturbed earth”, “radio logs”, “censored documents”) and forbidden ones (explicit gore). Your seed’s implementation must only use the permitted evidence types.

---

## 5. Step 4 – Set Entertainment Targets

Use the five metrics to express the intended experience loop:

- **UEC** – Uncertainty Engagement (0–1).
- **EMD** – Evidential Mystery Density (0–1).
- **STCI** – Safe‑Threat Contrast (0–1).
- **CDL** – Cognitive Dissonance Load (0–1).
- **ARR** – Ambiguous Resolution Ratio (0–1).

For Darkwood 2, a typical “slow‑burn night” band:

- `UEC: 0.55–0.85` – player constantly scanning, but not frozen.
- `EMD: 0.60–0.90` – many clues, little explicit explanation.
- `STCI: 0.40–0.70` – noticeable swings between “maybe safe” and “maybe lethal.”
- `CDL: 0.30–0.60` – enough dissonance to feel wrong, not so much it feels random.
- `ARR: 0.70–1.0` – most threads stay unresolved.

Write these bands directly into your seed’s contract card. Later, telemetry will tell you whether your implementation really lives in these ranges.

---

## 6. Step 5 – Author the Contract Card

Use the Aral Basin example as a template. For each new seed, create a small JSON or YAML contract card in your seeds repo (or in a dedicated `docs/darkwood2-seed-cards/` directory in Horror.Place), containing:

- `seed_id`
- `classification` (e.g., `Tier 2 (Atrocity-Seed) — Mature`)
- `authority` (Horror.Place canonical / Darkwood 2 implementation)
- Invariant pack (code, name, value, short PCG influence note)
- Style contract reference (`styleid`, any local knobs)
- Metric bands
- A draft `deadledgerref` block:
  - `proof_envelope_id`
  - `verifier_ref`
  - `circuit_type`
  - `required_proofs` (e.g., `age_gating`, `charter_agreement`)

This card is your **single source of truth** when talking to:

- Engine programmers (they implement it).
- CI (it validates against invariants/style/metrics schemas).
- Publishers (they review it as part of greenlight).

---

## 7. Step 6 – Add a Registry Entry (Horror.Place)

Once the card feels right:

1. Add an entry to `registry/regions.json` (or `events.json`, `personas.json` as appropriate) in Horror.Place:

   - `id`: registry ID (e.g., `REG-DW2-ARAL-BASIN-01`).
   - `schemaref`: the required schema URI (invariants/style/event).
   - `artifactid` / `cid`: opaque reference to the concrete implementation in `Darkwood2-Seeds` / Atrocity‑Seeds.
   - `metadata`: human‑readable name and tags.
   - `deadledgerref`: copy the block from your card.

2. Commit and run CI:

   - **Schema validation** – checks `schemaref` and fields.
   - **Registry linter** – ensures required fields and `schema://Horror.Place/...` prefix.
   - **ZKP conformity** – validates `deadledgerref` structure and `verifier_ref` shape.

If CI fails because of `deadledgerref`, adjust the block; do not remove it. The whole point is that every production‑eligible seed has a ledger hook.

---

## 8. Step 7 – Implement the Seed Locally

With the contracts in place, Darkwood 2 / Atrocity‑Seeds teams now:

- Implement PCG rules using the invariant pack:
  - Choke points and sightlines in high‑CIC/HVF.
  - Conflicting landmarks and documents in high‑AOS.
  - Threshold anomalies at LSG spikes.
- Route audio and VFX through the style contract:
  - Bind CIC/AOS/DET to rumble, distortion, silence, flashes.
- Use invariants and metrics via the narrow API (Rust or Lua):

  - Rust: calls into `spectrallibrary` / `H` module.
  - Lua: calls `H.CIC(region_id)`, `H.LSG(tile_id)`, etc.

Run `drift_detector.py` against your implementation:

- It will compare your local seed files to the canonical style/invariants/metrics in Horror.Place.
- If you’ve drifted (different DET interpretation, wrong styleid, off‑schema fields), fix the implementation or adjust the contract card and rerun CI.

---

## 9. Step 8 – Pass and Pitch the Seed

When a seed is ready to show:

- The contract card + registry entry are what you attach to emails, pitch decks, and internal docs.
- The **Schema Spine tools** give you proofs:
  - `schema_spine_scanner.py` shows your seed sits cleanly in the schema universe.
  - `spine_dependency_graph.py` draws how this seed links to Black‑Archivum / Atrocity‑Seeds bundles and which style/metric schemas it uses.
  - `content_guard.py` guarantees no raw trauma payloads are leaking into Horror.Place or any public repo.

For Ice‑Pick Lodge, emphasize:

- High AOS/RWF/MDI seeds with long ARR tails and Archivist‑aware evolution.
- Belongings and rituals that canonically nudge ledger values between runs.

For Acid Wizard, emphasize:

- CIC/LSG/HVF‑driven spatial dread and soundscapes.
- The ability to scale Darkwood‑style pacing to larger worlds while staying in the same tested fear bands.

---

## 10. Quick Checklist for Designers

Before you call a seed “ready”:

- [ ] Seed has a clear ID and one‑sentence intent.
- [ ] Invariant pack filled with defensible values (including DET).
- [ ] Bound to an existing style contract or a new, CI‑valid one.
- [ ] Metric bands reflect the intended experience (especially ARR).
- [ ] Contract card created and stored in the repo.
- [ ] Registry entry added in Horror.Place with `deadledgerref`.
- [ ] CI passes (schema, linter, ZKP conformity, content guard).
- [ ] Local implementation passes `drift_detector.py`.
- [ ] You can explain this seed to a non‑technical producer using only the card.

If you can tick all boxes, the seed is ready to be shared, tested in Darkwood 2 builds, and eventually wired to Dead‑Ledger for full attestation.
