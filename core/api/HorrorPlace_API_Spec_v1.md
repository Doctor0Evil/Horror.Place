# Horror.Place Public API Specification v1

**Version:** 1.0.0-draft
**Last Updated:** 2026-04-02
**Base URL:** `https://api.horror.place/v1`
**Status:** Draft — subject to change prior to 1.0.0 release

---

## 1. Authentication

| Method | Scope | Usage |
|---|---|---|
| **Bearer Token (JWT)** | Write endpoints, privileged reads | Passed via `Authorization: Bearer <token>` header |
| **API Key** | Read-only endpoints | Passed via `X-API-Key` header |
| **Anonymous** | `/health`, `/schemas/*` | No credentials required |

Tokens are issued by the Horror.Place Auth Service. JWTs expire after 1 hour.
API keys are scoped per-application and do not expire unless revoked.

---

## 2. Rate Limiting

| Tier | Limit | Window |
|---|---|---|
| Authenticated (JWT / API Key) | 100 requests | Per minute |
| Anonymous | 20 requests | Per minute |

**Rate limit headers** are included in every response:

| Header | Description |
|---|---|
| `X-RateLimit-Limit` | Maximum requests allowed in the current window |
| `X-RateLimit-Remaining` | Requests remaining in the current window |
| `X-RateLimit-Reset` | UTC epoch timestamp when the window resets |

When the rate limit is exceeded, a `429 Too Many Requests` response is returned.

---

## 3. Endpoints

### 3.1 GET /health

**Description:** Health check and version probe.
**Authentication:** None.

**Request Parameters:** None.

**Response (200 OK):**

```json
{
  "status": "ok",
  "version": "1.0.0",
  "timestamp": "2026-04-02T00:00:00Z"
}
```

**Error Codes:** `500` — Internal server error.

---

### 3.2 GET /registries/{registry_name}

**Description:** List all entries in a named registry.
**Authentication:** API Key required.

**Path Parameters:**

| Name | Type | Description |
|---|---|---|
| `registry_name` | string | One of: `events`, `regions`, `styles`, `personas` |

**Query Parameters:**

| Name | Type | Default | Description |
|---|---|---|---|
| `page` | integer | `1` | Page number (1-indexed) |
| `per_page` | integer | `50` | Results per page (max: 100) |
| `status` | string | — | Filter by status: `draft`, `active`, `archived` |

**Response (200 OK):**

```json
{
  "data": [
    {
      "id": "EVT-0001",
      "schema_ref": "schema://Horror.Place/core/schemas/invariants_v1",
      "artifact_id": "art_a1b2c3d4e5f6",
      "metadata": {
        "name": "Opaque Event Reference",
        "status": "active",
        "created_at": "2026-01-15T08:30:00Z"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 50,
    "total": 3
  }
}
```

**Error Codes:** `400` — Invalid registry name or query parameters. `401` — Missing or invalid API key. `500` — Internal server error.

---

### 3.3 GET /registries/{registry_name}/{id}

**Description:** Retrieve a single registry entry by ID.
**Authentication:** API Key required.

**Path Parameters:**

| Name | Type | Description |
|---|---|---|
| `registry_name` | string | One of: `events`, `regions`, `styles`, `personas` |
| `id` | string | Entry identifier (e.g., `EVT-0001`, `RGN-0012`) |

**Response (200 OK):**

```json
{
  "id": "EVT-0001",
  "schema_ref": "schema://Horror.Place/core/schemas/invariants_v1",
  "artifact_id": "art_a1b2c3d4e5f6",
  "metadata": {
    "name": "Opaque Event Reference",
    "status": "active",
    "created_at": "2026-01-15T08:30:00Z",
    "updated_at": "2026-03-20T14:00:00Z"
  }
}
```

**Error Codes:** `400` — Invalid ID format. `401` — Missing or invalid API key. `404` — Entry not found. `500` — Internal server error.

---

### 3.4 GET /schemas/{schema_name}

**Description:** Retrieve a JSON Schema document by name.
**Authentication:** None.

