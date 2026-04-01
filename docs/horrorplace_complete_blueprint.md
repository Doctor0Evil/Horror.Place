# Horror$Place Complete Foundation Compilation & VM‑Constellation Blueprint

## 1. Purpose and Scope

Horror$Place is a sovereign horror research engine whose outputs must be historically grounded, spectrally expressed, and entertainment‑validated through machine‑checkable invariants and metrics.[file:1] The goal of this blueprint is to consolidate all foundational specifications into a single, exportable document that defines the public core, the underground VM‑constellation, and the rules by which AI and tools may extend the system one file at a time.[file:1]

The document is written for direct inclusion in the `Horror.Place` public repository and serves as the baseline reference for every underground vault and VM node. It emphasizes procedural implication, GitHub safety, and cryptographic entitlement, ensuring that every horror output remains evidence‑driven and auditably constrained.[file:1]

---

## 2. Core Doctrine: Invariants, Metrics, and Entitlement

### 2.1 Historical Invariants (H.)

At the heart of Horror$Place is the history layer, expressed as a set of numeric invariants indexed per region/tile and accessed via the narrow `H.` API.[file:2] Each spatial unit exposes, at minimum:

- \(0xCIC\) — Catastrophic Imprint Coefficient  
- \(0xMDI\) — Mythic Density Index  
- \(0xAOS\) — Archival Opacity Score  
- \(0xRRM\) — Ritual Residue Map  
- \(0xFCF\) — Folkloric Convergence Factor  
- \(0xSPR\) — Spectral Plausibility Rating  
- \(0xRWF\) — Reliability Weighting Factor  
- \(0xDET\) — Dread Exposure Threshold  
- \(0xHVF\) — Haunt Vector Field  
- \(0xLSG\) — Liminal Stress Gradient  
- \(0xSHCI\) — Spectral‑History Coupling Index[file:1][file:2]

Public schema: `schemas/invariants_v1.json` defines the machine‑checkable structure for these invariants, including ranges, types, and optional `preconditions` that encode activation dependencies between regions.[file:1] Public API: `src/spectral_library.rs` (Rust) and `engine/horrorinvariants.lua` (Lua) implement the `H.` query functions used by all systems.[file:1][file:2]

### 2.2 Entertainment Metrics (Fear as Measurable Experience)

Fear in Horror$Place is quantified using entertainment metrics, defined in `schemas/entertainment_metrics_v1.json` and enforced across PCG, AI, pacing, and BCI subsystems.[file:1][file:2] Key metrics include:

- UEC — Uncertainty Engagement Coefficient  
- EMD — Evidential Mystery Density  
- STCI — Safe‑Threat Contrast Index  
- CDL — Cognitive Dissonance Load  
- ARR — Ambiguous Resolution Ratio[file:1][file:2]

The schema constrains each metric to [0.0, 1.0] with optional `delta_threshold` fields controlling maximum safe change between states.[file:1] The core success band for “effective mystery” is operationalized as maintaining UEC > 0.55 and ARR > 0.70 for long‑form experiences.[file:1]

### 2.3 Rivers of Blood Charter and Entitlement (Policy.)

The Rivers of Blood Charter formalizes Horror$Place ethics: horror is delivered through implication and evidence, never explicit depiction, and every manifestation must be traceable to historical invariants.[file:1] The Charter encodes statements such as “Every drop is an echo, every echo a record,” binding spectral behavior to ledger‑like geohistorical data.[file:1]

Entitlement is enforced by the `Policy.` API and the `HorrorPlace-Dead-Ledger-Network` vault.[file:1] It uses:

- ZKPs (age, charter agreement, ALN membership) for privacy‑preserving gating.  
- Tiered safety: `standard`, `mature`, `research`, aligned with `Cargo.toml` feature flags.  
- Verifiable credentials and ledger entries to prove rights to access mature/research content without revealing identities.[file:1]

Public doctrine and entitlement rules live in:

- `docs/rivers_of_blood_charter.md` — doctrinal charter.  
- `docs/hphistory_entertainment_framework.md` — invariants + metrics + ethics framework.  
- `docs/horrorplace_sovreign_blueprint.md` — sovereign repo and underground naming.[file:1]

