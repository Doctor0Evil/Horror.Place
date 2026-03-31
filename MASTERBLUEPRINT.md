## CORE GOAL

Design a horror research framework where **spectral presence + historical atrocity + uncertainty** drive *entertaining fear*—implemented as machine‑checkable invariants that tools, agents, and AI‑assistants can query and optimize.

> If horror reliably scares you, it is a form of entertainment; when that fear is sustained by evidence‑like mysteries, system automations can ground those mysteries in quasi‑factual patterns that keep you guessing, and that uncertainty is why it is scary—because you never fully know. [drwedge](https://drwedge.uk/2024/10/04/the-psychological-effects-of-horror-games-fear-fascination-and-the-thrill-of-the-unknown/)

***

## LAYER 1 – HISTORY‑AWARE HORROR WORLD MODEL

Treat the world (e.g., World‑of‑Darkwood) as a **geo‑historical database**: each region/volume stores structured trauma, myths, and record gaps. This is the substrate both spectral systems and AI authoring tools read from. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

**Core history fields (with hex IDs):**

1. Catastrophic Imprint Coefficient  
   - Name: Catastrophic Imprint Coefficient  
   - ID: `0xCIC`  
   - Meaning: Degree of man‑made / natural catastrophe bound to a location (wars, weapon trials, plagues, vanished settlements). High CIC → good candidate for boss sites, extreme environmental hazards, and “this place should *not* exist” setpieces. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

2. Mythic Density Index  
   - Name: Mythic Density Index  
   - ID: `0xMDI`  
   - Meaning: Density and variety of myths, rumors, and urban legends associated with an area, normalized by population/time. High MDI → more apparitions, audio anomalies, rumor‑driven quests. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

3. Archival Opacity Score  
   - Name: Archival Opacity Score  
   - ID: `0xAOS`  
   - Meaning: How incomplete, contradictory, or suspicious the records are (missing years, redactions, contradictory testimonies). High AOS → prime zones for conspiracies, secret labs, time‑slips, and info‑hazard events. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

4. Ritual Residue Map  
   - Name: Ritual Residue Map  
   - ID: `0xRRM`  
   - Meaning: Spatial layer encoding frequency and intensity of structured, repeated human actions (rites, test procedures, drills, cult meetings, military experiments). High RRM → faster activation of occult or anomalous mechanics. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

5. Folkloric Convergence Factor  
   - Name: Folkloric Convergence Factor  
   - ID: `0xFCF`  
   - Meaning: How many independent storylines, cultures, and time periods converge on similar motifs in the same spot (e.g., marsh spirit + weapons test + modern disappearances). High FCF → “natural” boss arenas and revelation sites. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

6. Spectral Plausibility Rating  
   - Name: Spectral Plausibility Rating  
   - ID: `0xSPR`  
   - Meaning: Composite likelihood that phenomena in this region can be explained as “haunting” within world rules, given CIC + MDI + AOS. High SPR → full spectral entities; mid SPR → ambiguous echoes; low SPR → psychological or environmental explanations only.

7. Reliability Weighting Factor  
   - Name: Reliability Weighting Factor  
   - ID: `0xRWF`  
   - Meaning: Per‑source credibility weight (official report vs. diary vs. bar rumor vs. cult tract). Aggregated into regional truth‑likelihood that AI can use when choosing which story version to foreground. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

8. Dread Exposure Threshold  
   - Name: Dread Exposure Threshold  
   - ID: `0xDET`  
   - Meaning: How long a character can remain in a region before measurable psychological/physiological impact should occur. Low DET → rapid sanity loss, hallucinations, AI aggression ramps; high DET → brief “safe” pockets. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

9. Haunt Vector Field  
   - Name: Haunt Vector Field  
   - ID: `0xHVF`  
   - Meaning: Direction + magnitude of “uncanny pressure” across space; derived from neighboring CIC/MDI/AOS/RRM/FCF. AI and PCG can bias movement, fog, sound, and spectral migration along this vector field.

10. Liminal Stress Gradient  
    - Name: Liminal Stress Gradient  
    - ID: `0xLSG`  
    - Meaning: Spatial gradients where states change sharply (forest/industrial, living/dead town, sacred/profane). High LSG → doorways, shorelines, tree‑lines where encounters, filters, and spectral manifestations are most effective. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/collection_e2b5eb8c-4dfa-4bf3-b6c9-d467a6fcdb53/b1ffc477-4ab9-450c-87d1-836edb6bcaed/Horror-Content-Generation.txt)