**Path Parameters:**

| Name | Type | Description |
|---|---|---|
| `schema_name` | string | Schema short name (e.g., `invariants_v1`, `entertainment_metrics_v1`) |

**Response (200 OK):** The JSON Schema document itself (Content-Type: `application/json`).

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "schema://Horror.Place/core/schemas/invariants_v1",
  "title": "Invariants v1",
  "type": "object",
  "properties": { ... }
}
```

**Error Codes:** `404` — Schema not found. `500` — Internal server error.

---

### 3.5 POST /metrics/ingest

**Description:** Ingest entertainment metrics for a session.
**Authentication:** Bearer token (JWT) required.

**Request Body** (conforms to `entertainment_metrics_v1` schema):

```json
{
  "session_id": "sess_7f8a9b0c1d2e",
  "timestamp": "2026-04-01T22:15:00Z",
  "metrics": {
    "engagement": 0.82,
    "tension_curve": [0.3, 0.5, 0.75, 0.9, 0.6],
    "pacing": "accelerating",
    "completion": 0.95,
    "satisfaction": 0.88
  }
}
```

**Response (202 Accepted):**

```json
{
  "accepted": true,
  "metric_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "ingested_at": "2026-04-01T22:15:01Z"
}
```

**Error Codes:** `400` — Invalid payload / schema validation failure. `401` — Unauthorized. `429` — Rate limited. `500` — Internal server error.

---

### 3.6 GET /metrics/summary/{session_id}

**Description:** Retrieve aggregated metrics summary for a session.
**Authentication:** Bearer token (JWT) required.

**Path Parameters:**

| Name | Type | Description |
|---|---|---|
| `session_id` | string | Opaque session identifier |

**Response (200 OK):**

```json
{
  "session_id": "sess_7f8a9b0c1d2e",
  "summary": {
    "engagement_avg": 0.82,
    "tension_peak": 0.93,
    "tension_valley": 0.18,
    "pacing_label": "accelerating",
    "audience": {
      "completion_rate": 0.95,
      "repeat_rate": 0.22,
      "satisfaction_index": 0.88
    }
  },
  "computed_at": "2026-04-01T23:00:00Z"
}
```

**Error Codes:** `401` — Unauthorized. `404` — Session not found. `429` — Rate limited. `500` — Internal server error.

---

### 3.7 POST /events/resolve

**Description:** Resolve an event ID to its opaque specification, optionally applying region and style context.
**Authentication:** Bearer token (JWT) required.

**Request Body:**

```json
{
  "event_id": "EVT-0042",
  "context": {
    "region_ref": "RGN-0007",
    "style_ref": "STY-0003"
  }
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `event_id` | string | Yes | Event identifier matching pattern `EVT-\d{4}` |
| `context` | object | No | Optional resolution context |
| `context.region_ref` | string | No | Region registry ID |
| `context.style_ref` | string | No | Style registry ID |

**Response (200 OK):**

```json
{
  "event_id": "EVT-0042",
  "schema_ref": "schema://Horror.Place/core/schemas/invariants_v1",
  "artifact_id": "art_e7f8a9b0c1d2",
  "cid": "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi",
  "metadata": {
    "name": "Opaque Event Reference",
    "status": "active",
    "resolved_at": "2026-04-02T00:00:00Z"
  },
  "style_contract": {
    "style_id": "STY-0003",
    "schema_ref": "schema://Horror.Place/core/schemas/stylecontract_v1"
  }
}
```

**Error Codes:** `400` — Invalid event_id format or invalid context references. `401` — Unauthorized. `404` — Event not found. `429` — Rate limited. `500` — Internal server error.

---

### 3.8 GET /audit/log

**Description:** Retrieve paginated audit log entries.
**Authentication:** Admin Bearer token (JWT with admin scope) required.

**Query Parameters:**

| Name | Type | Default | Description |
|---|---|---|---|
| `page` | integer | `1` | Page number (1-indexed) |
| `per_page` | integer | `50` | Results per page (max: 100) |
| `action_type` | string | — | Filter by action type (e.g., `resolve`, `ingest`, `lookup`) |
| `start_date` | string (ISO 8601) | — | Inclusive start date filter |
| `end_date` | string (ISO 8601) | — | Inclusive end date filter |

**Response (200 OK):**

```json
{
  "data": [
    {
      "log_id": "log_a1b2c3d4",
      "action": "resolve",
      "actor": "svc_event_resolver",
      "target_id": "EVT-0042",
      "timestamp": "2026-04-01T23:45:00Z",
      "details": {
        "context_applied": true,
        "style_ref": "STY-0003"
      }
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 50,
    "total": 1
  }
}
```

**Error Codes:** `400` — Invalid query parameters. `401` — Unauthorized. `403` — Forbidden (non-admin token). `500` — Internal server error.

---

## 4. Error Format

All error responses use a consistent envelope:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Event EVT-9999 not found",
    "request_id": "req_f47ac10b-58cc-4372-a567-0e02b2c3d479"
  }
}
```

### Error Code Reference

| HTTP Status | Code | Description |
|---|---|---|
| 400 | `BAD_REQUEST` | Malformed request, invalid parameters, or schema validation failure |
| 401 | `UNAUTHORIZED` | Missing, expired, or invalid authentication credentials |
| 403 | `FORBIDDEN` | Valid credentials but insufficient permissions |
| 404 | `NOT_FOUND` | Requested resource does not exist |
| 409 | `CONFLICT` | Request conflicts with current resource state |
| 429 | `RATE_LIMITED` | Rate limit exceeded; retry after `X-RateLimit-Reset` |
| 500 | `INTERNAL_ERROR` | Unexpected server error; include `request_id` in bug reports |

---

## 5. Security

- **No raw content in responses.** All artifact references are opaque identifiers (`artifact_id`, `cid`). Content is never embedded inline.
- **Telemetry sanitization.** PII is stripped before storage. Session IDs are opaque and non-reversible.
- **CORS.** Configurable allowed origins per deployment. Preflight responses are cached for 1 hour (`Access-Control-Max-Age: 3600`).
- **Content-Type.** All responses use `Content-Type: application/json; charset=utf-8`.
- **Transport.** TLS 1.2+ required. Plain HTTP connections are rejected.

---

## 6. Versioning & Deprecation

- **URI path versioning:** `/v1`, `/v2`, etc.
- **Deprecation policy:** Minimum 6-month notice before any version is sunset.
- **Sunset header:** Deprecated endpoints include the `Sunset` HTTP header with the retirement date per [RFC 8594](https://www.rfc-editor.org/rfc/rfc8594).
- **Changelog:** Breaking changes are documented in `CHANGELOG.md` in the repository root.

---

## Appendix A: Schema URI Table

| Short Name | Full URI |
|---|---|
| `invariants_v1` | `schema://Horror.Place/core/schemas/invariants_v1` |
| `entertainment_metrics_v1` | `schema://Horror.Place/core/schemas/entertainment_metrics_v1` |
| `stylecontract_v1` | `schema://Horror.Place/core/schemas/stylecontract_v1` |
| `persona_v1` | `schema://Horror.Place/core/schemas/persona_v1` |
| `region_v1` | `schema://Horror.Place/core/schemas/region_v1` |
| `audit_entry_v1` | `schema://Horror.Place/core/schemas/audit_entry_v1` |

