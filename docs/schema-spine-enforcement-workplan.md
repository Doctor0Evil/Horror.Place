---
title: "Schema-Spine Enforcement Workplan"
version: 1.0.0
status: "Phase 4 — Drift Remediation"
invariants_used:
  - CIC
  - MDI
  - AOS
  - RRM
  - FCF
  - SPR
  - RWF
  - DET
  - HVF
  - LSG
  - SHCI
metrics_used:
  - UEC
  - EMD
  - STCI
  - CDL
  - ARR
tiers:
  - standard
  - mature
  - research
deadledger_surfaces:
  - bundleattestation
  - agentattestation
  - spectralseedattestation
  - bcistateproof
---

# Schema-Spine Enforcement Workplan

This document defines a concrete, GitHub-native workplan for enforcing Horror.Place as the schema spine of the VM-constellation and for remediating schema and protocol drift across Tier 1–3 repositories during Phase 4 (Weeks 8–10).

It focuses on two immediate gaps:

- Missing `deadledgerref` in Tier 1 registries for regions, events, personas, and styles.
- Mixed JSON Schema draft usage for core schemas, beginning with `schemas/invariants_v1.json`.

The goal is to make all artifacts in the constellation mechanically traceable from Tier 1 registries through Dead-Ledger attestations to vault and lab implementations, under a single, coherent schema regime.

---

## 1. Objectives and Scope

The schema spine is the combination of:

- Core JSON Schemas in Horror.Place (invariants, entertainment metrics, style contracts, event contracts, persona contracts, agent artifacts, telemetry, and registry shapes).
- NDJSON/JSON registries in Horror.Place (`registry/regions.json`, `events.json`, `personas.json`, `styles.json`, and related indexes).
- Dead-Ledger-Network schemas and protocol documents that define proof envelopes, verifiers, and ledger entries for bundles, agents, and spectral seeds.
- Orchestrator validation and promotion flows that use those schemas to admit or reject artifacts.

Phase 4 work has three high-level objectives:

1. Make the relationship between Tier 1 registries and Dead-Ledger attestations explicit and machine-enforced via a new `deadledgerref` field on all registry entries.
2. Harmonize JSON Schema drafts and `$id` URIs for core schemas, starting with `schemas/invariants_v1.json`, so that all tooling uses a consistent draft and canonical identifiers.
3. Introduce cross-repo validation and CI patterns that prevent future drift, especially between Horror.Place schemas and vault/lab implementations.

This document describes the tasks, migration steps, and safety checks needed to achieve these objectives.

---

## 2. Design Principles

The workplan follows existing doctrinal constraints:

- Tier 1 is schema and registry only: no raw content, only opaque paths, hashes, and IDs.
- Tier 2 and Tier 3 implement content and behavior but must serialize to Tier 1 schemas.
- Dead-Ledger acts as the cryptographic authority; every production-eligible artifact must have a ledger-backed attestation reachable via a stable reference.
- Invariants and entertainment metrics are the primary numeric axes for design and safety: all schema and registry changes must preserve their integrity and ranges.
- Changes for Phase 4 are primarily additive and validation-tightening: they should not break existing behavior unless the existing behavior violates the blueprint.

The schema spine is treated as law: all repositories must read it and align to it, not redefine it.

---

## 3. Workstream A — `deadledgerref` in Tier 1 Registries

### 3.1. Rationale

Dead-Ledger defines ledger entries and proof envelopes for:

- Invariant bundles and regional histories (bundle attestations).
- Agents and personas (agent attestations).
- Spectral and BCI seeds (spectral seed attestations and bcistate proofs).

Tier 2 and Tier 3 repos already plan to embed opaque ledger references in their own JSON files, but Tier 1 registries currently have no field tying registry entries to ledger entries.

Without a registry-level `deadledgerref`:

- A region, event, persona, or style might appear valid in Tier 1 while lacking any on-ledger attestation.
- Orchestrator cannot easily check whether an artifact is covered by a ledger entry and appropriate proofs.
- AI tooling cannot see which registry entries are fully governed by the trust fabric.

Adding `deadledgerref` to Tier 1 registries makes Dead-Ledger part of the public contract surface and allows automated enforcement.

### 3.2. Target Registries and Field Shape

The following files must gain a `deadledgerref` field per entry:

- `registry/regions.json`
- `registry/events.json`
- `registry/personas.json`
- `registry/styles.json`

