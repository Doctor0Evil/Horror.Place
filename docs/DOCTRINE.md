# Horror$Place Doctrine: The Law of Atmospheric Integrity

**Version:** 1.0.0  
**Status:** Enforced | **License:** Apache 2.0 (Seal Trademark Reserved)

---

## 0. The Core Axiom
> **"No behavior without `QueryHistoryLayer → SetBehaviorFromInvariants`."**

Every entity, sound, encounter, and visual effect in a Horror$Place-compliant project MUST originate from a verifiable historical, spatial, or psychological invariant. Randomness is forbidden. Atmosphere is not an overlay; it is a measurable property of space.

---

## 1. The Three Pillars

### 1.1 History-First Design
Geography remembers. A coordinate is never empty; it carries the weight of what occurred there.
- **Documented events** (wars, disasters, experiments) set `CIC` and `SPR`.
- **Archival gaps** (redactions, missing records, conflicting accounts) set `AOS`.
- **Human repetition** (rituals, drills, cult activity) sets `RRM`.
Tools must query these before spawning anything. If the history is silent, the space remains tense but restrained.

### 1.2 Metric-Driven Entertainment
Horror is entertainment when it proves you wrong, keeps you guessing, and never fully explains itself. We track five machine-checkable metrics:
- `UEC` (Uncertainty Engagement): Are players cautious, scanning, hesitating?
- `EMD` (Evidential Mystery Density): Are clues abundant but unresolved?
- `STCI` (Safe-Threat Contrast): Does tension peak and valley naturally?
- `CDL` (Cognitive Dissonance Load): Can players hold multiple plausible theories?
- `ARR` (Ambiguous Resolution Ratio): Do some threads remain intentionally open?
Systems must tune toward target bands. If telemetry shows `ARR < 0.70`, the mystery is dying. Fix the data, not the script.

### 1.3 Anti-Laziness & Sustainable Craft
Automation replaces drudgery, not thought. Horror$Place enforces effort at the data layer:
- You cannot drop a boss into a `CIC 0.20` zone.
- You cannot spawn a jump scare without an `LSG` threshold transition.
- You cannot ignore `DET` decay and exhaust your players.
This is not restrictive; it is protective. It prevents burnout by providing sane defaults, validates choices early, and guarantees atmosphere scales with ambition.

---

## 2. Alignment with Deep Game Philosophy
We recognize and align with the principles pioneered by studios like Ice-Pick Lodge:
- **Intentional Discomfort:** Players are most engaged when stakes are unclear but consequences are real.
- **No Hand-Holding:** Navigation relies on landmarks, intuition, and spectral pressure (`HVF`), not waypoints.
- **Player as Co-Author:** Evidence is presented; interpretation is left to the player. The system never confirms "ghosts are real," only that the weight of history is.

---

## 3. AI & Contributor Rules

### 3.1 Schema-First Workflow
1. Define/extend schema (`core/schemas/`).
2. Author contract (`moods/`, `contracts/`).
3. Lint (`ajv`, `mood_lint.lua`).
4. Implement (Lua/C++).
**Never reverse this order.** AI agents must follow this sequence. Hallucinated keys or hardcoded values will be rejected by CI.

### 3.2 The "No Raw Content" Policy
This repository contains the **tools and logic** for horror, not the horror itself.
- ❌ Do not generate gore, slurs, or explicit narrative text.
- ✅ Do generate systems that enable dread: `"cic_0.85"`, `"archival_gap_1944"`, `"liminal_transition"`.
- ✅ Do generate parameterized templates that artists/writers can instantiate within realism bounds.

### 3.3 Historical Attribution as Ground Truth
Use the 10 canonical invariants as research hooks:
- `CIC`, `MDI`, `AOS`, `LSG`, `SPR`
- `RRM`, `FCF`, `RWF`, `DET`, `HVF`
Every asset, event, and AI behavior must reference at least one. If it cannot, it does not belong.

---

## 4. The Realism Threshold (RT)
A hard cap preventing fantastical drift. If an element cannot be traced to a plausible biological, historical, or psychological root, the system rejects it.
- High `RWF` + High `CIC` = Canon history (systemic enemies, core plot).
- Low `RWF` + High `MDI` = Unreliable rumor (audio anomalies, side quests).
- Mismatched `SPR` = Asset rejected or scaled to `Veracity-Variance (VV)` bounds.

---

## 5. Enforcement & Evolution
- **CI Gates:** Schema validation, Lua hook verification, invariant bound checks.
- **Telemetry Loops:** Live session metrics must remain within contract bands. Deviations trigger alerts, not patches.
- **Versioning:** Semantic. Breaking invariant definitions = Major. New moods/metrics = Minor. Docs/fixes = Patch.
- **Backwards Compatibility:** Deprecated hooks/invariants warn for one minor version before removal.

---

*This doctrine is living. Propose amendments via RFC. Implement with tests. Merge with CI passing. Seal with telemetry.*  
*© 2026 Horror$Place Consortium. All rights reserved.*
