---
name: "Schema / Contract Change"
about: Propose a change to Horror.Place schemas, API contracts, or registries
title: "[SCHEMA] <short summary>"
labels: ["schema", "tier-1", "needs-triage"]
assignees: []
---

## Summary

**Describe the proposed change in 2–3 sentences.**  
What schema(s) or contract(s) are you changing, and why is this necessary now?

---

## Scope of Change

### Affected files (check all that apply)

- [ ] `core/schemas/invariantsv*.json`
- [ ] `core/schemas/entertainmentmetricsv*.json`
- [ ] `core/schemas/stylecontractv*.json`
- [ ] `core/schemas/eventcontractv*.json`
- [ ] `core/schemas/personacontractv*.json`
- [ ] `core/api/openapi.yaml`
- [ ] `core/registry/events*.ndjson`
- [ ] `core/registry/regions*.ndjson`
- [ ] `core/registry/styles*.ndjson`
- [ ] `core/registry/personas*.ndjson`
- [ ] Other (specify):

```text
Other files:
```

### Change type

- [ ] Backwards-compatible schema extension
- [ ] Backwards-incompatible schema change (requires version bump)
- [ ] New schema file
- [ ] Registry shape change (fields, constraints)
- [ ] API contract change (OpenAPI or Lua public API)

---

## Schema-First Requirements

### ADR reference

```text
ADR ID / link (required for schema changes):
```

- [ ] New or updated ADR drafted
- [ ] ADR reviewed by at least 2 maintainers (required for Tier‑1 schema changes)

### Versioning

For any breaking change:

```text
Current version:
Proposed new version:
Migration notes (who must migrate, and how):
```

- [ ] New versioned schema file added (e.g., `invariantsv2.json`)
- [ ] Old version retained for deprecation window

---

## Registry and Invariant Impact

If this change affects registries or invariant/metric usage, describe:

```text
Impacted registry files (events / regions / styles / personas):
Expected number of entries to update:
Does this change any invariant or metric semantics? If yes, describe precisely:
```

- [ ] Registry update follows `audit/registry-update-playbook.md`
- [ ] Maximum 10 entries per PR respected (or justified if not)

---

## CI and Acceptance Tests

Confirm you have run the relevant checks locally:

- [ ] `python scripts/validateschemas.py --registry-dir core/registry --schema-dir core/schemas`
- [ ] `python scripts/registrylinter.py core/registry`
- [ ] `python scripts/apileaktest.py --scan-dirs core public-api docs`
- [ ] `luacheck public-api` (if Lua API is affected)

Map this change to acceptance tests:

- [ ] AT-001 Schema Validation
- [ ] AT-002 Registry Linter
- [ ] AT-003 API Leak Test
- [ ] AT-004 No Raw Content
- [ ] AT-005 Canonical URI Check
- [ ] AT-006 Single-Line Format
- [ ] AT-007 Lua Lint
- [ ] AT-008 Telemetry Sanitization Docs
- [ ] Other (specify):

```text
Additional tests or tools:
```

---

## Zero-Raw-Content Confirmation

This repository must never contain raw horror content, media, or direct asset links.

Confirm all of the following:

- [ ] No direct asset URLs introduced (e.g., `https://…`, `s3://…`, `gs://…`)
- [ ] No base64-encoded data or embedded binary blobs
- [ ] No inline narrative, dialogue, or descriptive horror content
- [ ] Registries reference only opaque identifiers (`artifactid`, `cid`, `schemaref`, metadata)

If any field could be misused to smuggle content, explain the guardrails:

```text
Potential leak surfaces and how they are constrained:
```

---

## Downstream Impact (Vaults, Orchestrator, Dead-Ledger)

Describe how this change affects downstream repositories and services:

```text
Vaults / services impacted (e.g., Atrocity-Seeds, Black-Archivum, Orchestrator, Dead-Ledger):
Required changes in those repos (schema alignment, registry updates, CI changes):
Rollout plan (order of PRs, feature flags, deprecation window):
```

- [ ] Orchestrator behavior reviewed (registry sync, hash verification)
- [ ] Any necessary cross-repo issues or tasks opened

---

## Open Questions / Reviewer Notes

```text
List any unresolved questions, tradeoffs, or design alternatives you considered.
Highlight anything you especially want reviewers to focus on.
```
