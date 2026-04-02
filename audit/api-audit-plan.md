# Horror.Place API Audit Plan

| Field         | Value       |
| ------------- | ----------- |
| Version       | 1.0.0       |
| Last Updated  | 2026-04-02  |

---

## Scope

This audit plan covers all public-facing components of the Horror.Place
public core repository:

- All public API endpoints defined in `core/api/openapi.yaml`.
- All registry files in `core/registry/`.
- All schema definitions in `core/schemas/`.
- All public API stubs in `public-api/`.
- Telemetry sanitization requirements for downstream consumers.
- Documentation and audit artifacts in `docs/` and `audit/`.

---

## Audit Categories

### 1. Content Leak Tests

Scan all public-facing files and API responses for raw content that violates
the zero-raw-content policy.

| Test ID     | Name                  | Description                                                       | Automated | CI Job          |
| ----------- | --------------------- | ----------------------------------------------------------------- | --------- | --------------- |
| AUD-CL-001  | Raw Content Scan      | Scan API response schemas for fields that could contain raw content (inline text blobs, binary data, media payloads). Verify all content fields reference opaque identifiers only. | Yes | `api-leak-test` |
| AUD-CL-002  | Direct Asset URL Scan | Scan all tracked files for patterns matching direct asset URLs (e.g., `https://`, `http://`, `s3://`, `gs://` followed by asset-like paths). Registry entries must not contain asset URLs. | Yes | `api-leak-test` |
| AUD-CL-003  | Unsanitized Data Scan | Scan for base64-encoded data patterns, hex-encoded binary, and embedded media MIME types in all tracked files. | Yes | `api-leak-test` |

### 2. Schema Compliance

Validate every registry entry against its declared schema reference.

| Test ID     | Name                      | Description                                                    | Automated | CI Job              |
| ----------- | ------------------------- | -------------------------------------------------------------- | --------- | ------------------- |
| AUD-SC-001  | Entry-Level Validation    | Parse each line of every registry NDJSON file. Load the schema referenced by the entry's `schema_ref` field. Validate the entry against that schema. | Yes | `schema-validation` |
| AUD-SC-002  | Schema Existence Check    | Verify that every `schema_ref` URI in every registry entry resolves to an existing schema file in `core/schemas/`. | Yes | `schema-validation` |

### 3. Telemetry Sanitization

Verify that telemetry specifications and documentation enforce proper
sanitization of sensitive data.

| Test ID     | Name                         | Description                                                    | Automated | CI Job          |
| ----------- | ---------------------------- | -------------------------------------------------------------- | --------- | --------------- |
| AUD-TS-001  | No PII in Telemetry          | Verify that telemetry schema definitions do not include fields for personally identifiable information (names, emails, IPs, device IDs). | Yes | `api-leak-test` |
| AUD-TS-002  | Opaque Session IDs           | Verify that session identifiers in telemetry schemas are typed as UUID-only with no additional metadata leakage. | Yes | `api-leak-test` |
| AUD-TS-003  | Aggregated Metrics           | Verify that engagement metrics are defined at session-aggregate level or higher. No individual-event-level tracking fields permitted. | Manual | Quarterly review |
| AUD-TS-004  | No Raw Content in Telemetry  | Verify that telemetry payloads and schemas never reference or include raw content identifiers, asset URLs, or content bodies. | Yes | `api-leak-test` |

### 4. Access Control

Verify authentication and authorization controls on API endpoints.

| Test ID     | Name                    | Description                                                       | Automated | CI Job           |
| ----------- | ----------------------- | ----------------------------------------------------------------- | --------- | ---------------- |
| AUD-AC-001  | Write Endpoint Auth     | Verify all write (POST, PUT, PATCH, DELETE) endpoints in the OpenAPI spec require authentication. | Yes | `api-leak-test`  |
| AUD-AC-002  | Rate Limiting           | Verify rate limiting headers and configuration are defined for all public endpoints. | Manual | Quarterly review |
| AUD-AC-003  | Admin Route Restriction | Verify admin-only routes are marked with appropriate security schemes and are not accessible without elevated privileges. | Manual | Quarterly review |

### 5. Registry Integrity

Verify structural integrity and consistency of all registry files.

| Test ID     | Name                   | Description                                                        | Automated | CI Job            |
| ----------- | ---------------------- | ------------------------------------------------------------------ | --------- | ----------------- |
| AUD-RI-001  | ID Consistency         | Verify every registry entry has a unique `id` field. Check `artifact_id` or `cid` is present and non-empty. No duplicates across entries within a file. | Yes | `registry-linter` |
| AUD-RI-002  | No Orphaned Entries    | Verify every `schema_ref` in registry entries points to a valid, existing schema. Cross-reference artifact IDs are consistent. | Yes | `schema-validation` |
| AUD-RI-003  | Canonical URI Format   | Verify all `schema_ref` values match the pattern `schema://Horror.Place/core/schemas/{name}`. | Yes | `registry-linter` |

---

## Schedule

| Frequency        | Type             | Scope                          | Responsible         |
| ---------------- | ---------------- | ------------------------------ | ------------------- |
| Every PR         | Automated        | All automated tests (CI jobs)  | PR author, CI       |
| Weekly           | Scheduled scan   | Full automated suite           | CI (cron trigger)   |
| Quarterly        | Manual review    | All categories incl. manual    | Audit lead          |

---

## Responsible Parties

| Role            | Responsibility                                                 |
| --------------- | -------------------------------------------------------------- |
| PR Author       | Run self-checks locally before pushing. Address CI failures.   |
| Reviewers (x2)  | Code review for Tier 1 changes. Verify audit compliance.       |
| Audit Lead      | Conduct quarterly manual reviews. Maintain audit plan.         |

---

## Telemetry Sanitization Rules

The following rules govern all telemetry data produced by Horror.Place
services. These rules are enforced through schema definitions, CI checks,
and manual review.

| Rule ID   | Rule                                   | Description                                                                                            | Enforcement         |
| --------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------- |
| TS-R-001  | PII Stripping                          | All telemetry payloads must strip personally identifiable information before storage. No names, email addresses, IP addresses, device fingerprints, or geolocation data at granularity finer than country level. | CI + quarterly review |
| TS-R-002  | Opaque Session IDs                     | The `session_id` field must be a v4 UUID only. No session tokens, authentication tokens, or user-correlatable identifiers may be used as session IDs. | CI (`api-leak-test`) |
| TS-R-003  | Aggregation Requirements               | Engagement metrics must be aggregated to session level at minimum. No per-event, per-click, or per-interaction granularity is permitted in stored telemetry. Real-time streams may contain event-level data but must aggregate before persistence. | Quarterly review    |
| TS-R-004  | Retention Limits                       | Telemetry data retention must not exceed 90 days for raw session data and 365 days for aggregated metrics. Retention policies must be enforced at the storage layer. | Quarterly review    |
| TS-R-005  | No Raw Content in Telemetry Payloads   | Telemetry payloads must never include raw content references (asset URLs, CIDs pointing to content, or content bodies). Only opaque event identifiers and metric values are permitted. | CI (`api-leak-test`) |
| TS-R-006  | Sanitization Validation in CI          | The `api-leak-test` CI job must include checks for PII patterns, raw content references, and non-UUID session identifiers in all telemetry-related schema and specification files. | CI (`api-leak-test`) |