Conceptual shape for a region entry:

```json
{
  "aral_sea_basin": {
    "path": "git@github.com:Doctor0Evil/HorrorPlace-Atrocity-Seeds.git#regions/basin_of_silence_v1.json",
    "invariant_bundle": "git@github.com:Doctor0Evil/HorrorPlace-Black-Archivum.git#contracts/invariant_bundles/invariant_bundle_aral_sea_v1.json",
    "story_spine_seeds": ["aral_sea_dissolution_01"],
    "hash": "sha256:example_hash_for_basin_of_silence_region_contract",
    "tier": "mature",
    "deadledgerref": {
      "proof_envelope_id": "dlr:aral_sea_basin:charter:v1",
      "verifier_ref": "verifiers.json#charter-agreement-verifier-prod",
      "circuit_type": "zkp-charteragreementcircuitv1",
      "required_proofs": ["age_gating", "charter_agreement"]
    }
  }
}
```

Event, persona, and style entries follow the same pattern:

- `proof_envelope_id`: Stable identifier for the ledger-side proof envelope set associated with this registry entry (e.g., age and charter proofs for access to this artifact).
- `verifier_ref`: Pointer into Dead-Ledger’s `registry/verifiers.json` for the primary verifier contract or circuit to use.
- `circuit_type`: Name of the verifier circuit class relevant to this registry entry (e.g., `zkpagegatingcircuitv1`, `zkpcharteragreementcircuitv1`, `bcistateprofilev1`).
- `required_proofs`: List of proof types that must be present and valid (e.g., `["age_gating", "charter_agreement"]`, `["age_gating", "charter_agreement", "aln_membership"]`, or including `bcistate` for BCI-bound artifacts).

### 3.3. Safety and Compatibility

- The change is additive: existing fields remain unchanged.
- Existing consumers that ignore `deadledgerref` continue to function as before.
- New validation paths in Orchestrator and Dead-Ledger can be rolled out incrementally, starting with warnings and progressing to hard failures for production tiers.

### 3.4. Tasks

A1. **Schema Updates in Horror.Place**

- Create or update JSON Schemas for Tier 1 registries, for example:
  - `schemas/registry_regions_v1.json`
  - `schemas/registry_events_v1.json`
  - `schemas/registry_personas_v1.json`
  - `schemas/registry_styles_v1.json`
- Each schema must:
  - Define the `deadledgerref` object with the fields listed above.
  - Require `deadledgerref` for artifacts in `tier` values that correspond to mature and research; optionally allow it to be absent for purely standard-tier entries during migration.
  - Enforce that `required_proofs` is a non-empty array of strings.

A2. **Registry File Patches**

- Add `deadledgerref` to all existing entries in:
  - `registry/regions.json`
  - `registry/events.json`
  - `registry/personas.json`
  - `registry/styles.json`
- For legacy content or examples where no Dead-Ledger attestation exists yet, temporarily set:
  - `deadledgerref: null` or a clearly marked placeholder object.
- Track such placeholders in a migration checklist for later replacement with real ledger refs.

A3. **Orchestrator Linter and Promotion Logic**

- Update the Orchestrator’s registry validation module to:
  - Load updated registry schemas from Horror.Place.
  - Validate registry files, including `deadledgerref` shapes.
  - Confirm that `verifier_ref` points to an existing entry in Dead-Ledger’s `registry/verifiers.json` for production builds.
- Update promotion workflows so that:
  - Any artifact promoted into a registry with `tier` ≥ `mature` must carry a non-null `deadledgerref`.
  - Promotion pipelines fail if `deadledgerref` is missing, malformed, or references a non-existent or inactive verifier.

A4. **Dead-Ledger Protocol Documentation**

- Amend the Dead-Ledger protocol document to explicitly state:
  - Tier 1 registries are required to carry `deadledgerref` for any artifact that depends on ledger-governed entitlement.
  - `proof_envelope_id` is the canonical link between registry entries and ledger proof sets.
  - `verifier_ref` must reference an active verifier entry.
  - Runtime clients should treat registry-level `deadledgerref` as the starting point for building entitlement requests.

A5. **CI and Migration Checks**

- Introduce new CI checks in Horror.Place:
  - Validate registry files against their updated schemas on every push.
  - Optionally maintain a “migration report” that lists entries missing `deadledgerref` or using placeholders.