## Appendix B: Pagination Format

All paginated endpoints return a `pagination` object:

```json
{
  "page": 1,
  "per_page": 50,
  "total": 128
}
```

- `page` — Current page number (1-indexed).
- `per_page` — Number of results per page.
- `total` — Total number of matching records.

## Appendix C: Rate Limit Headers

| Header | Type | Example | Description |
|---|---|---|---|
| `X-RateLimit-Limit` | integer | `100` | Max requests in current window |
| `X-RateLimit-Remaining` | integer | `73` | Requests remaining |
| `X-RateLimit-Reset` | integer (epoch) | `1743566460` | UTC epoch when window resets |

---

*End of Horror.Place Public API Specification v1*
FILE 2: public-api/H.CIC_stub.lua

-------------------------------------------------------------------------------
--- H.CIC — Horror.Place Core Integrity Check (Stub)
---
--- Provides public-facing validation utilities for opaque artifact references,
--- registry lookups, and payload integrity checks. This module operates
--- exclusively on opaque references — it never handles or exposes raw content.
---
--- @module H.CIC
--- @version 0.1.0
--- @license Proprietary
--- @copyright Horror.Place 2026. All rights reserved.
---
--- WARNING: This is a stub implementation for the public API surface.
--- Production internals are not included in this distribution.
-------------------------------------------------------------------------------

