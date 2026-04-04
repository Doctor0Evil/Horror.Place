# Summary

Provide a concise description of what this PR does and why.

```text
One or two paragraphs explaining the change and its motivation.
Reference any related issue IDs or ADRs.
```

---

# Changed Files

List the key files and what changed in each.

```text
- core/schemas/…            — e.g., add field X, tighten constraint Y
- core/registry/…           — e.g., add N entries, update metadata
- core/api/openapi.yaml     — e.g., add endpoint, adjust response schema
- public-api/*.lua          — e.g., expose new H.* function, fix parameter type
- docs/*.md                 — e.g., new ADR, updated contributing guidance
- audit/*.md                — e.g., update acceptance tests or audit plan
```

---

# Acceptance Tests

Tick every acceptance test or guard that you expect to pass as part of this change.

- [ ] AT-001 Schema Validation (registries validate against declared schemas)
- [ ] AT-002 Registry Linter (NDJSON structure, required fields, URI format)
- [ ] AT-003 API Leak Test (no asset URLs, base64, or hex blobs)
- [ ] AT-004 No Raw Content (no embedded images/audio/video, no narrative text)
- [ ] AT-005 Canonical URI Check (`schemaref` format)
- [ ] AT-006 Single-Line Format (one JSON object per registry line)
- [ ] AT-007 Lua Lint (luacheck on `public-api`)
- [ ] AT-008 Telemetry Sanitization Docs (if docs/audit are touched)
- [ ] Unit tests for scripts and tooling
- [ ] Other (specify):

```text
Additional tests run locally, with commands and results.
```

---

# Zero-Raw-Content Confirmation

This repo must never contain raw horror content or direct media.

Confirm all of the following:

- [ ] No direct asset URLs are introduced (no `http://`, `https://`, `s3://`, `gs://` pointing at assets).
- [ ] No base64-encoded content or embedded binary payloads are introduced.
- [ ] No narrative, dialogue, or scene descriptions are added to schemas, registries, or docs.
- [ ] Registries only reference opaque identifiers (`artifactid`, `cid`, `schemaref`, metadata).

If there are fields that might look like content to a reviewer or scanner, explain why they are safe:

```text
Potential leak-like fields and why they are safe (e.g., short labels, IDs).
```

---

# Schema / Contract Details (if applicable)

For schema or contract changes:

```text
Schemas touched:
Type of change (extension vs breaking):
New version file? (e.g., invariantsv2.json):
Migration plan for downstream repos:
```

- [ ] ADR added or updated
- [ ] Versioning rules applied (new file for breaking changes)
- [ ] Registry entries updated following `audit/registry-update-playbook.md`

---

# Downstream & Constellation Impact

Describe any expected impact on other repositories or services (Orchestrator, vaults, Dead‑Ledger, etc.).

```text
Repos or services impacted:
Required follow-up PRs:
Order of rollout or feature flags:
```

---

# Checklist for Reviewers

Reviewers can use this list when approving:

- [ ] Follows schema‑first principles (no ad‑hoc fields; schemas are single source of truth).
- [ ] No raw content or media leaks.
- [ ] CI configuration unchanged or clearly justified.
- [ ] Registry updates are minimal, well‑scoped, and follow the playbook.
- [ ] Docs, ADRs, and audit artifacts are consistent with the changes.
