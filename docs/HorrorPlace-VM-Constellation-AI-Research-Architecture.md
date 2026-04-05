Filename and destination:

- **Filename:** `docs/HorrorPlace-VM-Constellation-AI-Research-Architecture.md`  
- **Target repo:** `github.com/Doctor0Evil/Horror.Place`  
- **Path:** `Horror.Place/docs/HorrorPlace-VM-Constellation-AI-Research-Architecture.md` [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/d0db60df-4dcc-43b2-b889-2eb4a88581ea/this-research-focuses-on-creat-hfrKYptnQR.7lVWEu2zdUg.md)

Below is the GitHub‑ready document (no citations inside the file).

***

# Horror.Place VM‑Constellation AI Architecture & Research Synthesis

## 0. Purpose

This document consolidates the current Horror.Place VM‑constellation architecture and proposes a concrete AI‑assisted development stack. It is written for:

- Engine and tools engineers wiring Lua, Rust, C#, Unreal, Unity, and BCI.
- Repo maintainers designing schemas, contracts, and CI pipelines.
- Research teams in Lab‑tier repos building telemetry, BCI, and god‑like personalities.

The goal is to make the constellation **machine‑legible** for AI tools: invariants and contracts become the grammar that AI must obey when generating code, seeds, personas, and events.

***

## 1. Constellation Topology

### 1.1 Repo tiers

**Public Tier (Tier 1 – GitHub compliant)**

- `Horror.Place`  
  Sovereign core: invariant definitions, entertainment metrics, public schemas, Lua façade APIs, Tier‑1 safe docs.

- `Horror.Place-Orchestrator`  
  Cross‑repo orchestration, registry indexing, job dispatch, and CI orchestration for the constellation.

- `HorrorPlace-Constellation-Contracts`  
  Shared JSON/NDJSON schemas and contract specs for legends, seeds, events, personas, and FFI surfaces; CI templates and validators.

**Vault Tier (Tier 2 – private, user‑gated)**

- `HorrorPlace-Codebase-of-Death`  
  Full AI personalities, Surprise.Events!, high‑intensity behavior trees, and engine integrations that cannot live in Tier 1.

- `HorrorPlace-Black-Archivum`  
  Historical trauma archives, invariant bundles, and archival records that drive CIC/MDI/AOS/RWF and SHCI.

- `HorrorPlace-Spectral-Foundry`  
  Persona contracts and spectral entities; SHCI‑driven personality tuning and telemetry‑driven evolution.

- `HorrorPlace-Atrocity-Seeds`  
  PCG seed vault and extended invariant contracts for regions, hexes, and high‑intensity events.

- `HorrorPlace-Obscura-Nexus`  
  Experimental style DSLs, narrative styles, biome kits, and implication‑only content variants.

- `HorrorPlace-Liminal-Continuum`  
  Agent‑sharing, cryptographic marketplace logic, and style contract distribution.

**Lab Tier (Tier 3 – research grade)**

- `HorrorPlace-Process-Gods-Research`  
  High‑SHCI personality evolution experiments, including SHCI ≈ 0.95 “process” entities.

- `HorrorPlace-Redacted-Chronicles`  
  BCI/fMRI, EDA/HR archives, physiological response maps tied to entertainment metrics.

- `HorrorPlace-Neural-Resonance-Lab`  
  Haptic design, neural feedback tuning, and pacing curves informed by physiology.

- `HorrorPlace-Dead-Ledger-Network`  
  Age‑gated ledger, DID/CIKMS patterns, ZKP age gating, and trust fabric for artifacts.

Each tier has different **contract intensity** and **GitHub / safety constraints**. AI tools must understand which tier a proposed artifact belongs to.

***

## 2. Horror Algebra: Invariants and Metrics

### 2.1 Core invariants

These describe the **history and environment**:

- `CIC` – Catastrophic Imprint Coefficient  
  Magnitude of trauma and catastrophic events at a location.

- `MDI` – Mythic Density Index  
  Depth and richness of folklore, myths, and story fragments around the site.

- `AOS` – Archival Opacity Score  
  Degree of archival gaps, contradictions, and redactions.

- `RRM` – Ritual Residue Map (local strength)  
  Intensity and spread of ritual or repeated behavior residues.

- `FCF` – Folkloric Convergence Factor  
  How strongly disparate stories converge on similar shapes.

- `SPR` – Spectral Plausibility Rating  
  Derived plausibility that spectral phenomena “fit” the local history.

- `RWF` – Reliability Weighting Factor  
  Trustworthiness of sources for this region or event.