local H_CIC = {}

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

--- Canonical schema URI prefix for all Horror.Place schemas.
--- @field SCHEMA_PREFIX string
H_CIC.SCHEMA_PREFIX = "schema://Horror.Place/core/schemas/"

--- Supported registry types and their ID prefixes.
--- @table REGISTRY_TYPES
H_CIC.REGISTRY_TYPES = {
    events   = { prefix = "EVT", description = "Event invariants registry" },
    regions  = { prefix = "RGN", description = "Region definitions registry" },
    styles   = { prefix = "STY", description = "Style contracts registry" },
    personas = { prefix = "PRS", description = "Persona definitions registry" },
}

-------------------------------------------------------------------------------
-- Internal Helpers
-------------------------------------------------------------------------------

--- Check whether a value is a non-empty string.
--- @param value any
--- @return boolean
local function is_non_empty_string(value)
    return type(value) == "string" and #value > 0
end

--- Check whether a string starts with the given prefix.
--- @param str string
--- @param prefix string
--- @return boolean
local function starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Validate an artifact reference pair.
---
--- Checks that `artifact_id` is a non-empty string and that `schema_ref`
--- begins with the canonical Horror.Place schema prefix. This is a stub
--- implementation: it performs format checks only and does not verify that
--- the referenced artifact or schema actually exists.
---
--- @param artifact_id string  Opaque artifact identifier (e.g. "art_a1b2c3d4e5f6")
--- @param schema_ref  string  Full schema URI (e.g. "schema://Horror.Place/core/schemas/invariants_v1")
--- @return boolean valid  `true` if format checks pass
--- @return string|nil error  Error message if validation fails, `nil` otherwise
function H_CIC.validate_reference(artifact_id, schema_ref)
    if not is_non_empty_string(artifact_id) then
        return false, "artifact_id must be a non-empty string"
    end

    if not is_non_empty_string(schema_ref) then
        return false, "schema_ref must be a non-empty string"
    end

    if not starts_with(schema_ref, H_CIC.SCHEMA_PREFIX) then
        return false, "schema_ref must start with canonical prefix: " .. H_CIC.SCHEMA_PREFIX
    end

    -- Stub: format checks passed; no backend verification.
    return true, nil
end