These are **machine‑readable invariants**: every tile/volume in the world carries these keys (or a subset) as structured data (JSON, data table, or level metadata).

***

## LAYER 2 – SPECTRAL PRESENCE AS HISTORY INTERFACE

A “spectral presence” is not just a monster; it is a **query result** against the history layer, expressed as audiovisual and systemic behavior.

**Spectral invariant (hex):**

11. Spectral‑History Coupling Index  
    - Name: Spectral‑History Coupling Index  
    - ID: `0xSHCI`  
    - Definition: Degree to which any given spectral entity’s behaviors, pathing, and trigger conditions are constrained by CIC/MDI/AOS/RRM/FCF of its region.  
    - High `0xSHCI`: Apparition reenacts specific weapon trials, evacuations, or “vanished convoy” patterns.  
    - Low `0xSHCI`: Specter is generic or dreamlike, only loosely tied to history.

At runtime, spectral systems use:

- `0xCIC`, `0xRRM` to choose *what* ritual or experiment is being echoed.  
- `0xAOS`, `0xSPR`, `0xRWF` to choose *how clearly* this echo appears (audio only vs. fully visible entity, coherent vs. glitching narrative).  
- `0xHVF`, `0xLSG`, `0xDET` to choose *where and when* manifestations are most effective for dread. [algoryte](https://www.algoryte.com/blogs/the-art-of-fear-secrets-of-horror-game-level-design/)

This gives you **spectral presence as environmental storytelling agent**, aligned with research on negative space and uncertainty in horror: most of the horror is suggested by patterns and absences, not explicit exposition. [horror.dreamdawn](https://horror.dreamdawn.com/?p=8586)

***

## LAYER 3 – ENTERTAINMENT FACTORS (FEAR AS FUN)

To directly encode your statement (“if horror is proven to scare you, it is entertainment”), we introduce **fear‑as‑entertainment metrics** grounded in psychology of horror games. [drwedge](https://drwedge.uk/2025/03/22/psychology-horror-games/)

12. Uncertainty Engagement Coefficient  
    - Name: Uncertainty Engagement Coefficient  
    - ID: `0xUEC`  
    - Meaning: Player’s engagement *because of* uncertainty (not in spite of it), measured from cautious movement, scanning, hovering, revisiting ambiguous zones. [reddit](https://www.reddit.com/r/survivalhorror/comments/1pvsej5/the_paradox_of_horror_design_why_clarity_is_the/)
    - High `0xUEC`: Unclear rules / threats are fun and tense. Low `0xUEC`: They feel confusing or unfair.

13. Evidential Mystery Density  
    - Name: Evidential Mystery Density  
    - ID: `0xEMD`  
    - Meaning: Rate at which the player encounters unresolved, apparently meaningful clues per unit time (documents, traces, glitches, NPC contradictions) without immediate closure. [polygon](https://www.polygon.com/23743064/shadows-of-doubt-proc-gen-detective-game-pc-steam-early-access/)
    - Target bands maintain “detective mode” without ever fully collapsing mystery.

14. Safe‑Threat Contrast Index  
    - Name: Safe‑Threat Contrast Index  
    - ID: `0xSTCI`  
    - Meaning: Magnitude and frequency of swings between perceived safety and danger, known to correlate with adrenaline spikes & enjoyment in horror. [sciencedirect](https://www.sciencedirect.com/science/article/abs/pii/S1875952125000813)
    - Controls pacing between quiet, evidence‑rich exploration and sudden ambiguous threat.

15. Cognitive Dissonance Load  
    - Name: Cognitive Dissonance Load  
    - ID: `0xCDL`  
    - Meaning: Number of mutually plausible explanations a player can maintain simultaneously (ghosts vs. experiment vs. hallucination vs. cover‑up). [drwedge](https://drwedge.uk/2025/03/22/psychology-horror-games/)
    - High `0xCDL`: Stories remain “evidence‑stacked but unsolved,” matching your “you don’t know” clause.

16. Ambiguous Resolution Ratio  
    - Name: Ambiguous Resolution Ratio  
    - ID: `0xARR`  
    - Meaning: Ratio of storylines/encounters that end in partial or suggestive resolution vs. fully explained, closed cases. [devforum.roblox](https://devforum.roblox.com/t/the-biggest-factor-in-a-horror-game/2079282)
    - High `0xARR`: System keeps some percentage of mysteries permanently unsettled.

These five metrics let the system answer the question: **“Is this horror that is scaring the player in a way they enjoy, and that keeps them guessing?”** That’s your entertainment invariant.

***

## LAYER 4 – PCG / WORKFLOW SPRINTS FOR HORROR AUTOMATION

Tie the above invariants into development workflows for World‑of‑Darkwood and similar projects, leaning on PCG and audio pipelines already identified in your reference guide. [algoryte](https://www.algoryte.com/blogs/the-art-of-fear-secrets-of-horror-game-level-design/)

### 4.1 Asset & map generation sprints

Use 2–4 week sprints focused on **“vibe‑first” PCG**:

- Mapgen: blend TileTerror‑style horror‑aware map generation with roguelike techniques (BSP, cellular automata, drunkard’s walk) to place choke points, dead ends, and odd spaces according to `0xCIC`, `0xHVF`, `0xLSG`. [algoryte](https://www.algoryte.com/blogs/the-art-of-fear-secrets-of-horror-game-level-design/)
- Environmental kits: modular Soviet/industrial / woodland kits tagged with history and horror invariants; generators pick modules whose tags match the region’s data record.  
- Spectral templates: `BP_SpectralResidual` blueprints parameterized by `0xCIC`, `0xRRM`, `0xSPR`, `0xSHCI` so AI or tools can instantiate varied yet consistent manifestations.

### 4.2 Audio and spectral soundscapes

Integrate FMOD/Wwise‑style middleware and horror sound libraries (SONNISS, Soundiron, HORROR SOUNDSCAPES) with your invariants. [algoryte](https://www.algoryte.com/blogs/the-art-of-fear-secrets-of-horror-game-level-design/)

- Attach `0xCIC`, `0xMDI`, `0xAOS`, `0xHVF`, `0xDET` as RTPCs / parameters controlling ambience intensity, spectral whispers, and stingers.  
- Link `0xUEC`, `0xEMD`, `0xSTCI` to dynamic mix changes—if UEC drops, add subtle clues; if STCI too low, inject a controlled spike event. [drwedge](https://drwedge.uk/2024/10/04/the-psychological-effects-of-horror-games-fear-fascination-and-the-thrill-of-the-unknown/)

### 4.3 Narrative and quest mining (“Development‑Mining”)

Use **development‑mining**: data‑driven pattern extraction from playtests. [edmcrae](https://www.edmcrae.com/article/procedural-narrative)

- Collect heatmaps of fear responses and engagement.  
- Correlate player behavior with local values of `0xCIC..0xHVF` and `0xUEC..0xARR`.  
- Train light models to predict which combinations of invariants produce good “fear‑as‑fun” and feed back into generation weights.

***

## LAYER 5 – AI‑ASSISTED AUTHORING & CHAT TOOLS

Leverage editor‑integrated LLM agents (e.g., Unreal Editor style) that can **read and write these invariants**, rather than hallucinating unconstrained content. [jenova](https://www.jenova.ai/en/resources/best-ai-for-the-asylum)

### 5.1 History‑aware prompt conditioning

When a designer chats:  
> “Generate a night event near the old testing fields in the salt flats.”

The AI assistant:

1. Reads regional data: `0xCIC=high`, `0xMDI=mid`, `0xAOS=high`, `0xRRM=high`, `0xFCF=high`, `0xSPR=mid`, `0xHVF` direction, `0xDET=low`.  
2. Reads entertainment metrics from telemetry: `0xUEC` has dipped, `0xEMD` is low here, `0xARR` is slightly low for the chapter.  
3. Proposes events that:  
   - Raise `0xEMD` via new partial evidence (a torn protocol, “drill” announcements that weren’t drills).  
   - Maintain or slightly increase `0xARR` by ending in an ambiguous spectral echo, not a full explanation.  
   - Respect `0xDET` by making the area oppressive if the player lingers.

### 5.2 AI as spectral designer

Give the AI explicit access to templates keyed by invariants, e.g.:

- Template ID: `0xEVT_SALT_ECHO`  
- Params: `{ CIC:0.9, AOS:0.85, RRM:0.8, SPR:0.7, UEC_target:0.75, EMD_target:0.6, ARR_target:0.8 }`

The AI fills slots (visual cue, sound cue, minor gameplay effect, lore snippet) subject to:

- Must raise `0xUEC` by increasing uncertainty without confusing basic rules.  
- Must increase `0xEMD` locally via more clues.  
- Must not drop `0xARR` below a chapter‑level threshold.

This is where **“teaching AI how to scare, for entertainment”** becomes operational: you’re not just prompting it with “make it scary,” you’re constraining it with numeric fear‑and‑mystery objectives supported by horror research. [sciencedirect](https://www.sciencedirect.com/science/article/abs/pii/S1875952125000813)

***

## LAYER 6 – RESEARCH FRONTIER & GAP‑FILLING

Use this blueprint as a **research map**:

1. **Empirical validation:**  
   - Study correlations between `0xUEC`, `0xEMD`, `0xSTCI`, `0xCDL`, `0xARR` and actual player enjoyment, fear reports, and willingness to replay. [drwedge](https://drwedge.uk/2025/03/22/psychology-horror-games/)
   - Validate that high uncertainty with enough evidential structure is more entertaining than either full clarity or total randomness.

2. **Ethics & wellness:**  
   - Integrate content “veils and lines” research and wellness guidance, especially for adult, intense horror. [horror](https://horror.org/wp-content/uploads/2022/06/HWA-MHI-Of-Horror-And-Hope-Wellness.pdf)
   - Add “maximum allowed CIC x exposure” constraints to avoid harmful overstimulation while preserving the thrill.

3. **Cross‑game generalization:**  
   - Apply the invariant schema to very different horror subgenres (cosmic, folk, psychological, industrial) to check which keys are universal and which need extension. [delaporemedia.wordpress](https://delaporemedia.wordpress.com/2022/08/13/horror-rpg-scenario-design-part-2-horror-narrative/)

4. **Tooling benchmarks:**  
   - Prototype in one environment (e.g., a Darkwood‑like zone in Unreal) using editor‑integrated AI.  
   - Measure content quality and iteration speed vs. traditional authoring; refine invariants as needed.

***

## HEX SUMMARY (FOR QUICK MACHINE USE)

Below is a compact “registry” you can hand directly to tools or agents:

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
- `0xSHCI` – Spectral‑History Coupling Index  
- `0xUEC` – Uncertainty Engagement Coefficient  
- `0xEMD` – Evidential Mystery Density  
- `0xSTCI` – Safe‑Threat Contrast Index  
- `0xCDL` – Cognitive Dissonance Load  
- `0xARR` – Ambiguous Resolution Ratio  

Together, these give you a merged, machine‑readable vocabulary for **history‑aware spectral horror**, **fear‑as‑entertainment**, and **AI‑driven content pipelines** aligned with current horror design and psychological research.