- `DET` – Dread Exposure Threshold  
  Exposure cap per session; how much dread can be safely accumulated.

- `HVF` – Haunt Vector Field (magnitude/direction)  
  Direction and strength of horror flow across tiles and thresholds.

- `LSG` – Liminal Stress Gradient  
  Stress intensity at thresholds, doors, borders, and transitions.

- `SHCI` – Spectral‑History Coupling Index  
  How tightly entities and anomalies must follow local documented history.

### 2.2 Player‑experience metrics

These describe **entertaining fear**:

- `UEC` – Uncertainty Engagement Coefficient  
  How engaged the player is via uncertainty and doubt.

- `EMD` – Evidential Mystery Density  
  Concentration of clues, hints, and unresolved micro‑mysteries.

- `STCI` – Safe‑Threat Contrast Index  
  Contrast between perceived safety and real danger in a moment.

- `CDL` – Cognitive Dissonance Load  
  Load from conflicting explanations, unreliable testimony, and ruptures.

- `ARR` – Ambiguous Resolution Ratio  
  Ratio of questions left open vs questions resolved.

These are tracked per session and per region; Seeds, legends, and events define **metric targets** (deltas and caps) rather than narrative scripts.

***

## 3. AI‑Assisted Development: Design Principles

Any AI tool in this constellation must obey three rules:

1. **Contract‑first**  
   No raw code or content is valid until it satisfies a relevant JSON/NDJSON contract in `HorrorPlace-Constellation-Contracts` and, where applicable, Atrocity‑Seeds, Spectral‑Foundry, or NightWhispers specs.

2. **Invariant‑aware**  
   No horror behavior should be generated without consulting invariants. Every spectral entity, rumor, or event is a **query result over invariant bundles**, not an arbitrary monster or jumpscare.

3. **Metric‑targeted**  
   Generated content must specify how it intends to move UEC, EMD, STCI, CDL, and ARR within safe DET and governance bands. Telemetry and BCI are used to validate and tune these targets.

***

## 4. Research Direction 1: Invariant‑Aware Code and Contract Generation

### 4.1 Constellation‑aware RAG

Build a retrieval system that ingests:

- All contract schemas from `HorrorPlace-Constellation-Contracts`.
- Public invariant definitions and examples from `Horror.Place`.
- NightWhispers specs, Seed contracts, and personality contracts that are Tier‑1 safe.

Given a user request (e.g., “new urban legend for Barrow Heights, high mystery, low resolution”), the system returns:

- Relevant schemas (legend meta‑quest, rumor contract, etc.).
- Invariant bands for the referenced region.
- Example NDJSON lines and contract fragments.

This becomes the **context injector** for AI tools.

### 4.2 Invariant type checkers as tools

Implement invariant checkers that run **before** file emission:

- Validate that any proposed invariant vector:
  - Respects global bounds (0–1 and per‑profile ranges).
  - Does not exceed DET caps for the region or session tier.
  - Aligns SHCI with persona behavior (e.g., high SHCI implies more historically literal manifestations).

If a generated artifact violates these bounds, the tool rejects it or asks the model to adjust values.

### 4.3 Seed‑to‑invariant mapping models

From `HorrorPlace-Black-Archivum` and `HorrorPlace-Atrocity-Seeds`:

- Learn how seed patterns (event types, region archetypes) map to invariant vectors and metric trajectories.
- Train models that can answer:
  - “Which seed profiles historically raise UEC by ~0.2 while keeping ARR ≥ 0.7?”
  - “What invariant envelope matches a plague‑like swamp vs a quarantined city?”

These become **advisors** for AI when it proposes new seeds or legends.

***

## 5. Research Direction 2: Cross‑Repository Workflow Synthesis

### 5.1 Artifact promotion pipeline

Formalize a state machine for artifact lifecycle:

- `Lab Draft` → `Vault Prototype` → `Public Contract` → `Deprecated`.
- Encode this as machine‑readable metadata (e.g., `status`, `tier`, `source_repo`, `validation_level`).

AI tools should:

- Tag outputs with an initial status (e.g., `lab_draft`).
- Know that certain artifacts (e.g., explicit Surprise.Events! content) can never enter Tier 1; only their contracts or implication‑only shells can.

### 5.2 Dependency oracle

Implement a graph of contract dependencies:

- Example: A new Surprise.Event! referencing:
  - A Spectral‑Foundry persona.
  - An Atrocity‑Seed region profile.
  - A NightWhispers legend.

The oracle can tell an assistant:

- Which repos need updates.
- Which CI checks will be affected.
- Which schema versions the new artifact must target.

### 5.3 Signature‑aware generation