--- Look up an entry in a named registry.
---
--- Validates that `registry_type` is one of the known registry types and
--- that `entry_id` is a non-empty string. Returns a stub entry table.
--- In the production implementation this would query the registry backend.
---
--- @param registry_type string  Registry name: "events", "regions", "styles", or "personas"
--- @param entry_id      string  Entry identifier (e.g. "EVT-0001")
--- @return table|nil entry  Stub entry table `{id, registry, status}`, or `nil` on error
--- @return string|nil error  Error message if lookup fails, `nil` otherwise
function H_CIC.lookup(registry_type, entry_id)
    if not is_non_empty_string(registry_type) then
        return nil, "registry_type must be a non-empty string"
    end

    if not H_CIC.REGISTRY_TYPES[registry_type] then
        local valid_types = {}
        for k, _ in pairs(H_CIC.REGISTRY_TYPES) do
            valid_types[#valid_types + 1] = k
        end
        table.sort(valid_types)
        return nil, "unknown registry_type '" .. registry_type
            .. "'; valid types: " .. table.concat(valid_types, ", ")
    end

    if not is_non_empty_string(entry_id) then
        return nil, "entry_id must be a non-empty string"
    end

    -- Stub: return a placeholder entry without backend lookup.
    return {
        id       = entry_id,
        registry = registry_type,
        status   = "stub",
    }, nil
end

--- Check payload integrity for raw-content leakage.
---
--- Scans all string values in the provided `payload` table for patterns
--- that may indicate raw content exposure. This is a stub implementation
--- with a minimal set of heuristic patterns.
---
--- @param payload table  The payload table to inspect
--- @return boolean clean     `true` if no violations found
--- @return table|nil violations  Array of violation description strings, or `nil` if clean
function H_CIC.check_integrity(payload)
    if type(payload) ~= "table" then
        return false, { "payload must be a table" }
    end

    local violations = {}

    -- Stub heuristic patterns that might indicate raw content leakage.
    local raw_patterns = {
        { pattern = "<[hH][tT][mM][lL]",  label = "HTML content detected" },
        { pattern = "<script",             label = "Script tag detected" },
        { pattern = "data:[^;]+;base64,",     label = "Base64 data URI detected" },
        { pattern = "BEGIN .+ KEY",           label = "Cryptographic key material detected" },
    }

    --- Recursively scan table values.
    local function scan(tbl, path)
        for k, v in pairs(tbl) do
            local current_path = path .. "." .. tostring(k)
            if type(v) == "string" then
                for _, rule in ipairs(raw_patterns) do
                    if v:find(rule.pattern) then
                        violations[#violations + 1] = rule.label
                            .. " at " .. current_path
                    end
                end
            elseif type(v) == "table" then
                scan(v, current_path)
            end
        end
    end

    scan(payload, "root")

    if #violations > 0 then
        return false, violations
    end

    return true, nil
end

--- Batch-validate an array of artifact reference pairs.
---
--- Validates each entry in `entries` using `validate_reference`. Each entry
--- must be a table with `artifact_id` and `schema_ref` fields.
---
--- @param entries table  Array of tables, each with `artifact_id` (string) and `schema_ref` (string)
--- @return table results  Array of result tables `{index, artifact_id, valid, error}`
function H_CIC.batch_validate(entries)
    if type(entries) ~= "table" then
        return {{ index = 0, artifact_id = nil, valid = false, error = "entries must be a table" }}
    end

    local results = {}

    for i, entry in ipairs(entries) do
        local result = { index = i, artifact_id = nil, valid = false, error = nil }

        if type(entry) ~= "table" then
            result.error = "entry at index " .. i .. " must be a table"
        else
            result.artifact_id = entry.artifact_id
            local ok, err = H_CIC.validate_reference(entry.artifact_id, entry.schema_ref)
            result.valid = ok
            result.error = err
        end

        results[#results + 1] = result
    end

    return results
end

return H_CIC
FILE 3: public-api/H.resolve_event_spec.md

# H.resolve_event — Event Resolution Specification

**Version:** 1.0.0-draft
**Last Updated:** 2026-04-02
**Status:** Draft

---

## 1. Purpose

The `resolve_event` operation resolves a Horror.Place event identifier to its
full opaque specification. The response contains schema references, artifact
identifiers, content-addressed hashes, metadata, and an optional style
contract — but **never** raw content. All returned values are opaque
references suitable for downstream processing without content exposure.

---

## 2. Endpoint

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Path** | `/v1/events/resolve` |
| **Authentication** | Bearer token (JWT) |
| **Rate Limit** | 100 requests per minute |
| **Content-Type** | `application/json` |

---

## 3. Request Schema

```json
{
  "type": "object",
  "required": ["event_id"],
  "properties": {
    "event_id": {
      "type": "string",
      "pattern": "^EVT-\\d{4}$",
      "description": "Event identifier in the format EVT-NNNN."
    },
    "context": {
      "type": "object",
      "description": "Optional resolution context. When provided, the response includes context-aware metadata and style contract information.",
      "properties": {
        "region_ref": {
          "type": "string",
          "description": "Region registry ID (e.g. RGN-0007). Must be a valid entry in the regions registry."
        },
        "style_ref": {
          "type": "string",
          "description": "Style registry ID (e.g. STY-0003). Must be a valid entry in the styles registry."
        }
      },
      "additionalProperties": false
    }
  },
  "additionalProperties": false
}
```

---

## 4. Response Schema

```json
{
  "type": "object",
  "required": ["event_id", "schema_ref", "artifact_id", "cid", "metadata"],
  "properties": {
    "event_id": {
      "type": "string",
      "description": "The resolved event identifier."
    },
    "schema_ref": {
      "type": "string",
      "description": "Full schema URI for the event invariant."
    },
    "artifact_id": {
      "type": "string",
      "description": "Opaque artifact identifier."
    },
    "cid": {
      "type": "string",
      "description": "Content-addressed identifier (CID) for integrity verification."
    },
    "metadata": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "status": { "type": "string", "enum": ["draft", "active", "archived"] },
        "resolved_at": { "type": "string", "format": "date-time" }
      },
      "required": ["name", "status", "resolved_at"]
    },
    "style_contract": {
      "type": ["object", "null"],
      "description": "Present only when context.style_ref is provided.",
      "properties": {
        "style_id": { "type": "string" },
        "schema_ref": { "type": "string" }
      }
    }
  }
}
```

---

## 5. Validation Rules

1. **`event_id`** must match the pattern `^EVT-\d{4}$`. Any other format results in a `400` error.
2. **`context.region_ref`**, if provided, must be a valid ID in the `regions` registry. An unknown region ID results in a `400` error.
3. **`context.style_ref`**, if provided, must be a valid ID in the `styles` registry. An unknown style ID results in a `400` error.
4. **No additional properties** are permitted in the request body or the context object.
5. The resolved event must have status `active` or `draft`. Archived events return `404`.

---

## 6. Error Responses

| HTTP Status | Code | Condition |
|---|---|---|
| 400 | `BAD_REQUEST` | Invalid `event_id` format, unknown context reference, or malformed JSON |
| 401 | `UNAUTHORIZED` | Missing or invalid Bearer token |
| 404 | `NOT_FOUND` | Event ID does not exist or is archived |
| 429 | `RATE_LIMITED` | Rate limit exceeded |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

Error response body format:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Event EVT-9999 not found",
    "request_id": "req_f47ac10b-58cc-4372-a567-0e02b2c3d479"
  }
}
```

---

## 7. Example

### Request

```http
POST /v1/events/resolve HTTP/1.1
Host: api.horror.place
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "event_id": "EVT-0042",
  "context": {
    "region_ref": "RGN-0007",
    "style_ref": "STY-0003"
  }
}
```

### Response

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1743566460

{
  "event_id": "EVT-0042",
  "schema_ref": "schema://Horror.Place/core/schemas/invariants_v1",
  "artifact_id": "art_e7f8a9b0c1d2",
  "cid": "bafybeigdyrzt5sfp7udm7hu76uh7y26nf3efuylqabf3oclgtqy55fbzdi",
  "metadata": {
    "name": "Opaque Event Reference",
    "status": "active",
    "resolved_at": "2026-04-02T00:00:00Z"
  },
  "style_contract": {
    "style_id": "STY-0003",
    "schema_ref": "schema://Horror.Place/core/schemas/stylecontract_v1"
  }
}
```

