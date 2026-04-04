# Horror.Place Schema Spine Enforcement (Summary)

This document summarizes how the Horror.Place public core repository enforces its role as schema authority for the Horror$Place VM‑constellation. It explains what the “schema spine” is, how it is validated, and what contributors must do when changing it.

---

## 1. What the schema spine is

The schema spine is the set of canonical contracts that all other repositories in the constellation rely on. At minimum, it includes:

- Core invariant schemas (safety and horror invariants).
- Entertainment metrics schemas (UEC, EMD, STCI, CDL, ARR and related fields).
- Style, event, and persona schemas.
- OpenAPI definitions for public Horror.Place API endpoints.
- Registry files for events, regions, styles, and personas.

These documents live in `core/schemas`, `core/api`, and `core/registry` and define the machine‑readable rules for every downstream vault or service.

---

## 2. CI enforcement in Horror.Place

Every pull request must pass the following CI jobs before merge:

- **Schema validation**  
  Validates all registry entries against their declared schemas. If any entry fails, the PR cannot be merged.

- **Registry linter**  
  Ensures that registry files are valid NDJSON, with required fields present and no duplicate IDs, and that `schemaref` values use the canonical URI format.

- **API leak test**  
  Scans core, public‑api, and docs for direct asset URLs, base64 payloads, and other potential raw content. Any hit fails the build.

- **Lua lint**  
  Runs `luacheck` on all Lua files in `public-api` to ensure consistent, safe public API stubs.

Contributors should run the corresponding scripts locally before opening a PR.

---

## 3. Registry rules

Registries in `core/registry` follow strict rules:

- New entries are appended as single‑line JSON objects (NDJSON format).
- Each entry must include at least:
  - `id`
  - `schemaref` pointing to a canonical schema file
  - `metadata`
  - `artifactid` or `cid` as an opaque reference
- Entries must never contain:
  - Direct links to assets
  - Base64‑encoded blobs
  - Embedded narrative, dialogue, or horror scenes

Changes to registries must follow the registry update playbook and are limited in size per PR to keep diffs auditable.

---

## 4. Contributor responsibilities

When proposing changes that touch the schema spine, contributors must:

1. Treat schemas as the single source of truth and update them before any implementation or registry changes.
2. Provide or update an ADR for any new or modified schema.
3. Bump versions and add new schema files for breaking changes rather than editing existing ones in place.
4. Run all validation and linting scripts locally.
5. Confirm that no raw content has been added anywhere in the public repo.

Pull requests that change schemas or registries should reference both the relevant ADR and the acceptance tests they expect to satisfy.

---

## 5. Relationship to downstream repositories

Horror.Place acts as the public schema authority. Private vaults and labs:

- Clone the canonical schemas from this repo.
- Validate their own data and assets against these schemas.
- Rely on Horror.Place registries as the source of opaque identifiers and contracts.

The Orchestrator service watches Horror.Place for changes to registries and schemas, then updates downstream indexes in a controlled, auditable way. This only works if every change in Horror.Place is validated, minimal, and fully documented.

By following this summary and the detailed docs in `docs/` and `audit/`, contributors help keep the entire VM‑constellation coherent, safe, and predictable.