- Introduce optional CI or periodic jobs in Dead-Ledger to:
  - Scan Tier 1 registries (via raw URLs) and ensure that any non-null `deadledgerref` resolves to a known ledger entry or verifier.

---

## 4. Workstream B — JSON Schema Draft Harmonization

### 4.1. Rationale

Core schemas in Horror.Place currently mix JSON Schema drafts (e.g., draft-07 and draft-2020-12). Entertainment metrics and some newer schemas already use draft-2020-12 with proper `$id` URIs, while others, such as `schemas/invariants_v1.json`, are on draft-07.

This mix complicates:

- Validator configuration in CI and Orchestrator.
- Cross-repo tooling that expects a single draft and canonical `$id` layout.
- Schema evolution, versioning, and reuse via `$ref`.

Harmonizing on JSON Schema draft-2020-12 improves consistency and makes it easier to expose schemas via stable URLs for external tools.

### 4.2. Target Schema: `schemas/invariants_v1.json`

Planned changes:

- Update the meta-schema reference:
  - From: `"$schema": "http://json-schema.org/draft-07/schema#"`
  - To: `"$schema": "https://json-schema.org/draft/2020-12/schema"`
- Add a canonical `$id`:
  - `"$id": "https://horrorplace.org/schemas/invariants_v1.json"`

No other structural changes are required for this phase, as long as invariants_v1 does not depend on features whose semantics changed between drafts.

### 4.3. Draft Differences and Risk Analysis

Relevant draft-2020-12 points:

- `prefixItems` is used for tuple schemas; `items` is used for list-like collections. If `invariants_v1.json` only uses `items` with simple schemas (no tuples), no change is required.
- `definitions` has been superseded by `$defs`, but existing draft-07-style `definitions` usage can continue as long as the meta-schema and validator support it. If desired, a later phase can refactor `definitions` to `$defs` explicitly.
- `additionalProperties: false` semantics remain the same. Existing “no extra fields” constraints will behave identically.

The main risk is validator compatibility:

- Any usage of the Python `jsonschema` library must be on a version that supports draft-2020-12 (for example, v4.18 or higher).
- CI pipelines and Orchestrator service components must be configured with validators that understand draft-2020-12 for all schemas that use it.

### 4.4. Tasks

B1. **Schema Update in Horror.Place**

- Edit `schemas/invariants_v1.json` to:
  - Set the `$schema` to the 2020-12 URL.
  - Add a canonical `$id` matching the URL used in other docs and references.
- Confirm that internal `$ref` usage is compatible under draft-2020-12:
  - Prefer absolute or `$id`-relative references where possible.
  - Avoid ambiguous relative paths.

B2. **Validator Configuration in CI and Orchestrator**

- Update Horror.Place CI pipelines to:
  - Use a JSON Schema validator engine that supports draft-2020-12 for all schemas with that meta-schema.
  - Explicitly configure the validator to respect `$id` and resolve references relative to that URI.
- Update the Orchestrator’s schema validation code:
  - Ensure the validator instance supports draft-2020-12.
  - Implement a registry of schema URIs and local paths so that `invariants_v1.json` and related schemas are loaded consistently.

B3. **Full Sweep of Invariant Bundles**

- Enumerate all invariant bundles in:
  - Black-Archivum and any other repos that serialize invariant bundles.
- Run a full validation sweep:
  - Validate each bundle JSON against the updated `schemas/invariants_v1.json`.
  - Record any failures and categorize:
    - Bundles that rely on now-invalid fields or types.
    - Bundles with extraneous fields caught by `additionalProperties: false`.
- Resolve failures by:
  - Updating the bundles to comply with the schema.
  - Or, if a schema issue is discovered, adjusting invariants_v1 in a controlled way, with explicit change notes.

B4. **Documentation and Versioning**

- Update Horror.Place documentation to:
  - Note that invariants, metrics, styles, events, and personas share a consistent schema draft (2020-12).
  - Provide a table mapping schema filenames to their `$id` URIs.
- Consider incrementing a minor version number of the invariants schema if any structural changes beyond `$schema`/`$id` are necessary.

---

## 5. Workstream C — Cross-Repo Drift Detection and Prevention

### 5.1. Rationale

Phase 4’s goal is not only to fix current drift but also to prevent future drift between:

- Horror.Place schemas and registries.
- Dead-Ledger proof schemas and verifier registries.
- Vault and lab implementations of invariant bundles, events, personas, styles, and telemetry.