---

## 8. Security Guarantees

- The response **never** contains raw event content. All references are opaque identifiers.
- Artifact IDs and CIDs are non-reversible references; content retrieval requires separate authorized access.
- Telemetry for resolution requests is sanitized: PII is stripped, and only opaque session context is logged.
- All transport is over TLS 1.2+.

---

## 9. Related Schemas

| Schema | URI |
|---|---|
| Event Invariants | `schema://Horror.Place/core/schemas/invariants_v1` |
| Style Contract | `schema://Horror.Place/core/schemas/stylecontract_v1` |
| Region Definition | `schema://Horror.Place/core/schemas/region_v1` |

---

*End of H.resolve_event Specification v1.0.0-draft*
FILE 4: public-api/H.metrics_spec.md

# H.metrics — Entertainment Metrics Specification

**Version:** 1.0.0-draft
**Last Updated:** 2026-04-02
**Status:** Draft

---

## 1. Purpose

The Horror.Place Entertainment Metrics system provides endpoints for ingesting
and retrieving audience engagement metrics. All data conforms to the
`entertainment_metrics_v1` schema. The system enforces telemetry sanitization,
prohibits raw content references in payloads, requires aggregation for
retrieval, and guarantees that no individual event tracking is exposed.

---

## 2. Endpoints

