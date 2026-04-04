# Horror.Place — Copilot Task Overview

## 1. What Horror.Place Is

Horror.Place is the public, schema‑first rules engine for the Horror$Place ecosystem. It contains no raw horror content. Instead, it defines JSON Schemas, NDJSON registries, Lua/Rust APIs, and audit docs that all underground repositories must obey. Horror here is data and contracts: historical invariants, entertainment metrics, style rules, and entitlement policies.

The public repo must always remain GitHub‑safe: only opaque IDs, contracts, and specs. All explicit content and sensitive data live in private Tier‑2/3 vaults, referenced only by IDs and cryptographic hashes.

---

## 2. Core Concepts Copilot Must Respect

Horror.Place encodes three main pillars:

1. **Historical invariants (H.):**  
   Each region/tile/POI is modeled as numeric invariants such as CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI. These values drive when, where, and how horror can manifest. All systems query these invariants via a narrow `H.` API (usually Lua stubs in `public-api/` or `engine/`).

2. **Entertainment metrics:**  
   Fear is treated as measurable experience, not vibes. Metrics like UEC, EMD, STCI, CDL, ARR define how uncertain, mysterious, or resolved an experience feels. Content, events, and scenes must be designed so metrics stay within safe but engaging bands (for example, high UEC and ARR for “good mystery”).

3. **Charter and safety doctrine:**  
   The Rivers of Blood Charter forbids explicit depiction of horror in public spaces and demands implication‑driven, historically grounded design. Every system must be able to show its chain of evidence back to invariants and metrics. Public files must never contain explicit descriptions, raw media, or policy‑violating text.

---

## 3. Repo Structure (What Copilot Will See)

Typical layout (exact paths may vary per version):

- `core/schemas/` – Versioned JSON Schemas for invariants, metrics, styles, events, personas.  
- `core/registry/` – NDJSON registries (events, regions, styles, personas) with one JSON object per line and only opaque IDs/refs.  
- `core/api/` – OpenAPI spec describing public Horror.Place API endpoints.  
- `public-api/` – Lua stubs such as `H.CIC(region_id)` or `H.resolve_event_spec(event_id)`.  
- `docs/` – ADRs, blueprints, charter docs, contributing guides, audit plans.  
- `audit/` – Audit playbooks and acceptance tests detailing how to validate contracts and registries.  
- `scripts/` – Validation and leak‑test utilities (schema validation, NDJSON format checks, raw‑content scanners).

Copilot must treat these directories as contract surfaces, not arbitrary code folders.

---

## 4. VM‑Constellation and Tiers

Horror.Place is Tier 1 in a three‑tier VM‑constellation:

- **Tier 1 (Core / public):** Horror.Place. Publishes schemas, metrics, invariant APIs, style contracts, and public doctrine. No raw content.  
- **Tier 2 (Vault / private):** Underground repos (e.g., Atrocity‑Seeds, Black‑Archivum) hold sensitive content, full AI personas, PCG seeds, and historical trauma archives. They reference public schemas and IDs but are not directly visible on GitHub.  
- **Tier 3 (Lab / research):** Highly restricted sandboxes for BCI/fMRI data, physiological logs, ZKP‑based gating, and experimental agents.

Copilot must assume that any “real content” is elsewhere and represented here only through IDs, hashes, and schema‑conformant descriptors.

---

## 5. Invariants → Lua Logic → Engine Behavior

All horror‑relevant behavior follows this pattern:

1. **Query history layer:**  
   Lua or engine scripts call `H.*` helpers (e.g., `H.CIC(region_id)`) to read invariants like CIC, AOS, RRM, HVF, LSG, SHCI.

2. **Derive behavior from invariants:**  
   AI behavior trees, PCG rules, audio logic, and pacing systems must set their behavior based on the invariants and entertainment metrics, not arbitrary randomness. For example:
   - High CIC + high RRM → strong ritual echo potential.  
   - High AOS + high SPR → ambiguous, glitch‑like manifestations only.  
   - LSG spikes at thresholds → liminal events near doors, bridges, borders.  

3. **Respect metrics targets:**  
   Before scheduling events or generating contracts, systems must check desired changes in UEC, EMD, STCI, CDL, ARR. The goal is to keep experiences tense but not overwhelming, and to avoid instant resolution of mysteries.

4. **Log for telemetry:**  
   Every meaningful change (new event contract, metric jump, invariant query pattern) should be loggable and auditable for later tuning.

---

## 6. What the Copilot Task Needs Copilot To Do

The existing Task asks Copilot to:

- Continuously scan Horror.Place and connected constellation repos for **schema drift** against core invariants/metrics/style specs.  
- Generate **daily markdown compliance reports** describing where files or registries diverge from published schemas and doctrine.  
- Propose **Git patches** that restore alignment without adding any raw horror content.  
- Flag any potential violations of public‑repo rules (explicit text, media, unsafe descriptions) for manual review, never auto‑merge.

This overview gives Copilot the context to interpret diffs and schema changes correctly: it should always prefer tightening contracts, reinforcing invariants and metrics, and maintaining public‑safe implication over adding content.

---

## 7. Guardrails for Copilot

When operating on Horror.Place:

- **Never** introduce explicit horror content, graphic description, or unsafe examples. Use placeholders, opaque IDs, or highly abstract language instead.  
- **Always** ensure new or modified files validate against the relevant JSON Schemas in `core/schemas/`.  
- **Always** keep registries NDJSON, one object per line, no inline assets, no base64, no URLs to sensitive media.  
- **Never** invent new invariant or metric names arbitrarily; reuse CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI, UEC, EMD, STCI, CDL, ARR unless a new schema explicitly defines an extension.  
- **Prefer** small, contract‑tightening changes over broad refactors, unless schemas and ADRs explicitly require refactoring.  
- **Defer** to existing ADRs, charter docs, and schemas whenever there is a conflict between style and safety.

With this overview, Copilot should be able to stay on‑task: enforcing the Horror.Place contract spine, preserving safety, and keeping the VM‑constellation coherent over time.