AI outputs should include:

- Placeholders for DID references and `deadledgerref`.
- Fields for `validatorsignature` or “to‑be‑signed” metadata.

This ensures artifacts are **born governance‑aware**, ready to be anchored in `HorrorPlace-Dead-Ledger-Network` after human review.

***

## 6. Research Direction 3: Horror Algebra Simulation Environments

### 6.1 Invariant simulator

Create a lightweight simulator (Rust crate or similar) that:

- Accepts operations like:
  - “Add UrbanLegendMetaQuest X to zone Y with these rumor rules.”
  - “Change rumor decay parameters in Barrow Heights.”
- Computes approximate effects on:
  - Local CIC/MDI/AOS.
  - Local SPR, RRM, SHCI.
  - Derived DET caps.

AI tools can call this simulator to test whether a proposed contract:

- Overloads a region’s trauma or opacity.
- Breaks macro‑level balance.

### 6.2 Metric trajectory predictors

Using `HorrorPlace-Redacted-Chronicles` and playtest telemetry:

- Train models that map:
  - Proposed metric targets (UEC/EMD/STCI/CDL/ARR deltas) and invariants.
  - To expected physiological responses and engagement curves.

AI tools can:

- Ask “If I set UECdelta=0.2 and CDLdelta=0.3 in this sequence, what is the likely player effect?”
- Adjust metric envelopes before writing Seeds or legends.

### 6.3 Adversarial invariant validation

Design tools that:

- Deliberately push invariants and metrics to extremes in simulation.
- Catalog failure modes:
  - Overexposure (DET violations).
  - Boring maps (UEC too low).
  - Over‑resolution (ARR too low for too long).

AI generation then uses this **negative corpus** as a “what not to do” library.

***

## 7. Research Direction 4: FFI and Binding Automation

### 7.1 Bindings from Rust to C#/Lua

Leverage tools like `csbindgen` and existing Horror.Place FFI stubs to:

- Automate generation of:
  - C headers (`extern "C"` functions and POD structs).
  - C# P/Invoke bindings.
  - Lua façade modules that wrap FFI calls into `H.*` style APIs.

The AI assistant’s job:

- Propose Rust structs and function signatures.
- Generate corresponding bindings with consistent naming and memory semantics.

### 7.2 Lua façade generator

Given FFI functions (e.g., `nw_get_debug_snapshot`, `nw_horror_tick`):

- Auto‑generate a Lua module exposing:
  - `H.nightwhispers.snapshot()`.
  - `H.nightwhispers.apply_action(action_tag, intensity)`.
  - `H.nightwhispers.tick(player_state, zone_id)`.

All façade functions must:

- Query invariants first where relevant.
- Convert raw FFI data into engine‑agnostic structures.

### 7.3 Memory ownership annotations

Define a small annotation language for bindings:

- Example tags:
  - `#[ffi_owns_buffer]`, `#[caller_owns_buffer]`.
- AI uses these to:
  - Document who must free each buffer.
  - Avoid double‑frees and leaks across Rust/C#/Lua boundaries.

***

## 8. Research Direction 5: Contracts as Prompt Grounding

### 8.1 Contract retrieval service

Expose a service (or module) that:

- Accepts queries like:
  - “High‑EMD urban legend in Barrow Heights.”
  - “Seed for a low‑DET introduction sequence in Lantern Alley.”
- Returns:
  - Contract schemas.
  - Invariant profiles for the requested region.
  - Example NDJSON entries.

This becomes the **front door** for AI generation in the constellation.

### 8.2 Template‑guided contract generation

Maintain contract templates in `HorrorPlace-Constellation-Contracts`:

- Legend meta‑quest template.
- Rumor contract template.
- Seed contract templates per stage (outer, threshold, locus, rupture, aftermath).
- Persona templates (Archivist, Witness, Echo, Process, Threshold, etc.).

AI fills these templates with:

- Invariant vectors validated against local profiles.
- Metric targets consistent with experience goals.
- Allowed persona hooks and narrative affordances.

Output is a **ready‑for‑CI NDJSON or JSON file**.

### 8.3 Contract diff analysis

Before merging AI‑proposed contracts:

- Compare them with existing registry entries:
  - Are invariants overlapping in the same region with similar roles?
  - Do metric targets conflict with known sequences?
  - Do multiple contracts compete for the same triggers?

Flag collisions early and provide suggestions:

- Merge.
- Split into variants.
- Adjust invariants or metrics.

***

## 9. Research Direction 6: Telemetry‑Driven Feedback

### 9.1 Metric‑to‑content translation

Given telemetry observations:

- “Players in Clockwork Station flatten UEC after 15 minutes.”
- “ARR drops below 0.5 in Barrow Heights late game.”

AI tools should:

- Suggest content changes:
  - Increase mystery (EMD) via new Seeds or rumors.
  - Adjust DET caps or threat pacing.
  - Tune legend transitions or rumor decay.

This adds a **closed loop**: contract → runtime → telemetry → improved contract.

### 9.2 A/B test generator

AI can:

- Propose small variations in:
  - Rumor decay curves.
  - Legend hazard delta scaling.
  - Scene selection bias parameters.
- Package them as labeled variants (A/B/C) with:
  - Expected metric differences.
  - Clear gating to avoid overshooting DET.

Lab teams then run real tests and update priors.

### 9.3 Failure case database

Every CI failure or runtime invariant violation should log:

- The offending artifact (contract, code, Seed).
- The violated constraints (invariant, metric, governance).
- A short explanation.

This builds a **knowledge base of anti‑patterns** that AI searches before generation.

***

## 10. AI Chat Tool Stack for the Constellation

### 10.1 Tool: Constellation Context Injector

- Input: User request + current repo focus (e.g., “new Spectral Foundry persona”).
- Behavior:
  - Fetch relevant schemas, invariant profiles, examples.
  - Assemble a focused context bundle.
- Output:
  - Expanded prompt, ready for invariant‑aware generation.

### 10.2 Tool: Invariant‑Aware Generator

- Backend: Model tuned on Horror.Place doctrines and contracts.
- Guardrail:
  - Runs invariant and schema validation before finalizing output.
- Output:
  - NDJSON/JSON contracts and optional code stubs (Rust/C#/Lua) that reference them.

### 10.3 Tool: Cross‑Repo Orchestrator

- When a new Surprise.Event! is generated:
  - Writes event contract (Tier 1 or 2).
  - Stubs persona entries in Spectral‑Foundry.
  - Links or creates Seeds in Atrocity‑Seeds.
  - Updates agent manifests in Liminal‑Continuum.
  - Prepares PRs or change sets across all affected repos.

### 10.4 Tool: Metric Simulator Plugin

- Commands:
  - `simulate` – project metric deltas for a given legend or Seed.
  - `optimize` – suggest content that will push metrics toward target bands.
  - `validate` – check whether a proposed contract respects invariants and metric caps.

This becomes the “what‑if” sandbox for designers and AI alike.

### 10.5 Tool: FFI Binding Assistant

- Input:
  - Rust type definitions and function signatures.
- Output:
  - C header stubs.
  - C# bindings.
  - Lua façades.
  - Memory ownership docs.

All consistent with existing NightWhispers and core Horror.Place bindings.

***

## 11. Immediate Next Steps

For practical progress in the next iteration:

1. **Seed the public contract registry**  
   - Take a small set of NightWhispers legends, rumors, and Zones.
   - Encode them as NDJSON contracts using the existing and NightWhispers‑adjacent schemas.
   - Store in `HorrorPlace-Constellation-Contracts` and mirror any engine‑specific views in `Horror.Place`.

2. **Build the invariant simulator crate**  
   - Implement a minimal Rust crate that:
     - Loads region invariant bundles.
     - Applies simple operations (add legend, adjust rumor rules).
     - Computes updated CIC/MDI/AOS/DET/SHCI summaries.

3. **Define repo‑specific prompt profiles**  
   - For each repo, write a short “AI persona contract”:
     - What can be generated here.
     - Which schemas apply.
     - Which fields are mandatory or forbidden at Tier 1.

4. **Wire invariant validation into CI**  
   - Ensure any new contract files:
     - Validate against schemas.
     - Pass invariant and metric bounding checks.
   - Make failures informative for both humans and AI.

5. **Prepare a small training set**  
   - Collect existing valid contracts (Seeds, personas, events, legends).
   - Use them as a fine‑tuning or LoRA base so generation becomes schema‑native rather than ad‑hoc.

***

## 12. Closing

The Horror.Place constellation treats **invariants and contracts as the grammar of horror**. AI tools are new authors that must write in this grammar: every legend, rumor, persona, Seed, or event is a structured utterance over CIC, MDI, AOS, SHCI, UEC, EMD, STCI, CDL, ARR, and the rest of the horror algebra.

By giving AI access to:

- Schemas and contracts (syntax).
- Invariant simulators and telemetry (semantics).
- Tiered repos and Dead‑Ledger governance (pragmatics).

the constellation can support **buildable, safe, and powerful AI‑assisted development** across all engines, labs, and vaults.