---

## 3. Public Core Repository: Horror.Place

### 3.1 Repository Layout and Narrow APIs

The public `Horror.Place` repo is the sovereign, GitHub‑visible heart of the engine.[file:1][file:2] Its layout:

```text
Horror.Place/
├── Cargo.toml
├── src/
│   ├── spectral_library.rs
│   ├── pcg_generator.rs
│   └── audio_automation.rs
├── engine/
│   ├── horrorinvariants.lua
│   ├── bciadapter.lua
│   ├── surprisedirector.lua
│   └── trajectoryscare.lua
├── schemas/
│   ├── invariants_v1.json
│   ├── entertainment_metrics_v1.json
│   ├── stylecontract_v1.json
│   ├── eventcontract_v1.json
│   └── persona_contract_v1.json
├── docs/
│   ├── rivers_of_blood_charter.md
│   ├── hphistory_entertainment_framework.md
│   ├── horrorplace_sovreign_blueprint.md
│   ├── horrorplace_complete_blueprint.md   ← (this file)
│   ├── spectral_library_spec.md
│   ├── artstyle_spectral_engraving_dark_sublime.md
│   ├── artstyle_machine_canyon_biomech_bci.md
│   ├── style_router_module_spec.md
│   ├── style_lint_enforcement_module_spec.md
│   ├── style_contract_dsl_and_research_alignment.md
│   ├── archivist_contradiction_director_spec.md
│   └── diagrams/
│       ├── spectral_library_architecture.mmd
│       └── style_router_flow.mmd
├── scripts/
│   ├── ai_chat_templates.lua
│   ├── stylelint.lua
│   └── runstylelint.lua
└── registry/
    ├── styles.json
    ├── events.json
    ├── regions.json
    └── personas.json
```

The narrow APIs shared across VMs and repos are:

- `H.` — invariants: `H.CIC(region_id)`, `H.AOS(region_id)`, `H.SHCI(region_id)`, etc.[file:2]  
- `BCI.` — affect: `BCI.get_fear()`, `BCI.update_from_eeg(...)`, `BCI.update_from_face(...)`.[file:2]  
- `Director.` — pacing and Surprise.Events! scheduling.[file:2]  
- `Story.` — story spines and storylets (`Story.next_unseen_beat`, `Story.surface_fragment`).[file:1]  
- `Policy.` — entitlement and tier enforcement.[file:1]  
- `A.` — Archivist persona state machine.[file:1]

These APIs are treated as sockets; all implementations must preserve the same interface even if internals differ per VM.[file:1][file:2]

### 3.2 Schemas as Machine‑Checkable Contracts

Schemas define the shape of every horror object.[file:1] Core public schemas:

- `schemas/invariants_v1.json` — region invariant records, including dependency `preconditions`.[file:1]  
- `schemas/entertainment_metrics_v1.json` — UEC, EMD, STCI, CDL, ARR numeric bounds and thresholds.[file:1]  
- `schemas/stylecontract_v1.json` — style contract structure: `style_id`, `tier`, `platforms`, invariant ranges, metrics bounds, visual/semantic tags, and `implication_rules` such as `explicit_violence_forbidden` and `evidence_types_allowed`.[file:1]  
- `schemas/eventcontract_v1.json` — Surprise.Events! / Vanish.Dissipation! fields: `trigger_conditions`, `required_evidence`, `metrics_impact`.[file:1]  
- `schemas/persona_contract_v1.json` — persona state space, constraints, metric targets.[file:1]

These schemas are binding contracts between data producers (Vaults, tools) and consumers (engines, AI personas). No file enters the system without passing schema validation.[file:1]

### 3.3 Style Contracts, DSL, and Style Router

Styles are not cosmetic; they are contracts between history, engine, and AI tools.[file:1] The Style Contract DSL (defined in `docs/style_contract_dsl_and_research_alignment.md`) compiles into JSON documents validated against `schemas/stylecontract_v1.json`.[file:1] Example styles:

- `docs/artstyle_spectral_engraving_dark_sublime.md` / JSON variant — monochrome devotional cosmic horror with strict implication rules.[file:1]  
- `docs/artstyle_machine_canyon_biomech_bci.md` / JSON variant — industrial biomech style with BCI‑aware haptics.[file:1]

The Style Router, specified in `docs/style_router_module_spec.md`, selects artstyles per region/tile based on invariants and metrics, emitting a **Style Decision Object** consumed by rendering, narrative, and audio systems.[file:1] It relies on:

- Style registry: `registry/styles.json`.  
- Invariant queries via `H.`  
- Metric state from telemetry.[file:1]

Static and runtime validation are handled by `scripts/stylelint.lua`, `scripts/runstylelint.lua`, and the StyleLint Runtime Validator described in `docs/style_lint_enforcement_module_spec.md`.[file:1]

### 3.4 PCG and Audio Automation

The PCG subsystem (`src/pcg_generator.rs`) generates maps and world tiles where every tile’s type, encounters, and assets are determined by invariants and charter‑compliant rules, not arbitrary randomness.[file:1][file:34] It implements:

- `WorldTile` structures with `TileType` (SafeHaven, Exploration, HighThreat, LiminalThreshold, AtrocityAnchor) and embedded `HistoricalInvariantProfile`.[file:34]  
- `GeneratedAsset` records bound to invariants and entertainment contributions, ensuring historical justification and metric impact are explicit.[file:34]  
- Charter‑compliant asset factories (industrial decay, archival evidence, environmental traces, spectral residuals, structural anomalies, audio echoes) that honor implication‑only rules.[file:34]  
- Entertainment metric prediction for generated maps against `schemas/entertainment_metrics_v1.json`.[file:34]  
- Integration hooks to style router and audio automation via helper functions that derive style ids and audio profiles from invariants.[file:34]

The audio subsystem (`src/audio_automation.rs`) maps invariants and metrics to audio parameters (rumble, distortion, ritual motifs, silence spikes), treating silence and negative space as first‑class tools.[file:1][file:2]

---

## 4. VM‑Constellation and Underground Repos

### 4.1 Tiered VM Architecture

Horror$Place operates as a VM‑constellation: multiple nodes bound to specific repositories and tiers.[file:1]

- **VM‑Core (Tier 1)**  
  - Repo: `Horror.Place` (public).  
  - Role: rules engine, schemas, APIs, style DSL, safe persona patterns.

- **VM‑Vault‑T2 (Tier 2)**  
  - Repos: `HorrorPlace-Codebase-of-Death`, `HorrorPlace-Black-Archivum`, `HorrorPlace-Spectral-Foundry`, `HorrorPlace-Atrocity-Seeds`, `HorrorPlace-Obscura-Nexus`, `HorrorPlace-Liminal-Continuum`.[file:1]  
  - Role: extended datasets, full AI personas, PCG seeds, experimental styles, cryptographic agent market.

- **VM‑Lab‑T3 (Tier 3)**  
  - Repos: `HorrorPlace-Process-Gods-Research`, `HorrorPlace-Redacted-Chronicles`, `HorrorPlace-Neural-Resonance-Lab`, `HorrorPlace-Dead-Ledger-Network`.[file:1]  
  - Role: BCI/fMRI, neural resonance, haptic optimization, ALN/Googolswarm, ZKP‑based gating.

Each VM has a local implementation of `H.` and `BCI.` conforming to the public interfaces and a local configuration crate describing enabled tiers via `Cargo.toml` feature flags.[file:1]

### 4.2 Shared Directory Pattern Across All Repos

Every repo, including underground vaults, follows a consistent skeleton:[file:1]

```text
<Repo>/
├── README.md
├── Cargo.toml (or language manifest)
├── schemas/
├── contracts/
├── registry/
├── docs/
└── data/ or agents/ (for vaults/labs)
```

