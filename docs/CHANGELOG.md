# Changelog

All notable changes to the Horror.Place Public Core repository will be
documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] — 2026-04-02

### Added

- **Schemas:** Initial schema definitions in `core/schemas/`:
  - `invariants_v1.json` — core invariant constraints for Horror.Place entities.
  - `entertainment_metrics_v1.json` — engagement and entertainment metric
    structures.
  - `stylecontract_v1.json` — style contract definitions for visual and
    narrative consistency.

- **Registries:** Registry files with placeholder entries in `core/registry/`:
  - `events.ndjson` — event registry.
  - `regions.ndjson` — region registry.
  - `styles.ndjson` — style registry.
  - `personas.ndjson` — persona registry.

- **API Specification:** OpenAPI 3.1 specification v1 draft in `core/api/openapi.yaml`.

- **Public API Stubs:** Lua API stubs in `public-api/`:
  - `h_cic.lua` — H.CIC (Content Integrity Check) stub.
  - `h_resolve_event_spec.lua` — H.resolve_event_spec stub.
  - `h_metrics_spec.lua` — H.metrics_spec stub.

- **ADR-0001:** Schema-First Design architecture decision record
  (`docs/ADR/0001-schema-first.md`).

- **Contributing Guide:** Full contributing guidelines (`docs/CONTRIBUTING.md`).

- **Code of Conduct:** Contributor Covenant v2.1 adapted for Horror.Place
  (`docs/CODE_OF_CONDUCT.md`).

- **Changelog:** This changelog file (`docs/CHANGELOG.md`).

- **Audit Artifacts:**
  - `audit/api-audit-plan.md` — API audit plan with telemetry sanitization
    rules.
  - `audit/registry-update-playbook.md` — step-by-step registry update process.
  - `audit/acceptance-tests.md` — acceptance test definitions (AT-001 through
    AT-008).

- **CircleCI Pipeline:** `.circleci/config.yml` with jobs:
  - `registry-linter` — NDJSON format and field validation.
  - `schema-validation` — registry entries validated against declared schemas.
  - `api-leak-test` — scan for raw content and asset URL leaks.
  - `lua-lint` — luacheck on all public-api/ Lua files.
