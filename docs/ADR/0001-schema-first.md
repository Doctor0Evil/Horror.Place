# ADR-0001: Schema-First Design

| Field     | Value                    |
| --------- | ------------------------ |
| Status    | **Accepted**             |
| Date      | 2026-04-02               |
| Deciders  | Horror.Place Core Team   |

---

## Context

Horror.Place requires strict separation between public schema definitions and
private content. The platform architecture comprises:

- **Public core repository** — schema definitions, registries, API specs, and
  audit artifacts visible to all contributors and downstream consumers.
- **Private vaults** — content repositories (e.g., HorrorPlace-Atrocity-Seeds)
  that produce artifacts referencing public schemas but containing proprietary
  or sensitive material.

Multiple private vaults independently produce artifacts that reference public
schemas. Registries in the public core must be machine-validatable to ensure
correctness without human inspection of private content.

Without a schema-first design:

- Contract drift between public and private repos becomes unmanageable.
- Registry entries cannot be validated without access to private vaults.
- Breaking changes propagate silently across vault boundaries.
- CI/CD pipelines cannot enforce structural correctness.
- Onboarding new vaults requires manual contract negotiation.

---

## Decision

We adopt the following schema-first principles:

1. **All data structures are defined as versioned JSON Schemas (draft 2020-12)
   before any implementation.** Schemas are the canonical source of truth for
   data shape, constraints, and documentation.

2. **Registries reference schemas via canonical URIs.** Every registry entry
   includes a `schema_ref` field with the format:
   ```
   schema://Horror.Place/core/schemas/{schema_name}
   ```

3. **CI pipelines validate all entries against declared schemas.** The
   `schema-validation` job loads the referenced schema for each registry entry
   and validates the entry against it. No PR merges without passing validation.

4. **Schema changes require a new ADR.** Any modification to an existing schema
   or introduction of a new schema must be accompanied by an Architecture
   Decision Record documenting the rationale, impact, and migration plan.

5. **Breaking changes require a version bump.** Non-backward-compatible changes
   to a schema produce a new versioned file (e.g., `invariants_v2.json`) rather
   than modifying the existing schema. The previous version remains available
   for a deprecation period defined in the ADR.

---

## Consequences

### Positive

- **Deterministic validation.** Every registry entry can be validated
  automatically without human judgment or private content access.
- **Clear contracts.** Schemas define the exact interface between public
  infrastructure and private vaults.
- **Automated compliance.** CI enforces schema adherence on every commit,
  preventing contract drift.
- **Independent vault development.** Private vaults can develop against
  published schemas without coordinating with the core team on every change.

### Negative

- **Schema evolution discipline.** Teams must plan schema changes carefully;
  ad-hoc field additions are no longer possible.
- **Migration tooling for breaking changes.** Major version bumps require
  migration scripts and a deprecation timeline.
- **Upfront design cost.** Schema authoring takes time before implementation
  can begin.

---

## Compliance

To ensure adherence to this decision:

- Every CI pipeline **must** include a `schema-validation` job.
- No PR merges without passing schema checks.
- Schema changes require:
  - A new ADR documenting the change.
  - Minimum **2-reviewer approval** on the PR.
  - A migration plan if the change is breaking.
- Quarterly audits verify all active registry entries validate against current
  schemas (see [audit/api-audit-plan.md](../../audit/api-audit-plan.md)).