- `schemas/` — local or mirrored JSON Schemas (e.g., `persona_contract_v1.json`, `archive_record_v1.json`).  
- `contracts/` — style, event, persona, haptic, ZKP, or protocol contracts.  
- `registry/` — static JSON registries mapping ids to contract paths/hashes.  
- `docs/` — experiment protocols, specs, charters.  
- `data/` / `agents/` — signed datasets or agent artifacts (Tier 2/3 only).[file:1]

This pattern makes cross‑repo linking predictable and machine‑navigable.

---

## 5. Declarative Wiring: Schemas, Registries, DSLs

### 5.1 Schemas Define Shape, Registries Define Location

The wiring philosophy is:

- Schemas define the shape of horror objects (invariants, metrics, styles, events, personas, regions, cursed objects).[file:1]  
- Contracts/DSL encode behavior, rules, and entitlements (style DSL, persona state machines, event chains).[file:1]  
- Registries index these contracts by id and tier; engines and AI tools consult registries, never raw folders.[file:1]

Core public registries:

- `registry/styles.json` — `style_id` → contract path, tier, platforms.  
- `registry/events.json` — `event_id` → event contract path, invariant preconditions.[file:1]  
- `registry/regions.json` — `region_id` → invariant bundle + story spine seeds.[file:1]  
- `registry/personas.json` — `persona_id` → persona contract path, tier, SHCI range.[file:1]

Vault‑level registries mirror this structure (e.g., `HorrorPlace-Atrocity-Seeds/registry/events.json`) but point to internal files or IPFS hashes. The public core references vault assets indirectly via Git URLs or IPFS hashes pinned in its own registries.[file:1]

### 5.2 DSLs Define Behavior and Transformation Logic

Behavior is encoded in DSLs, then compiled to JSON or state machines.[file:1]

- **Style DSL** (`docs/style_contract_dsl_and_research_alignment.md`)  
  - Human‑readable contracts specifying invariant minima, metric ranges, visual/semantic tags, evidence types, and implication rules.  
  - Parsed by `scripts/stylelint.lua` into JSON, validated against `schemas/stylecontract_v1.json`.[file:1]

- **Persona DSL / State Machines** (`docs/archivist_contradiction_director_spec.md`)  
  - Defines persona states, transitions, guards using `H.` invariants and metrics, and effects on internal state (e.g., Archivist contradiction budget).[file:1]

- **Event Chain / Trajectory DSL** (Lua skeleton in `engine/trajectoryscare.lua` and `engine/surprisedirector.lua`)  
  - Stages and timing of Vanish.Dissipation! sequences, referencing BCI/metrics.[file:2]

These DSLs keep behavior auditable and decoupled from engine code.

---

## 6. Transition Channels and Cryptographic Enforcement

### 6.1 Transition Channels

Transition channels are formal pathways for data and validation signals between tiers.[file:1]

- **Registry Update Channel** — Vaults publish new content via releases and internal registries; Core’s Orchestrator polls, verifies hashes, and updates public registries via PRs.[file:1]  
- **Validation Feedback Channel** — Core dispatches validation requests to Vault workflows; Vaults respond with cryptographically signed reports (invariant compliance, metrics deltas) via `repository_dispatch` back to Core.[file:1]  
- **Agent Distribution Channel** — SSB‑based gossip of signed agents between Vault nodes; each node verifies signatures and compliance before admitting agents.[file:1]  
- **Telemetry Aggregation Channel** — Lab nodes aggregate BCI/fMRI and behavioral data, publish anonymized metrics to IPFS, and expose hashes back to Core for schema/DSL refinement.[file:1]

These channels are documented in `docs/horrorplace_sovreign_blueprint.md` and expanded here as part of the complete blueprint.[file:1]

### 6.2 ZKPs, Signed Agents, and Dead Ledger

The `HorrorPlace-Dead-Ledger-Network` repo defines:

- ZKP proof formats (`schemas/zkp_proof_v1.json`) and zkEVM contracts for age gating and charter verification.  
- Protocols for generating and verifying proofs integrated into `Policy.`.[file:1]

Agents (personas, Directors) are:

- Encoded as artifacts conforming to `schemas/persona_contract_v1.json` plus an `agent_artifact_v1.json` structure (agent_id, code_hash, contract_hash, compliance_report, signature).[file:1]  
- Signed by vault keys; validated by peers who enforce invariant fidelity first, entertainment efficacy second.[file:1]