### 2.1 POST /v1/metrics/ingest

**Description:** Submit entertainment metrics for a session.

| Property | Value |
|---|---|
| **Method** | `POST` |
| **Path** | `/v1/metrics/ingest` |
| **Authentication** | Bearer token (JWT) |
| **Rate Limit** | 100 requests per minute |
| **Content-Type** | `application/json` |

#### Request Body

The request body must conform to the `entertainment_metrics_v1` schema:

```json
{
  "type": "object",
  "required": ["session_id", "timestamp", "metrics"],
  "properties": {
    "session_id": {
      "type": "string",
      "description": "Opaque session identifier."
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp of the metrics snapshot."
    },
    "metrics": {
      "type": "object",
      "required": ["engagement", "tension_curve", "pacing", "completion", "satisfaction"],
      "properties": {
        "engagement": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Engagement score in the range [0, 1]."
        },
        "tension_curve": {
          "type": "array",
          "items": { "type": "number", "minimum": 0, "maximum": 1 },
          "minItems": 2,
          "description": "Ordered array of tension values (min 2 points). Each value in [0, 1]."
        },
        "pacing": {
          "type": "string",
          "enum": ["accelerating", "steady", "decelerating", "erratic"],
          "description": "Pacing classification label."
        },
        "completion": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Completion rate in the range [0, 1]."
        },
        "satisfaction": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Satisfaction index in the range [0, 1]."
        }
      }
    }
  }
}
```

#### Response (202 Accepted)

```json
{
  "accepted": true,
  "metric_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "ingested_at": "2026-04-01T22:15:01Z"
}
```

---

### 2.2 GET /v1/metrics/summary/{session_id}

**Description:** Retrieve aggregated metrics summary for a session.

| Property | Value |
|---|---|
| **Method** | `GET` |
| **Path** | `/v1/metrics/summary/{session_id}` |
| **Authentication** | Bearer token (JWT) |
| **Rate Limit** | 100 requests per minute |
| **Content-Type** | `application/json` |

#### Path Parameters

| Name | Type | Description |
|---|---|---|
| `session_id` | string | Opaque session identifier |

#### Response (200 OK)

```json
{
  "session_id": "sess_7f8a9b0c1d2e",
  "summary": {
    "engagement_avg": 0.82,
    "tension_peak": 0.93,
    "tension_valley": 0.18,
    "pacing_label": "accelerating",
    "audience": {
      "completion_rate": 0.95,
      "repeat_rate": 0.22,
      "satisfaction_index": 0.88
    }
  },
  "computed_at": "2026-04-01T23:00:00Z"
}
```

---

## 3. Telemetry Sanitization Rules

The following rules are enforced at the ingestion boundary and apply to all
stored and retrieved metrics data:

1. **PII stripping.** All personally identifiable information is stripped from payloads before storage. The ingestion pipeline rejects payloads containing detectable PII patterns (email addresses, IP addresses, names in known fields).

2. **Opaque session IDs.** `session_id` values are opaque, non-reversible identifiers. They must not encode or embed user-identifiable information.

3. **No raw content references.** Metrics payloads must not contain artifact content, HTML, script tags, data URIs, or other raw content. Payloads failing integrity checks are rejected with `400`.

