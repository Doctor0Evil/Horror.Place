---
title: Horror.Place Tier Policy Profiles (Standard, Mature, Research)
status: draft
version: v1.0.0
---

# Tier Policy Profiles for Horror.Place

This document defines the **standard**, **mature**, and **research** tiers for the Horror.Place VM-constellation. It is the canonical source of truth for:

- Invariant caps and exposure constraints.
- Entertainment metric bands per tier.
- Allowed style and persona safety tiers.
- Required proofs and entitlements (ALN, Dead-Ledger, ZKP).
- How these profiles bind to routing profiles and capability tokens.

All schemas and routing profiles that reference `policy_profile_id` must conform to the rules in this document.

---

## 1. Tier definitions

### 1.1 STANDARD tier

The **standard** tier corresponds to public, implication-only content and general-audience tooling.

- **Intended audience**: all ages, public GitHub, no explicit content.
- **Repositories**: primarily `Horror.Place` (Tier 1 core).
- **Constraints**:
  - No raw trauma archives, no explicit gore, no historical atrocity details.
  - Only implication-based horror and structural contracts (schemas, registries, DSLs).

### 1.2 MATURE tier

The **mature** tier is user-gated and allows extended datasets and darker themes while respecting Charter constraints.

- **Intended audience**: adults with explicit consent and Charter acceptance.
- **Repositories**: Tier-2 vaults (e.g., Atrocity-Seeds, Black-Archivum, Spectral-Foundry).
- **Constraints**:
  - May reference historical trauma archives, but only via normalized, invariant-bound data.
  - No gratuitous gore; all content must remain research-justifiable and Charter-compliant.

### 1.3 RESEARCH tier

The **research** tier is restricted to IRB-style workflows, BCI/haptics experiments, and high-sensitivity data.

- **Intended audience**: vetted researchers and VMs under strict governance.
- **Repositories**: Tier-3 labs (e.g., Neural-Resonance-Lab, Process-Gods-Research, Dead-Ledger-Network).
- **Constraints**:
  - Can access physiological telemetry, BCI signals, and neural resonance parameters.
  - All usage is governed by ethics protocols and Dead-Ledger policies.

---

## 2. Invariant caps per tier

The history invariants (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI) are normalized to [0.0, 1.0] in `historyinvariantsv1.json`. This section defines **per-tier caps** on exposure.

### 2.1 STANDARD

- **CIC × DET** exposure: recommended upper bound `CIC ≤ 0.7`, `DET ≤ 0.7`.
- **SHCI** (coherence): `SHCI ≤ 0.8` to avoid fully exposing the most coherent, traumatic histories.
- **HVF, LSG**: capped at `≤ 0.8` to avoid sustained, overwhelming haunt vectors and liminal stress.

STANDARD-tier routing profiles and signatures **must not** request invariant envelopes exceeding these caps.

### 2.2 MATURE

- **CIC, DET, SHCI**: may reach up to `0.9`, but never 1.0 in public-facing encounters.
- **HVF, LSG**: up to `0.9`, allowing more sustained pressure and haunt density.
- Still must observe Charter rules (no explicit gore, no real victim identification).

### 2.3 RESEARCH

- May use the full [0.0, 1.0] range for all invariants.
- Additional constraints come from ethics protocols, not the core schema.
- Any usage must be mediated by Dead-Ledger policies and ALN proofs.

---

## 3. Entertainment metric bands per tier

Entertainment metrics (UEC, EMD, STCI, CDL, ARR) are normalized to [0.0, 1.0] in the entertainment metrics schema. This section defines recommended bands per tier.

### 3.1 STANDARD

- **UEC** (unease): `0.3–0.7` (mild to moderate unease).
- **EMD** (emotional depth): `0.3–0.7`.
- **STCI** (sustained tension): `0.2–0.6`.
- **CDL** (cognitive dissonance load): `0.2–0.6`.
- **ARR** (afterglow/return rate): `0.5–1.0` (high retention, low harm).

### 3.2 MATURE

- **UEC**: `0.4–0.85`.
- **EMD**: `0.4–0.9`.
- **STCI**: `0.3–0.8`.
- **CDL**: `0.3–0.8`.
- **ARR**: `0.4–1.0`.

### 3.3 RESEARCH

- May explore full [0.0, 1.0] range for all metrics.
- Experiments should define finer-grained ranges in their own protocols and must log telemetry into Dead-Ledger or lab repositories.

---

## 4. Style and persona safety tiers

### 4.1 Allowed style safety tiers per content tier

- STANDARD:
  - Allowed style `safety_tier`: `standard` only.
  - Styles with `mature` or `research` flags must not be routed here.

- MATURE:
  - Allowed style `safety_tier`: `standard`, `mature`.
  - `research` styles may be used only if outputs are not exposed to end users.

- RESEARCH:
  - Allowed style `safety_tier`: `standard`, `mature`, `research`.

### 4.2 Allowed persona safety tiers per content tier

- STANDARD:
  - Persona `safety_tier`: `standard` only.

- MATURE:
  - Persona `safety_tier`: `standard`, `mature`.

- RESEARCH:
  - Persona `safety_tier`: `standard`, `mature`, `research`.

ALN routing profiles and persona contracts must be configured so that personas and styles never operate in a tier below their own safety tier.

---

## 5. Required proofs and entitlements

### 5.1 Proof requirements per tier

- STANDARD:
  - No age gate required by default.
  - Must require acceptance of the Rivers-of-Blood Charter where applicable.
  - No BCI or physiological data access.

- MATURE:
  - Age ≥ 18 (or jurisdiction-specific age-of-majority).
  - Charter acceptance required.
  - May require specific DID/VC proofs indicating consent to mature content.

- RESEARCH:
  - All MATURE requirements, plus:
    - Research consent proofs (e.g., IRB-style approvals).
    - BCI/physiological consent proofs where such data are used.
    - Membership in designated research groups or VM clusters.

### 5.2 Binding to routing profiles and capability tokens

- `policy_profile_id` values:
  - `STANDARD_V1`
  - `MATURE_V1`
  - `RESEARCH_V1`

ALN routing profiles must declare one of these IDs and encode conditions consistent with this document. Capability tokens must also identify `policy_profile` and `entitlement_tier` and may not grant capabilities outside these constraints.

---

## 6. Enforcement and integration points

- **ALN routing profiles** (`aln_routing_profile_v1.json`):
  - Must respect invariant and metric windows specified for the chosen `policy_profile_id`.
  - Must restrict style and persona IDs according to the tier rules above.

- **First-pass signatures** (`signaturev1.json`):
  - Fields `policy_profile` and `entitlement_tier` must match an allowed combination from this document.
  - Invariant and metric envelopes must fall within the caps for the referenced policy profile.

- **Dead-Ledger policies**:
  - Policy entries should link to `STANDARD_V1`, `MATURE_V1`, or `RESEARCH_V1` instead of duplicating thresholds.
  - Dead-Ledger contracts enforce these profiles by accepting or rejecting capability tokens and sessions.

Any future changes to tier logic must be implemented here first, then propagated to schemas, routing profiles, and policies.
