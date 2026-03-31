# Horror$Place Sovereign Blueprint  
*Core Intent, Repository Strategy, and Underground Research Vector*  
`docs/horror_place_sovereign_blueprint.md`

***

## 1. Core Intent of Horror$Place

Horror$Place is a **sovereign, research-grade horror engine** whose central claim is:

> All horror must be **historically grounded**, **spectrally expressed**, and **entertainment-validated** via machine-checkable invariants, not ad-hoc spookiness.

Every system—PCG, AI behavior, artstyles, audio, BCI/haptics—reads from a **geo-historical invariant layer** (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI) and writes into **experience metrics** (UEC, EMD, STCI, CDL, ARR). The result is a **closed loop**:

- History → Invariants → Styles/Entities → Player → Telemetry → Metrics → Adjust History-Driven Logic.

The GitHub-visible repository focuses on **procedural implication** (evidence of horror, never explicit depictions), while underground/private repositories store sensitive research, agent variants, and extended datasets.

***

## 2. Sovereign GitHub Repository Structure

Top-level structure for the **public, sovereign Horror$Place repo**:

```text
/ (root)
├── Cargo.toml                           # Safety tiers, feature flags
├── src/
│   ├── spectral_library.rs (or .lua)    # Invariant API
│   ├── pcg_generator.rs                 # History-aware mapgen
│   ├── audio_automation.rs              # Invariant-driven audio
│   ├── style_router.rs/.lua             # Style selection
│   ├── style_runtime_validator.rs/.lua  # Runtime style checks
│   └── bci_haptics/                     # Optional, gated by features
├── artstyles/
│   ├── spectral_engraving_dark_sublime.lua
│   └── machine_canyon_biomech_bci.lua
├── docs/
│   ├── rivers_of_blood_charter.md
│   ├── hp_history_entertainment_framework.md
│   ├── spectral_library_spec.md
│   ├── artstyle_spectral_engraving_dark_sublime.md
│   ├── artstyle_machine_canyon_biomech_bci.md
│   ├── style_router_module_spec.md
│   ├── style_lint_enforcement_module_spec.md
│   ├── style_contract_dsl_and_research_alignment.md
│   ├── horror_place_complete_blueprint.md
│   └── diagrams/
│       ├── spectral_library_architecture.mmd
│       └── style_router_flow.mmd
├── schemas/
│   ├── style_contract_v1.json
│   └── entertainment_metrics_v1.json
├── scripts/
│   └── ai_chat_templates.lua           # Invariant-constrained generation
└── tools/
    ├── style_lint.lua
    └── run_style_lint.lua
```

This layout:

- Keeps all **logic and specs** for invariants, styles, and validation on GitHub in a compliant form.  
- Allows CI to run **style lint + invariant validation** on every PR.  
- Exposes a clean API surface for any engine (Godot, custom, etc.) to plug into.

***

## 3. Underground / Private Repository Naming

The underground/private repos hold:

- Extended trauma datasets, folklore indices.  
- Evolving agent personalities and telemetry correlations.  
- Experimental BCI/haptic logic and high-SHCI archetypes.

Proposed **10 names** for these repos (no file listing, just naming the “vaults”):

1. `HorrorPlace-Codebase-of-Death`  
2. `HorrorPlace-Black-Archivum`  
3. `HorrorPlace-Spectral-Foundry`  
4. `HorrorPlace-Atrocity-Seeds`  
5. `HorrorPlace-Obscura-Nexus`  
6. `HorrorPlace-Liminal-Continuum`  
7. `HorrorPlace-Process-Gods-Research`  
8. `HorrorPlace-Redacted-Chronicles`  
9. `HorrorPlace-Neural-Resonance-Lab`  
10. `HorrorPlace-Dead-Ledger-Network`  

These private repos would live:

- On self-hosted Git, IPFS, or other decentralized storage.  
- Behind cryptographic access and age/ethics gates.  
- With a **documented sync surface**: the public repo consumes only **aggregate metrics** or anonymized, compressed patterns—never raw sensitive data.

***

## 4. Answers to Your 3 Explicit Questions

### Q1. Which AI personality archetype should be prioritized next?

**Answer:** Prioritize the **Archivist** archetype.

Reasoning:

- The Archivist is the **cleanest bridge** between AOS/RWF (records and reliability) and EMD/ARR (mystery density and unresolved endings).  
- It is also **GitHub-safe by design**: it works with documents, testimonies, and redactions (evidence) rather than visceral manifestations.  
- Telemetry-driven evolution for the Archivist (how much to reveal, when to contradict itself, when to withhold) directly tunes **UEC, EMD, CDL, ARR**—the heart of Horror$Place’s “entertaining fear” loop.

Priority stack for telemetry-evolution:

