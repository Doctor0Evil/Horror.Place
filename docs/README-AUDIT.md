---
invariants_used: [CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI]
metrics_used: [UEC, EMD, STCI, CDL, ARR]
tiers: [standard, mature, research]
deadledger_surface: [zkpproof_schema, verifiers_registry, bundle_attestation, agent_attestation, spectralseed_attestation, bcistate_proof]
---

# Horror.Place Audit Harness README

This document describes how to run the read-only audit harness for Horror.Place and its VM-Constellation, and how that harness interacts with the ALN parser, routing engine, orchestrator, and Dead-Ledger / ZKP envelope surfaces while strictly preserving repository and ledger constraints.

The harness is designed to be safe for Tier-1 use: it never writes to vault or lab repos, never emits proof blobs, and never touches raw content or trauma data.

## 1. What the audit harness does

The audit harness is a collection of scripts and tests that crawl the Horror.Place core repository, Orchestrator, and selected private repos via GitHub APIs or local clones, then compare their current state against the VM-Constellation blueprint and Dead-Ledger protocol.

It focuses on four surfaces: schemas and registries in Horror.Place, the ALN parser and routing engine crates, the Orchestrator’s cross-repo sync and verification modules, and the Dead-Ledger protocol files (schemas, verifiers, and ledger entry schemas) in HorrorPlace-Dead-Ledger-Network.

All checks are read-only: the harness inspects directory trees, parses JSON Schemas, validates that invariants/metrics are wired correctly, and runs dry-run test flows for Orchestrator and Dead-Ledger without mutating any registries or ledgers.

## 2. Surfaces under audit

The harness treats Horror.Place as the Schema Authority and inspects:

The harness validates core invariant and entertainment metric schemas, including `coreschemas/invariantsv1.json` and `coreschemas/entertainmentmetricsv1.json`, ensuring all eleven invariants and five metrics are present, versioned, and referenced consistently.

It also checks contract schemas for styles, events, and personas, plus public registries for events, regions, styles, and personas.

For the ALN and routing layer, the harness expects the ALN parser crate and routing engine to consume the Tier-1 schemas and routing profiles, and will flag any missing or divergent files (for example, missing `crates/horrorplace_aln/src/parser.rs` or `crates/horrorplace_core/src/routing_engine.rs`).

On the orchestration side, the harness reads Horror.Place-Orchestrator’s configuration and source files (for example, `src/verify.rs`, `src/promote.rs`, `src/api/mod.rs`, and any integration tests) to confirm that registry mutations are performed only after hash and signature verification and that all operations are idempotent and rollback-safe.

For Dead-Ledger, the harness inspects `schemas/zkp_proof_v1.json`, `registry/verifiers.json`, `docs/deadledgerprotocolv1.md`, and ledger entry schemas such as `schemas/ledger_entry_bundle_attestation_v1.json`, ensuring they follow the proof-envelope-only pattern and never embed raw BCI, trauma, or content data.

## 3. Running schema and registry audits

To run the core Tier-1 audits locally, use a Rust- and Python-capable environment with JSON Schema tooling.

From the Horror.Place root:

```bash
# 0. Move to repo root
cd Horror.Place

# 1. Quick file enumeration (read-only)
rg --hidden --glob '!node_modules' -n "schema|schemas|registry|\\.proto$" || true
git ls-files | rg "schemas|registry|docs/schemas|\\.avsc$|\\.proto$|\\.json$|\\.ya?ml$" || true

# 2. Core Rust schema/registry audit (if test exists)
cargo test -p horrorplace-core --test audit_schemas_and_registries -- --nocapture || true

# 3. Deep schema and registry audit (optional)
cargo test -p horrorplace-core --test deep_schema_audit -- --nocapture || true
```

The schema audit test should enumerate all `coreschemas/*.json` and `registry*.json` files, validate them against JSON Schema, and cross-reference invariant and metric fields to ensure all invariants and metrics are correctly typed and constrained.

It should also check for duplication or drift (for example, schemas mirrored under both `schemas/` and `coreschemas/`) and report canonical paths so tooling can treat a single location as authoritative.

## 4. ALN parser and routing engine checks

The ALN parser and routing engine form the bridge between Tier-1 contracts and downstream vault behaviors.

The harness expects:

- An ALN parser crate (for example `crates/horrorplace_aln/`) that parses `.aln` contract specifications for style and routing rules into internal Rust types aligned with the JSON schemas.
- A routing engine module (for example `crates/horrorplace_core/src/routing_engine.rs`) that consumes parsed ALN data, invariant values, and entertainment metric envelopes to produce routing decisions.

To run ALN and routing audits:

```bash
# From Horror.Place root

# 1. Run ALN parser unit tests
cargo test -p horrorplace_aln --lib -- --nocapture || true

# 2. Run routing engine tests
cargo test -p horrorplace-core routing_engine -- --nocapture || true

# 3. Run integrated ALN + routing audit (if present)
cargo test -p horrorplace-core --test aln_routing_audit -- --nocapture || true
```

The ALN audit tests should ensure that parser and engine modules treat style, event, and persona DSLs as first-class contracts and never introduce parallel, schema-less formats.

They should verify that routing decisions are always expressed in terms of invariants (CIC, AOS, SHCI, etc.) and entertainment metrics (UEC, EMD, STCI, CDL, ARR) already defined in Horror.Place, reinforcing the schema-first doctrine.