The dead ledger (`HorrorPlace-Liminal-Continuum/registry/dead_ledger.json`) accumulates entries describing agent provenance and performance.[file:1]

---

## 7. AI‑Chat Hard Rules and File Generation Discipline

To align tooling with this blueprint, AI‑assisted editing and generation must obey strict rules:[file:1]

1. **One‑File‑Per‑Response**  
   - Each AI response that generates content must produce exactly one file.  
   - It must specify `Repository:` and `File path:` and provide full file content in a single fenced block.[file:1]

2. **Structural Wiring Expectations**  
   - Every file must declare which invariants and metrics it expects to use.  
   - It must reference the correct schema/contract (e.g., `stylecontract_v1.json`, `eventcontract_v1.json`).  
   - It must state the safety tier(s) it belongs to (standard/mature/research), aligned with `Cargo.toml` flags.[file:1]  
   - If defining a style, event, persona, region, haptic pattern, or agent, a future file must add the corresponding entry in the relevant `registry/*.json`.[file:1]

3. **Charter and Compliance Constraints**  
   - Procedural implication over explicit depiction: evidence (ledgers, stains, static, logs) only.[file:1]  
   - Tier 1 / `Horror.Place` can never contain explicit content; underground repos may hold mature/research artifacts but must be referenced schematically in Core, not copied.[file:1]

Under these rules, AI‑chat behaves as a deterministic file compiler, not an improvisational storyteller.

---

## 8. Research Roadmap and Phased Implementation

The blueprint supports a phased rollout that gradually lights up the VM‑constellation.[file:1]

### 8.1 Phase 1 — Core Extension (VM‑Core, Weeks 1–4)

- Finalize missing core docs and schemas: `hphistory_entertainment_framework.md`, `horrorplace_sovreign_blueprint.md`, `spectral_library_spec.md`, diagrams, JSON schemas for styles/events/personas.[file:1]  
- Implement Style DSL validator and Style Lint CLI.  
- Flesh out Directors and Surprise.Events! Lua skeletons wired via `H.` and `BCI.`.[file:1][file:2]

### 8.2 Phase 2 — Underground Seeds (VM‑Vault‑T2, Weeks 5–12)

- Bootstrap `HorrorPlace-Atrocity-Seeds` with Aral Sea and Soviet industrial data encoded as invariant‑bound event contracts; establish first cross‑repo pipeline to Core registries.[file:1]  
- Initialize `HorrorPlace-Black-Archivum` with normalized trauma archives and invariant bundles.[file:1]  
- Create initial persona contracts in `HorrorPlace-Spectral-Foundry` (Witness, Echo, Threshold, Process) referencing Archivist spec.[file:1]

### 8.3 Phase 3 — Neural Resonance (VM‑Lab‑T3, Weeks 13–20)

- Implement BCI/fMRI adapters and telemetry pipelines in `HorrorPlace-Redacted-Chronicles` and `HorrorPlace-Neural-Resonance-Lab`.[file:1][file:2]  
- Deploy Dead Ledger ZKP contracts and agent‑sharing protocol.[file:1]  
- Prototype Process‑Gods experiments with SHCI>0.95 under strict bounds.[file:1]

### 8.4 Phase 4 — Continuous Evolution (Ongoing)

- Use Seeders, Breeders, Validators, Researchers roles to evolve Archivist and other personas based on telemetry.[file:1]  
- Feed aggregate insights from IPFS telemetry into schema/DSL updates in `Horror.Place`, closing the loop between public rules and underground practice.[file:1]

---

## 9. Hex Registry Summary (Operational Glossary)

For machine use and quick reference, the invariant and metric set is:

- Invariants: CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI.[file:1][file:2]  
- Metrics: UEC, EMD, STCI, CDL, ARR.[file:1]

These symbols are the shared vocabulary binding history, spectral presence, PCG, AI, BCI, haptics, styles, and underground research into a single coherent horror engine.[file:1][file:2]