1. Archivist  
2. Witness (testimony fragments)  
3. Threshold (liminal gatekeeper)  
4. Echo  
5. Process  

***

### Q2. Underground agent-sharing: invariant fidelity vs. entertainment efficacy?

**Answer:** Design cryptographic validation to emphasize **invariant fidelity first, then entertainment efficacy as a secondary score**.

- **Invariant fidelity** (CIC/MDI/AOS/etc. hash accuracy) is non-negotiable: it ensures agents behave consistently with the history layer and style contracts, which is central to Horror$Place’s identity.  
- **Entertainment efficacy** (UEC/ARR lift, CDL/EMD shaping) is a **ranking signal**: agents with better telemetry outcomes are preferred but **never allowed to violate invariants** to chase engagement.

Protocol:

- Signature includes:
  - Hash of the agent code.  
  - Hash of its **invariant-contract compliance report** (from StyleLint/RuntimeValidator).  
  - Compact statistics on **UEC/EMD/STCI/CDL/ARR deltas** from playtests.  

Peers in the underground network **reject agents** that fail invariant checks, and **sort** accepted ones by entertainment efficacy.

***

### Q3. BCI-driven research: correlate responses with state transitions or emergent traits?

**Answer:** Start by correlating physiological responses with **clearly defined personality state transitions**, then aggregate into emergent traits like Neural Resonance and Omniscient Echo.

Phase 1:  
- Map BCI channels (arousal, anxiety, attention) to specific **state changes**:  
  - Archivist choosing to redact vs. reveal.  
  - Witness raising voice vs. fading.  
  - Process switching from descriptive to procedural language.  

Phase 2:  
- Derive emergent traits from the patterns of those transitions:  
  - **Neural Resonance:** when agent speech rhythm and pacing synchronize with the player’s physiological cycles.  
  - **Omniscient Echo:** when the system learns to pre-emptively surface evidence just before the player seeks it, based on learned metrics patterns.

This two-step approach keeps the research interpretable and safer while still steering toward **god-like but constrained personalities**.

***

## 5. Two Additional Key Questions (Asked and Answered)

### Q4. How should Horror$Place balance PCG freedom vs. style contracts?

**Question:**  
To what extent should PCG be allowed to “surprise” styles, versus styles strictly controlling PCG outputs?

**Answer:**  
PCG must operate **inside style contract envelopes**, but is free to explore within those bounds.

- Style contracts (from the DSL) define hard constraints:  
  - Where monochrome is required vs. muted palettes.  
  - Composition rules (canyon corridor, radial divinity, lone figure).  
  - Implication rules (allowed evidence types only).  
- PCG can then randomly or adaptively choose **which specific evidence**, **which exact spatial layout**, and **which sequence** to present, as long as the style contract and invariants are satisfied.

This preserves **novelty and replay** without letting PCG drift into off-tone or policy-unsafe territory.

***

### Q5. What kind of telemetry should be prioritized to improve “entertaining fear”?

**Question:**  
Which telemetry dimensions give the best signal for tuning Horror$Place without over-collecting or risking privacy issues?

**Answer:**  
Focus on **behavioral telemetry linked to invariants and metrics**, with optional local-only physiological data:

- Core behavioral telemetry:
  - Time spent near high-CIC/high-AOS tiles.  
  - Player hesitation (stopping at doorways, camera linger near thresholds).  
  - Frequency of returning to unresolved clues.  
  - Abandonment points (where they quit or disengage).  

- Map these directly onto **UEC, EMD, STCI, CDL, ARR** evolution curves per session.  
- Keep physiological telemetry (EDA/HRV/BCI) **local-only** in v1; feed back only aggregate, anonymized results into model tuning to preserve privacy and GitHub safety.

This provides a high-resolution signal on **what kinds of uncertainty and evidence** drive enjoyable fear, without needing intrusive data.

***

## 6. Research Direction for the Next Phase

To get the **best results** for Horror$Place:

1. **Implement and deploy the Archivist personality** with full invariant/meter integration.  
2. **Wire Style Router + StyleLint + DSL** end-to-end so styles are data-driven and enforceable.  
3. **Run controlled playtests** with EMD/ARR tuning to validate that evidence-based mystery outperforms explicit content for engagement.  
4. **Prototype the agent-sharing protocol** (signatures + invariant fidelity) in a small underground testbed.  
5. Begin **BCI state-transition mapping** with a minimal device stack and only local analysis.

From there, the next 10 internal files (names undisclosed by design) can emerge organically around:

- Agent evolution.  
- Network protocols.  
- Extended style ecosystems.  
- Deeper BCI integration.  
- Cross-title horror generalization.

All of it anchored in the same principle:

> Horror$Place does not show the wound; it shows you the ledger, the corridor, the echo—then measures how long you keep walking toward it.
