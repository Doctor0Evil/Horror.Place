***

# Horror$Place History & Entertainment Framework  
`docs/hp_history_entertainment_framework.md`

***

## 1. Core Goal

Design a Horror$Place framework where **spectral presence, historical trauma, and systemic uncertainty** combine to produce **entertaining fear**, encoded as **machine-checkable invariants** that every tool, agent, and AI assistant must query before generating horror.

Fear is treated as an **entertainment signal**: when players stay engaged under uncertainty, the system considers the horror successful and tunes itself to maintain that state through evidence, not explicit depiction. [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)

***

## 2. Layer 1 – History-Aware World Model (Invariants)

Horror$Place treats each world (and every region/tile within it) as a **geo-historical database**. Regions are not just visuals; they are **records**: documented and inferred disasters, rituals, myths, and archival gaps encoded as invariants. These invariants are the **first-class data layer** that all spectral systems, PCG modules, and AI authoring tools must read.

### 2.1 Core History Invariants (with IDs)

Each location exposes a structured record containing:

1. **Catastrophic Imprint Coefficient (CIC / `0xCIC`)**  
   Measures the intensity and persistence of catastrophes—wars, plagues, industrial accidents, disappearances—that have marked this region. High CIC marks **boss arenas**, lethal anomalies, and zones that “should not exist,” while low CIC supports quieter, investigative horror. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

2. **Mythic Density Index (MDI / `0xMDI`)**  
   Captures the **density and variety of myths, rumors, and legends** tied to that location, normalized by population and time. High MDI supports **frequent apparitions, rumor-centric quests, and lore-rich encounters**, while low MDI leans toward mundane or rational horror. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

3. **Archival Opacity Score (AOS / `0xAOS`)**  
   Quantifies how incomplete, contradictory, or redacted the records are. High AOS regions generate **info-hazard events, conspiracies, missing years, and paradoxical testimonies**; low AOS supports clearer, more documented histories. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

4. **Ritual Residue Map (RRM / `0xRRM`)**  
   A spatial layer describing the **frequency and intensity of repeated human actions**—rites, drills, experiments, patrols. High RRM accelerates **ritual activation, looped encounters, and pattern-based AI behaviors**. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

5. **Folkloric Convergence Factor (FCF / `0xFCF`)**  
   Measures how many independent storylines and cultures converge on similar motifs in the same place. High FCF creates natural **revelation hubs** and multi-era boss grounds; low FCF feels more singular or local. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

6. **Spectral Plausibility Rating (SPR / `0xSPR`)**  
   A composite likelihood that phenomena here can be interpreted as **haunting** under the world’s rules, derived from CIC+MDI+AOS. High SPR allows full-bodied apparitions; mid SPR leans to ambiguous echoes; low SPR favors psychological or environmental explanations. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

7. **Reliability Weighting Factor (RWF / `0xRWF`)**  
   Weights how trustworthy each source is (official reports, diaries, rumors, cult tracts) and aggregates them into a **truth-likelihood**. This guides AI when selecting which **version of events** to foreground in dialogue and environmental storytelling. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

8. **Dread Exposure Threshold (DET / `0xDET`)**  
   Indicates how long an entity can remain in this region before measurable psychological or physiological effects should appear. Low DET means rapid sanity erosion, hallucinations, and AI aggression spikes; high DET signals temporary “safe” pockets. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

9. **Haunt Vector Field (HVF / `0xHVF`)**  
   A vector field encoding direction and magnitude of “uncanny pressure,” derived from neighboring CIC/MDI/AOS/RRM/FCF. It drives **spectral migration, fog flows, and AI path bias** (entities, sounds, and anomalies tend to drift along HVF). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

10. **Liminal Stress Gradient (LSG / `0xLSG`)**  
    Encodes where **sharp transitions** in state occur—forest/industrial, sacred/profane, living/abandoned. High LSG points (doorways, tree-lines, shorelines) are privileged for **manifestations, filters, and thresholds** because transitions are where dread concentrates. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

These invariants are stored per region/tile as structured data (Lua tables, JSON, or level metadata) and must be accessed via the canonical Horror$Place API (the Spectral Library), not ad-hoc.

***

## 3. Layer 2 – Spectral Presence as History Interface

Spectral entities in Horror$Place are not arbitrary monsters; they are **query results** against the history layer. Each apparition, echo, or anomaly arises because the invariants demand it.

### 3.1 Spectral-History Coupling

11. **Spectral-History Coupling Index (SHCI / `0xSHCI`)**  
Defines how strictly an entity’s behavior, triggers, and pathing are constrained by local history. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

