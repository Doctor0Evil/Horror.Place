# Horror.Place — Public Core

[![CircleCI](https://circleci.com/gh/HorrorPlace/horror-place-core.svg?style=shield)](https://circleci.com/gh/HorrorPlace/horror-place-core)
![Schema Version](https://img.shields.io/badge/schema-draft--2020--12-blue)
![License](https://img.shields.io/badge/license-Proprietary-red)

---

## Overview

**Horror.Place Public Core** is the schema-first, audit-heavy, zero-raw-content
public infrastructure repository for the Horror.Place platform. This repo
contains every public contract, schema definition, registry specification, and
API stub required by downstream private vaults and orchestration services.

No raw content — no assets, no media, no inline data — ever exists in this
repository. Registries contain only opaque identifiers. Every update is logged.
Every CI run produces an auditable trail.

---

## What This Repo Contains

| Directory          | Purpose                                                  |
| ------------------ | -------------------------------------------------------- |
| `core/schemas/`    | Versioned JSON Schemas (draft 2020-12) for all data types |
| `core/registry/`   | NDJSON registry files with opaque references only         |
| `core/api/`        | OpenAPI 3.1 specification for the Horror.Place public API |
| `public-api/`      | Public API stubs (Lua): H.CIC, H.resolve_event_spec, etc.|
| `docs/`            | ADRs, contributing guide, code of conduct, changelog      |
| `audit/`           | Audit plans, playbooks, acceptance test definitions       |

---

## Architecture Principles

### 1. Schema-First (ref ADR-0001)

All data structures are defined as versioned JSON Schemas **before**
implementation. Schemas are the single source of truth. See
[docs/ADR/0001-schema-first.md](docs/ADR/0001-schema-first.md).

### 2. No Raw Content in Public Repos

Registries contain **only opaque identifiers** — artifact IDs, content
identifiers (CIDs), and metadata. No asset URLs, no base64-encoded data,
no inline content. Raw content lives exclusively in private vaults.

### 3. Audit-Heavy

Every update is logged. Every CI pipeline produces an audit trail. Every
registry mutation follows the
[Registry Update Playbook](audit/registry-update-playbook.md). Quarterly
manual reviews supplement automated checks.

### 4. Canonical URIs

All schema references use the canonical URI format:

```
schema://Horror.Place/core/schemas/{name}
```

This ensures deterministic resolution across all consuming services and vaults.

### 5. Single-Line Registry Entries

Each registry entry occupies exactly one line of valid JSON (NDJSON format).
This produces clean, reviewable diffs and enables line-level validation.

---

## Quick Start

### Validate Schemas

```bash
# Install dependencies
pip install jsonschema check-jsonschema

# Validate all registry entries against their declared schemas
python scripts/validate_schemas.py --registry-dir core/registry/ --schema-dir core/schemas/
```

### Run Registry Linter

```bash
# Lint all registry files for format compliance
python scripts/registry_linter.py core/registry/
```

### Run API Leak Tests

```bash
# Scan for raw content, asset URLs, base64 data in public files
python scripts/api_leak_test.py --scan-dirs core/ public-api/ docs/
```

### Lua Lint

```bash
# Lint all Lua stubs
luacheck public-api/
```

---

## CI/CD

This repository uses **CircleCI** with the following pipeline jobs:

| Job                  | Trigger      | Description                                       |
| -------------------- | ------------ | ------------------------------------------------- |
| `schema-validation`  | Every PR     | Validates all registry entries against schemas     |
| `registry-linter`    | Every PR     | Checks NDJSON format, required fields, URI format  |
| `api-leak-test`      | Every PR     | Scans for raw content, asset URLs, base64 data     |
| `lua-lint`           | Every PR     | Runs luacheck on all public-api/ Lua files         |
| `weekly-full-scan`   | Cron (weekly)| Full audit scan across all categories              |

All jobs must pass before a PR can be merged. See
[.circleci/config.yml](.circleci/config.yml) for pipeline definitions.

---

## Repository Map

```
horror-place-core/
├── .circleci/
│   └── config.yml
├── core/
│   ├── schemas/
│   │   ├── invariants_v1.json
│   │   ├── entertainment_metrics_v1.json
│   │   └── stylecontract_v1.json
│   ├── registry/
│   │   ├── events.ndjson
│   │   ├── regions.ndjson
│   │   ├── styles.ndjson
│   │   └── personas.ndjson
│   └── api/
│       └── openapi.yaml
├── public-api/
│   ├── h_cic.lua
│   ├── h_resolve_event_spec.lua
│   └── h_metrics_spec.lua
├── docs/
│   ├── ADR/
│   │   └── 0001-schema-first.md
│   ├── CONTRIBUTING.md
│   ├── CODE_OF_CONDUCT.md
│   └── CHANGELOG.md
├── audit/
│   ├── api-audit-plan.md
│   ├── registry-update-playbook.md
│   └── acceptance-tests.md
├── scripts/
│   ├── validate_schemas.py
│   ├── registry_linter.py
│   └── api_leak_test.py
├── README.md
└── LICENSE
```

---

## Related Repositories

| Repository                    | Description                                      |
| ----------------------------- | ------------------------------------------------ |
| `HorrorPlace-Atrocity-Seeds`  | Canonical private vault example implementation    |
| `Horror.Place-Orchestrator`    | Registry update service; polls this repo for changes |

---

## Contributing

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for full contributing
guidelines, branch naming conventions, PR process, and required checks.

---

## License

**Proprietary.** All rights reserved. See [LICENSE](LICENSE) for details.