## 5. Orchestrator harness and cross-repo flow

Horror.Place-Orchestrator is the sync conductor that validates artifacts from vaults and labs, then promotes them into Tier-1 registries.

The audit harness interacts with the Orchestrator in read-only mode by:

- Exercising its REST API (typically `src/api/mod.rs`) using local mock requests that simulate vault descriptors for styles, events, agents, and invariant bundles.
- Running integration tests (for example `tests/integration_sync_test.rs`) that simulate a full promotion cycle from vault descriptor reception through verification, registry update planning, and decision logging without hitting production registries.

To run Orchestrator audits:

```bash
# From Horror.Place-Orchestrator root

# 0. Move to orchestrator repo root
cd Horror.Place-Orchestrator

# 1. Run unit tests and verification logic
cargo test -- --nocapture || true

# 2. Run integration sync harness (if present)
cargo test --test integration_sync_test -- --nocapture || true
```

The harness should check that:

- All registry mutations are gated behind a verify-then-promote workflow where canonical hashes and signatures are validated before any write is attempted.
- The Orchestrator’s Dead-Ledger client uses narrow, declarative interfaces (for example, proof envelopes and `deadledgerref` identifiers) and never attempts to store proofs or content locally.
- Cross-repo tests rely only on mock registries and descriptors, never cloning or modifying private vault content during audits.

## 6. Dead-Ledger / ZKP envelope preservation

The Dead-Ledger Network is the Tier-3 attestation layer that manages ZKPs, verifier registries, and ledger entries for bundles, agents, and spectral/BCI seeds.

The audit harness interacts with Dead-Ledger solely at the metadata level by:

- Validating that `schemas/zkp_proof_v1.json` defines a generic proof envelope with identifiers, proof type, statement ID, verifier ID, an opaque proof blob, and optional public inputs, with no embedded identity or raw BCI signals.
- Ensuring `registry/verifiers.json` lists all active verifier contracts with supported proof types and that every referenced `verifier_id` in envelopes resolves to an entry.
- Validating ledger entry schemas such as `schemas/ledger_entry_bundle_attestation_v1.json` to ensure they contain hashes, invariant/metric ranges, safety tiers, jurisdiction flags, signatures, and `deadledgerref` strings, but never content payloads.

To run Dead-Ledger schema audits:

```bash
# From HorrorPlace-Dead-Ledger-Network root

# 0. Move to Dead-Ledger repo root
cd HorrorPlace-Dead-Ledger-Network

# 1. Validate proof and ledger schemas (example Python tests)
pytest -q tests/test_schemas_deadledger.py || true

# 2. Validate verifiers registry and sample envelopes
pytest -q tests/test_verifiers_and_envelopes.py || true
```

These tests should confirm that all proof types share the same envelope schema, that verifiers are declared centrally, and that ledger entries are strictly attestation objects, not content stores.

## 7. Invariants, metrics, and constraints enforced by the harness

The audit harness implicitly enforces the full invariant and metric spine by treating Horror.Place schemas as the single reference.

For invariants (CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI), the harness should verify:

- Presence and correct numeric ranges in `coreschemas/invariantsv1.json`.
- Proper usage in contracts and routing logic (for example, events and personas referencing invariant bands consistently with the schema).
- Consistent projection of invariant ranges into Dead-Ledger bundle attestation entries (for example, normalized bands for CIC, DET, and SHCI).

For metrics (UEC, EMD, STCI, CDL, ARR), the harness should check:

- Schema correctness and documented roles in `coreschemas/entertainmentmetricsv1.json`.
- That experiment and summary schemas in labs map back to these canonical metric names and ranges.
- That Dead-Ledger fields for metric caps or targets reference these metrics and remain normalized, supporting policy decisions without exposing telemetry details.

## 8. How the harness preserves Dead-Ledger and content constraints

The harness is explicitly designed to honor Dead-Ledger and VM-Constellation constraints:

1. **No writes to Tier-2 or Tier-3 repos**  
   All interactions with vaults, labs, and Dead-Ledger are via read-only Git operations or mock HTTP calls; the harness never commits, pushes, or directly edits any private repository.

2. **No proof blobs or secret material**  
   When testing ZKP envelopes, the harness can construct synthetic envelopes with dummy `proof_blob` values and verify them against `schemas/zkp_proof_v1.json` and `registry/verifiers.json`, but must never generate or store real proofs, keys, or BCI-derived proofs.

3. **No horror content or trauma data**  
   The harness deals solely with schemas, registries, configuration files, and test descriptors; it does not open or parse any assets, raw logs, or narrative content files in vaults and labs, staying compliant with implication-only doctrine and public safety requirements.

4. **Dead-Ledger as the only entitlement authority**  
   The harness never bypasses Dead-Ledger: whenever tests need to simulate entitlement, they operate purely on metadata and example `deadledgerref` values, showing how clients would call Policy/Dead-Ledger without actually changing ledger state.

By keeping all checks read-only, metadata-focused, and schema-driven, this audit harness lets you continuously verify that the Horror.Place core, ALN and routing engines, Orchestrator, and Dead-Ledger protocol remain aligned with VM-Constellation rules while never crossing boundaries on content, proofs, or user data.