- High SHCI: Apparitions **re-enact specific events** (tests, evacuations, vanishings) and react to archival states (e.g., new evidence being found).  
- Low SHCI: More dreamlike specters; their behavior loosely reflects themes but not specific incidents.

### 3.2 Spectral Query Logic

When a spectral system wants to manifest something, it must:

- Use **CIC + RRM** to decide which trauma or ritual is being echoed.  
- Use **AOS + SPR + RWF** to determine **clarity vs. ambiguity** (audio-only, glitchy visuals, partial silhouettes, or full apparitions).  
- Use **HVF + LSG + DET** to decide **where and when** manifestations appear (thresholds, ridges, low-exposure pockets). [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

In practice, an entity AI state machine includes a mandatory step:

```lua
-- pseudo-logic
local inv = Spectral.QueryHistoryLayer(region_id, tile_id)
Spectral.SetBehaviorFromInvariants(entity, inv, metrics) -- sets aggression, opacity, patrol bias
```

This makes spectral presence a **living interface** to history: the world’s trauma speaks through behavior patterns rather than exposition. [icysedgwick](https://www.icysedgwick.com/horror-world-building-guest/)

***

## 4. Layer 3 – Fear as Entertainment Metrics

Horror$Place distinguishes between **fear that entertains** and fear that frustrates or harms. To do this, it defines a set of **experience metrics** that measure uncertainty, evidence density, and resolution ambiguity. [pmc.ncbi.nlm.nih](https://pmc.ncbi.nlm.nih.gov/articles/PMC8204235/)

### 4.1 Core Entertainment Metrics

12. **Uncertainty Engagement Coefficient (UEC / `0xUEC`)**  
Tracks how engaged players are *because of* uncertainty—hovering at thresholds, slow movement, repeated re-checks of ambiguous areas, and deliberate exposure to unknowns. [icysedgwick](https://www.icysedgwick.com/horror-world-building-guest/)

13. **Evidential Mystery Density (EMD / `0xEMD`)**  
Measures the rate at which players encounter **apparently meaningful but unresolved clues** per unit time: strange documents, anomalous markings, glitch events, contradictory NPC statements. [kindlepreneur](https://kindlepreneur.com/world-building/)

14. **Safe-Threat Contrast Index (STCI / `0xSTCI`)**  
Captures the strength and frequency of shifts between perceived safety and threat, a key factor in horror enjoyment through pacing (quiet exploration vs. sudden tension). [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)

15. **Cognitive Dissonance Load (CDL / `0xCDL`)**  
Counts how many **plausible explanations** a player can maintain at once (ghosts vs. experiments vs. hallucinations vs. cover-up). High CDL means evidence points in multiple directions without collapsing into a single, tidy interpretation. [icysedgwick](https://www.icysedgwick.com/horror-world-building-guest/)

16. **Ambiguous Resolution Ratio (ARR / `0xARR`)**  
Tracks the proportion of encounters and storylines that end in **partial or suggestive resolution** vs. fully explained outcomes. High ARR preserves dread and replay value by leaving meaningful gaps. [kindlepreneur](https://kindlepreneur.com/world-building/)

These metrics are logged per player/region and used by PCG, spectral AI, and style routing to **tune horror to remain fun**: maintain UEC and EMD in target ranges, keep ARR high enough to avoid over-explaining, and modulate CDL to avoid fatigue.

***

## 5. Layer 4 – PCG and Workflow Integration

The invariants and entertainment metrics guide **procedural content generation** and production workflows, ensuring every map, asset, and event is history-aware and pace-conscious. [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)

### 5.1 History-Weighted Map Generation

PCG modules (e.g., `pcg_generator.rs` in Rust or Lua-based mapgen) must:

- Use CIC, HVF, and LSG to place **choke points, dead ends, and liminal spaces** where dread should spike.  
- Maintain **atrocity anchors** (high-CIC tiles) across iterations, so trauma-rich locations persist even when layouts shift.  
- Choose tilesets and environmental kits via **tag matching** against invariants: industrial, marsh, or folk kits only appear where history supports them. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_cdb90fc3-8a6a-46e2-89a6-187b2f85f988/114f9185-3edf-4251-b08f-db275e57eb2f/for-this-conversation-let-s-cr-84g4wybTQday6rTQXVEVCQ.md)

### 5.2 Audio Automation and Negative Space

Audio middleware (e.g., `audio_automation.rs`) uses invariants and metrics to generate:

- CIC-driven low-frequency rumble, AOS-driven distortion and hiss, RRM-driven ritual motifs.  
- UEC/EMD/STCI-driven **dynamic mixes**: when UEC dips, subtle clues and textures emerge; when STCI flattens, controlled spikes of ambiguous threat are introduced. [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)

Silence itself becomes an asset: high-UEC regions can leverage **negative space audio**—long, careful quiet punctuated by distant machine or spectral hints.

### 5.3 Telemetry-Driven Development (“Development Mining”)

Playtest telemetry is mined to discover:

- Which combinations of CIC/MDI/AOS/LSG produce the most engaging fear.  
- Where entertainment metrics drift out of range (e.g., EMD too low → boredom, EMD too high → overload).  

These findings feed back into PCG weights and style routing, making Horror$Place **self-tuning** over time. [oneuptime](https://oneuptime.com/blog/post/2026-02-06-monitor-game-analytics-pipeline-opentelemetry/view)

***

## 6. Layer 5 – AI-Assisted Authoring and Agent Behavior

AI in Horror$Place is not a free improviser; it is a **spectral designer and archivist** obeying invariants and metrics.

### 6.1 History-Aware Prompt Conditioning

Editor-integrated AI assistants (e.g., Lua/Godot tools) handle prompts like:

> “Generate a night event in the salt flats near the old testing fields.”

They must:

1. Query invariants for that region/tile: CIC, MDI, AOS, RRM, FCF, SPR, HVF, DET.  
2. Query current player metrics: UEC, EMD, STCI, CDL, ARR.  
3. Select templates and patterns that:  
   - Raise EMD via new evidence.  
   - Preserve or increase ARR by avoiding full closure.  
   - Respect DET (don’t let the area remain mild if DET is low).  

The AI outputs **events, object placements, and narrative fragments** that are consistent with both the history layer and the entertainment targets. [icysedgwick](https://www.icysedgwick.com/horror-world-building-guest/)

### 6.2 AI Personalities as Horror Agents

Horror$Place defines **AI behavior archetypes** (Archivist, Witness, Echo, Process, Threshold) whose internal logic is driven by invariants:

- The Archivist foregrounds or withholds records based on AOS and RWF.  
- The Witness provides partial testimony in high-SPR regions.  
- The Echo repeats ritual patterns in high-RRM zones.  

Each personality monitors player metrics and adapts its behavior (e.g., increasing CDL, maintaining high ARR) to deliver **god-like but constrained** horror experiences.

***

## 7. Layer 6 – Research Frontier and Ethics

Horror$Place is a **research engine** as much as an entertainment system.

### 7.1 Empirical Validation

Research tasks include:

- Studying relationships between UEC/EMD/STCI/CDL/ARR and actual player enjoyment and fear reports.  
- Testing whether **evidence-driven uncertainty** (high EMD + high ARR) consistently outperforms both full clarity and pure randomness in producing satisfying horror. [pmc.ncbi.nlm.nih](https://pmc.ncbi.nlm.nih.gov/articles/PMC8204235/)

### 7.2 Ethics and Wellness

The system embeds wellness through:

- **Caps on CIC × exposure** to limit intensity.  
- Use of implication (bloodstained ledgers, disturbed earth, archival gaps) rather than explicit depictions.  
- Support for age gating and content tiers (standard, mature, research) at build level. [horror](https://horror.org/horror-world-building-tips-by-joanna-nelius/)

***

## 8. Hex Registry Summary

For quick machine use, the invariant set is:

- `0xCIC` – Catastrophic Imprint Coefficient  
- `0xMDI` – Mythic Density Index  
- `0xAOS` – Archival Opacity Score  
- `0xRRM` – Ritual Residue Map  
- `0xFCF` – Folkloric Convergence Factor  
- `0xSPR` – Spectral Plausibility Rating  
- `0xRWF` – Reliability Weighting Factor  
- `0xDET` – Dread Exposure Threshold  
- `0xHVF` – Haunt Vector Field  
- `0xLSG` – Liminal Stress Gradient  
- `0xSHCI` – Spectral-History Coupling Index  
- `0xUEC` – Uncertainty Engagement Coefficient  
- `0xEMD` – Evidential Mystery Density  
- `0xSTCI` – Safe-Threat Contrast Index  
- `0xCDL` – Cognitive Dissonance Load  
- `0xARR` – Ambiguous Resolution Ratio  

These form the shared vocabulary for **history-aware horror**, **spectral logic**, and **fear-as-entertainment** across PCG, AI, audio, styles, and underground knowledge layers in Horror$Place. [kindlepreneur](https://kindlepreneur.com/world-building/)