4. **Aggregation requirement.** The summary endpoint (`GET /v1/metrics/summary/{session_id}`) returns only aggregated statistics. Individual data point tracking or per-event breakdowns are not exposed through the public API.

5. **Retention policy:**
   - **Raw metrics:** Retained for 90 days, then purged.
   - **Aggregated summaries:** Retained for 1 year, then purged.

---

## 4. Validation Rules

| Rule | Field(s) | Constraint |
|---|---|---|
| Range check | `engagement`, `completion`, `satisfaction`, each element of `tension_curve` | Must be in the range [0, 1] inclusive |
| Minimum points | `tension_curve` | Must contain at least 2 data points |
| Enum validation | `pacing` | Must be one of: `accelerating`, `steady`, `decelerating`, `erratic` |
| Required fields | `session_id`, `timestamp`, `metrics` | Must be present and non-null |
| Timestamp format | `timestamp` | Must be valid ISO 8601 date-time |
| Schema conformance | Entire body | Must validate against `entertainment_metrics_v1` JSON Schema |

---

## 5. Error Responses

| HTTP Status | Code | Condition |
|---|---|---|
| 400 | `BAD_REQUEST` | Schema validation failure, out-of-range values, invalid pacing label, PII detected, or raw content detected |
| 401 | `UNAUTHORIZED` | Missing or invalid Bearer token |
| 404 | `NOT_FOUND` | Session ID not found (summary endpoint only) |
| 429 | `RATE_LIMITED` | Rate limit exceeded |
| 500 | `INTERNAL_ERROR` | Unexpected server error |

Error response body format:

```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "metrics.engagement must be in range [0, 1]; received 1.5",
    "request_id": "req_c3d4e5f6a7b8"
  }
}
```

---

## 6. Examples

### 6.1 Ingest Request

```http
POST /v1/metrics/ingest HTTP/1.1
Host: api.horror.place
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "session_id": "sess_7f8a9b0c1d2e",
  "timestamp": "2026-04-01T22:15:00Z",
  "metrics": {
    "engagement": 0.82,
    "tension_curve": [0.30, 0.52, 0.75, 0.93, 0.60, 0.18],
    "pacing": "accelerating",
    "completion": 0.95,
    "satisfaction": 0.88
  }
}
```

### 6.2 Ingest Response

```http
HTTP/1.1 202 Accepted
Content-Type: application/json; charset=utf-8
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 94
X-RateLimit-Reset: 1743566460

{
  "accepted": true,
  "metric_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "ingested_at": "2026-04-01T22:15:01Z"
}
```

### 6.3 Summary Request

```http
GET /v1/metrics/summary/sess_7f8a9b0c1d2e HTTP/1.1
Host: api.horror.place
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 6.4 Summary Response

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1743566520

{
  "session_id": "sess_7f8a9b0c1d2e",
  "summary": {
    "engagement_avg": 0.82,
    "tension_peak": 0.93,
    "tension_valley": 0.18,
    "pacing_label": "accelerating",
    "audience": {
      "completion_rate": 0.95,
      "repeat_rate": 0.22,
      "satisfaction_index": 0.88
    }
  },
  "computed_at": "2026-04-01T23:00:00Z"
}
```

---

## 7. Security Guarantees

- **No raw content.** Metrics payloads and responses contain numeric values, opaque identifiers, and enum labels only. No artifact content is accepted or returned.
- **Integrity checking.** All inbound payloads are scanned for raw content patterns via `H.CIC.check_integrity` before processing.
- **Transport security.** TLS 1.2+ required. Plain HTTP connections are rejected.
- **Audit trail.** All ingest and summary requests are logged to the audit system with sanitized metadata (no PII, no raw content).

---

## 8. Related Schemas

| Schema | URI |
|---|---|
| Entertainment Metrics | `schema://Horror.Place/core/schemas/entertainment_metrics_v1` |
| Audit Entry | `schema://Horror.Place/core/schemas/audit_entry_v1` |

---

*End of H.metrics Specification v1.0.0-draft*