To do this, we need standardized patterns for schema validation, registry checking, and Dead-Ledger linkage across all 12 repos.

### 5.2. Standard CI Patterns

For each repo category:

1. **Tier 1 (Horror.Place, Orchestrator)**

   - Validate all JSON/NDJSON against the latest schemas in Horror.Place.
   - Check that all `deadledgerref` fields in registries:
     - Match the local registry schemas.
     - Refer to existing and active entries in Dead-Ledger’s verifier registry.
   - Run a draft-2020-12-compatible validator for all core schemas that declare that draft.

2. **Tier 2 Vaults (Codebase-of-Death, Black-Archivum, Spectral-Foundry, Atrocity-Seeds, Obscura-Nexus, Liminal-Continuum)**

   - Fetch relevant schemas from Horror.Place and Dead-Ledger via canonical URIs.
   - Validate all exported bundles, agent artifacts, seeds, and style/event contracts against those schemas.
   - For any artifact intended for promotion:
     - Require a `deadledgerref` placeholder or full reference in the vault’s own registry or descriptor.
     - Run a dry-run check that the corresponding Tier 1 registry entry can accept a matching `deadledgerref`.

3. **Tier 3 Labs (Process-Gods-Research, Redacted-Chronicles, Neural-Resonance-Lab, Dead-Ledger-Network)**

   - For Dead-Ledger:
     - Validate all proof envelopes and ledger entries against its own schemas and protocol docs.
     - Periodically scan Tier 1 registries to ensure references remain consistent.
   - For telemetry labs:
     - Validate telemetry summary schemas against Horror.Place entertainment metrics and any telemetry-specific schemas.
     - Confirm that any references to agent IDs, event IDs, or region IDs match values present in Tier 1 registries.

### 5.3. Drift Reporting

Introduce a common reporting pattern:

- Each repo CI run produces a small JSON or Markdown drift report that summarizes:
  - Schema validation errors.
  - Missing or placeholder `deadledgerref` values for artifacts that should be ledger-governed.
  - Cross-repo ID mismatches (e.g., registry entries that reference non-existent bundles or agents).
- Horror.Place maintains a top-level drift dashboard document that:
  - Aggregates these reports.
  - Prioritizes remediation tasks based on safety impact (e.g., incorrect entitlement vs purely cosmetic drift).

---

## 6. Workstream D — Safety Impact and Rollout Strategy

### 6.1. Safety Classification

For Phase 4 changes:

- Adding `deadledgerref` to Tier 1 registries:
  - Impact: Low direct runtime risk (additive, optional at first).
  - Benefit: High for auditability and entitlement enforcement.
- Migrating `schemas/invariants_v1.json` to draft-2020-12:
  - Impact: Medium; validator behavior changes must be tested across all invariant bundles.
  - Benefit: High; consistent schema draft and `$id` usage improves tool interoperability and reduces long-term risk.

### 6.2. Rollout Plan

1. Phase 4 Week 8:
   - Implement schema changes for registries and `invariants_v1`.
   - Update CI validators where necessary.
   - Run initial validation sweeps, generate drift reports.

2. Phase 4 Week 9:
   - Patch Tier 1 registries to add `deadledgerref` for all known production entries.
   - Coordinate with Dead-Ledger to ensure verifier registry contains entries referenced in `verifier_ref`.
   - Address invariant bundle validation failures in Black-Archivum and other vaults.

3. Phase 4 Week 10:
   - Turn on stricter CI enforcement:
     - Fail builds if new production-tier registry entries lack `deadledgerref`.
     - Fail builds if invariant bundles fail validation under draft-2020-12.
   - Publish a revised schema and registry reference doc in Horror.Place, describing the new fields and schema drafts.

---

## 7. Summary of Expected Outcomes

By the end of Phase 4:

- All Tier 1 registry entries for regions, events, personas, and styles will be capable of carrying a `deadledgerref` linking them to Dead-Ledger attestations and proof sets.
- `schemas/invariants_v1.json` will be aligned with JSON Schema draft-2020-12 and a canonical `$id`, matching patterns already used by entertainment metrics and other core schemas.
- CI pipelines in Horror.Place, Orchestrator, Dead-Ledger, and key vaults will enforce schema compliance, registry correctness, and ledger linkage, reducing schema and protocol drift.
- The schema spine will be more robust, transparent, and easier to extend, supporting later phases that introduce new proof types, spectral seeds, and BCI-aware policies without compromising safety or consistency.
