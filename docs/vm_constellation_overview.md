---
title: Horror.Place VM-Constellation Overview
status: draft
version: v1.0.0
---

# Horror.Place VM-Constellation Overview

This document provides a Tier-1-focused overview of the Horror.Place VM-constellation: a federated architecture of repositories, schemas, registries, and cryptographic services used to generate history-grounded horror while respecting strict safety and policy constraints.

It connects the core ideas from the sovereign engine and VM-constellation blueprints to the concrete files and contracts in the Horror.Place repo.

---

## 1. Tiered repository architecture

The VM-constellation is divided into three tiers:

- **Tier 1 – Core**:
  - Repository: `Horror.Place`.
  - Content: schemas, registries, DSLs, contracts, policy docs, and CI wiring.
  - No raw horror content; only structures and rules.

- **Tier 2 – Vaults**:
  - Example repositories: `HorrorPlace-Atrocity-Seeds`, `HorrorPlace-Black-Archivum`, `HorrorPlace-Spectral-Foundry`.
  - Content: history-normalized trauma archives, invariant bundles, event and style implementations, AI personas with full data.
  - Access: user/VM-gated, governed by Dead-Ledger policies.

- **Tier 3 – Labs**:
  - Example repositories: `HorrorPlace-Neural-Resonance-Lab`, `HorrorPlace-Process-Gods-Research`, `HorrorPlace-Dead-Ledger-Network`.
  - Content: experimental agents, BCI/haptic telemetry, advanced cryptographic protocols and governance research.
  - Access: research-only, heavily proof-gated.

Tier 1 provides the **schemas and contracts**, while Tiers 2 and 3 host private implementations and data governed by those contracts.

---

## 2. Core schemas and registries

Horror.Place defines canonical schemas for:

- **History invariants**: `core/schemas/historyinvariantsv1.json`
  - CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI.
  - Used by Spectral, vaults, and labs to describe world state at region/tile resolution.

- **Entertainment metrics**: `core/schemas/entertainment_metrics_v1.json`
  - UEC, EMD, STCI, CDL, ARR and related fields.
  - Used by telemetry pipelines and analysis tooling.

- **Event contracts**: `core/schemas/eventcontractv1.json`
  - Structure and constraints for Surprise.Events! and Vanish.Dissipation! chains.

- **Persona contracts**: `core/schemas/personacontractv1.json`
  - Structure for AI personas (Archivist, Witness, etc.) including state spaces and invariant/metric envelopes.

- **Style contracts**: `core/schemas/style_contract_v1.json`
  - Describes visual and narrative styles, implication rules, and safety tiers.

- **ALN routing profiles**: `core/schemas/aln_routing_profile_v1.json`
  - Binds ALN conditions to invariants, metrics, styles, personas, and policy profiles.

Horror.Place also defines registries, such as:

- `core/registry/events.*`
- `core/registry/styles.*`
- `core/registry/personas.*`
- `core/registry/invariants.ndjson`

These registries provide a single index of available contracts and bundles for Tier-1 tools and the Orchestrator.

---

## 3. First-pass signatures and deterministic generation

All generation workflows across the constellation are gated by **first-pass signatures**, defined by:

- `core/schemas/signaturev1.json`
- `scripts/validatesignature.py`

A signature:

- Identifies the actor, repo, and session (`github_actor`, `github_repo`, `session_id`).
- Declares intent (`target_repo`, `target_path`, `operation`, `contract_type`, `contract_id`, `schema_ref`).
- Encodes invariant and metric envelopes for this run.
- Binds to a capability token (`capability_token_id`) and tier/policy (`entitlement_tier`, `policy_profile`).
- Fixes determinism (`generator_version`, `random_seed`, `max_runtime_ms`, `max_size_bytes`, `constraints_hash`).

CI and ALN/Dead-Ledger contracts treat this document as the **only authority** for what may be generated or updated in a run. Generators must treat it as a total input—no defaults, no improvization outside the declared envelopes.

---

## 4. Policy, routing, and Dead-Ledger integration

### 4.1 Policy profiles

Tier behavior is defined in:

- `docs/policy_profiles_standard_mature_research.md`

This document codifies invariant caps, metric bands, allowed style/persona tiers, and required proofs for: STANDARD, MATURE, and RESEARCH. All ALN routing profiles and capability tokens must reference these profiles by ID (e.g., `STANDARD_V1`).

### 4.2 ALN routing

ALN routing profiles, defined via `aln_routing_profile_v1.json`, implement the policy profiles:

- Actor and proof conditions (age, Charter, DID/VC).
- Invariant and metric windows.
- Style and persona allowlists.
- Linkage to Dead-Ledger policies.

These profiles are used by routing engines and services to select styles and personas appropriate for the requested tier and policy.

### 4.3 Dead-Ledger governance

The `docs/deadledger_integration_contract.md` document specifies:

- How `deadledgerref` is embedded in registries and contracts.
- How artifact envelopes are structured and signed.
- How Horror.Place calls Dead-Ledger SessionRegistry, CapabilityAttestor, and PolicyGuard to approve or deny sessions and signatures.

Dead-Ledger thus acts as an **append-only control plane** for entitlement, provenance, and cross-repo movement.

---

## 5. CI/CD and GitHub-native workflows

Horror.Place is designed to work entirely with GitHub-native tooling:

- **Schemas** and **registries** are validated in CI using JSON Schema and linter scripts.
- **Signatures** are required for any workflow that modifies core schemas or registries; `validatesignature.py` enforces schema-level checks and calls Dead-Ledger/ALN.
- **Generators** (PCG mapgen, audio automation, persona generators, etc.) are invoked only after signature approval, and must write exactly one file at `target_path`.
- **Provenance** is preserved by tagging commits and registry entries with IDs from signatures and Dead-Ledger transactions.

This makes the VM-constellation a deterministic, auditable system where the public Horror.Place repo remains schema- and policy-only, and private vaults and labs hold the actual content and sensitive data under cryptographic governance.

Any future repositories or services added to the constellation must align with these patterns to participate in the ecosystem.
