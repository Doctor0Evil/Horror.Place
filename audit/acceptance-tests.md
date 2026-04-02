# Acceptance Test Definitions

This document defines the acceptance tests for the Horror.Place public core
repository. Each test has a unique ID, description, preconditions, steps,
expected result, and automation status.

---

## AT-001: Schema Validation

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-001                                                                |
| **Name**        | Schema Validation                                                     |
| **Description** | All registry entries validate against their declared `schema_ref`.    |
| **Preconditions** | Schemas exist in `core/schemas/`. Registry files exist in `core/registry/`. |
| **Steps**       | 1. Load all JSON Schema files from `core/schemas/`. 2. Iterate over all `.ndjson` files in `core/registry/`. 3. For each line, parse the JSON object and extract `schema_ref`. 4. Resolve `schema_ref` to a local schema file. 5. Validate the entry against the resolved schema. |
| **Expected Result** | Zero validation errors. Every entry conforms to its declared schema. |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `schema-validation`                                                   |

---

## AT-002: Registry Linter

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-002                                                                |
| **Name**        | Registry Linter                                                       |
| **Description** | All registry files are valid NDJSON. Each entry contains required fields: `id`, `schema_ref`, `metadata`, and `artifact_id` or `cid`. |
| **Preconditions** | Registry files exist in `core/registry/`.                           |
| **Steps**       | 1. Iterate over all `.ndjson` files in `core/registry/`. 2. For each non-empty line, parse as JSON. 3. Verify required fields are present and non-empty. 4. Verify no duplicate `id` values within a file. |
| **Expected Result** | Zero format errors. All required fields present. No duplicate IDs. |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `registry-linter`                                                     |

---

## AT-003: API Leak Test

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-003                                                                |
| **Name**        | API Leak Test                                                         |
| **Description** | Scan `core/`, `public-api/`, and `docs/` for raw content patterns including direct asset URLs, base64-encoded data, and hex-encoded binary. |
| **Preconditions** | Repository files exist and are tracked by git.                      |
| **Steps**       | 1. Recursively scan all tracked files in `core/`, `public-api/`, `docs/`. 2. Apply regex patterns for asset URLs (`https?://`, `s3://`, `gs://` with asset extensions). 3. Apply regex for base64 data patterns. 4. Apply regex for hex-encoded binary blobs. |
| **Expected Result** | Zero matches. No raw content detected in any public file.          |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `api-leak-test`                                                       |

---

## AT-004: No Raw Content

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-004                                                                |
| **Name**        | No Raw Content                                                        |
| **Description** | Grep all tracked files for image/audio/video file extensions and base64 patterns to ensure no media content is embedded. |
| **Preconditions** | Repository files exist and are tracked by git.                      |
| **Steps**       | 1. Search all tracked files for patterns: `.png`, `.jpg`, `.jpeg`, `.gif`, `.mp3`, `.mp4`, `.wav`, `.ogg`, `.webm`, `.webp` in URL-like contexts. 2. Search for base64 header patterns (`data:image/`, `data:audio/`, `data:video/`). 3. Exclude documentation references (e.g., this file). |
| **Expected Result** | Zero matches outside of documentation/test definition files.       |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `api-leak-test`                                                       |

---

## AT-005: Canonical URI Check

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-005                                                                |
| **Name**        | Canonical URI Check                                                   |
| **Description** | All `schema_ref` values in registry entries match the canonical URI format `schema://Horror.Place/core/schemas/{name}`. |
| **Preconditions** | Registry files exist in `core/registry/`.                           |
| **Steps**       | 1. Iterate over all `.ndjson` files in `core/registry/`. 2. For each entry, extract the `schema_ref` value. 3. Validate against the regex: `^schema://Horror\.Place/core/schemas/[a-z_]+_v\d+$`. |
| **Expected Result** | All `schema_ref` values match the canonical format. Zero mismatches. |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `registry-linter`                                                     |

---

## AT-006: Single-Line Format

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-006                                                                |
| **Name**        | Single-Line Format                                                    |
| **Description** | Each non-empty line in registry files parses as a valid JSON object. No multi-line JSON, no trailing commas, no comments. |
| **Preconditions** | Registry files exist in `core/registry/`.                           |
| **Steps**       | 1. Iterate over all `.ndjson` files in `core/registry/`. 2. For each non-empty line, attempt to parse as JSON. 3. Verify the parsed result is a JSON object (not array, string, etc.). |
| **Expected Result** | Every non-empty line parses as a valid JSON object. Zero parse errors. |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `registry-linter`                                                     |

---

## AT-007: Lua Lint

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-007                                                                |
| **Name**        | Lua Lint                                                              |
| **Description** | luacheck passes on all `.lua` files in `public-api/` with zero errors and zero warnings. |
| **Preconditions** | luacheck installed (v1.1+). `.luacheckrc` config present in repo root. |
| **Steps**       | 1. Run `luacheck public-api/`. 2. Capture exit code, errors, and warnings. |
| **Expected Result** | Exit code 0. Zero errors. Zero warnings.                           |
| **Automated**   | Yes                                                                   |
| **CI Job**      | `lua-lint`                                                            |

---

## AT-008: Telemetry Sanitization Docs

| Field           | Value                                                                 |
| --------------- | --------------------------------------------------------------------- |
| **ID**          | AT-008                                                                |
| **Name**        | Telemetry Sanitization Docs                                           |
| **Description** | Verify that `audit/api-audit-plan.md` contains a "Telemetry Sanitization Rules" section with rules TS-R-001 through TS-R-006. |
| **Preconditions** | `audit/api-audit-plan.md` exists.                                   |
| **Steps**       | 1. Open `audit/api-audit-plan.md`. 2. Search for heading "Telemetry Sanitization Rules". 3. Verify rules TS-R-001 through TS-R-006 are present with descriptions. |
| **Expected Result** | Section exists. All six rules (TS-R-001 through TS-R-006) are documented with descriptions and enforcement methods. |
| **Automated**   | No (manual review)                                                    |
| **CI Job**      | Quarterly review                                         
