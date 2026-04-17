# Horror.Place Public Core – Implementation Wiring Guide v1

This document defines concrete coding steps, file placements, and wiring patterns for the Horror.Place public core repository. It is intended as an implementation map for engine teams and downstream repositories (Orchestrator, Constellation-Contracts, Codebase-of-Death, Atrocity-Seeds, etc.).

The guide focuses on:

- Engine startup contracts and failure modes.  
- Rivers of Blood charter enforcement via schemas and CI.  
- Surprise director stubs and telemetry wiring.  
- Neutral Void mode definitions.  
- CI connections and cross-repo integration.

No raw content, assets, or private heuristics are included here.

***

## 1. Engine Startup Contract and Failure Modes

### 1.1. Invariants: runtime startup rules

**File:** `coreschemas/invariantsv1.json`

Extend the `rules` array to encode minimum startup behavior. Add rules along these lines (IDs and descriptions are examples; tune as needed):

- `R-RUN-001`  
  - `description`: Engine must not enter the main loop if no registries validate against their schemas.  
  - `enforcement`: `"runtime_gate"`  
  - `severity`: `"critical"`  
  - `automatedTestHook`: `"engine-startup-check"`

- `R-RUN-002`  
  - `description`: Neutral Void mode must be explicitly declared when running without vault-fed content.  
  - `enforcement`: `"runtime_gate"`  
  - `severity`: `"high"`  
  - `automatedTestHook`: `"engine-startup-check"`

These rules do not implement behavior; they define machine-readable invariants that a startup script and engines must respect.

### 1.2. Engine startup preflight script

**File (new):** `scripts/engine_startup_check.py`

Purpose: provide a canonical, schema-driven preflight for engines to determine whether they can start and which startup mode is allowed.

Implementation outline:

- Load schemas from `coreschemas/` (at minimum: `invariantsv1.json`, `entertainmentmetricsv1.json`, `stylecontractv1.json`).  
- Load registries from `coreregistry/*.json`.  
- For each non-empty line in each registry file:
  - Parse as JSON.  
  - Resolve `schemaref` to a local schema.  
  - Validate entry against the schema (mirror logic from `.circleci` schema-validation job).  
- Compute:
  - `has_regions`, `has_styles`: at least one valid entry exists in those registries.  
  - `has_non_placeholder_entries`: at least one entry where `metadata.status` is not `"draft"` or `tags` does not contain `"placeholder"` only.  
  - `has_neutral_entries`: presence of canonical Neutral Void entries (see section 4).

Mode logic:

- If schemas or registries are missing or validation fails:  
  - Exit non-zero. No mode returned.  
- If non-placeholder entries exist and all validations pass:  
  - Print `startup_mode=normal` (or return equivalent status).  
- If only placeholder/neutral entries exist and validations pass:  
  - Print `startup_mode=neutral-void`.

This script is the reference implementation for the `R-RUN-001` and `R-RUN-002` invariants.

### 1.3. Documentation for engine consumers

**File:** `README.md`

Add a “Runtime Consumers / Engine Startup Contract” section instructing engine implementers to:

- Run `python scripts/engine_startup_check.py` before entering the main loop.  
- Treat:
  - No mode (non-zero exit) as a hard failure – engine must refuse to launch.  
  - `startup_mode=neutral-void` as a valid but restricted mode (see section 4).  
  - `startup_mode=normal` as full operation.

Engines should log the chosen mode and any failure reasons for auditability.

### 1.4. Acceptance test for startup contract

**File:** `audit/acceptance-tests.md`

Add a new test definition:

- `AT-009 Engine Startup Contract`  
  - Preconditions:
    - `coreschemas/*.json` present and valid.  
    - `coreregistry/*.json` present.  
  - Steps:
    1. Run `scripts/engine_startup_check.py` with full registries (non-placeholder entries present).  
    2. Run it with only placeholder/neutral entries.  
    3. Run it after temporarily moving/removing registries to simulate missing data.  
  - Expected:
    - Step 1: reports `startup_mode=normal`.  
    - Step 2: reports `startup_mode=neutral-void`.  
    - Step 3: exits non-zero (startup forbidden).

***

## 2. Rivers of Blood Charter: Schema and CI Wiring

The Rivers of Blood charter is enforced at Tier-1 via schemas, invariants, and CI, not via asset inspection.

### 2.1. Invariants: Rivers of Blood rule group

**File:** `coreschemas/invariantsv1.json`

Add a group of rules representing Rivers of Blood constraints, for example:

- `R-ROB-001`  
  - `description`: Sexual Violence Index (SVI) must always be 0 across all tiers.  
  - `enforcement`: `"schemavalidation"` and `"runtime_gate"`  
  - `severity`: `"critical"`  
  - `automatedTestHook`: `"rivers-of-blood-schema-check"`

- `R-ROB-002`  
  - `description`: Explicitness caps must not exceed chartered ranges for Emax.  
  - `enforcement`: `"schemavalidation"`  
  - `severity`: `"high"`  
  - `automatedTestHook`: `"explicitness-ceiling-check"`

- `R-ROB-003`  
  - `description`: After any event classified above GXI high threshold, cooldown constraints must be observed before another high-GXI event.  
  - `enforcement`: `"runtime_gate"`  
  - `severity`: `"high"`  
  - `automatedTestHook`: `"boundary-runtime-check"`

These rules anchor the charter numerically. The actual policy schemas live in Constellation-Contracts.

### 2.2. Policy schema (Constellation-Contracts)

**Repository:** `HorrorPlace-Constellation-Contracts`  
**File (suggested):** `schemas/policy/rivers-of-blood-charter.v1.json`

Implementation outline:

- Define per-tier caps for:
  - `SVI_max`, `GXI_max`, `HVI_max`, `NSI_max`.  
  - `Emax` coefficients (e.g., `C`, `R`, `H` parameters).  
- Include references to:
  - Invariants schema spine.  
  - Entertainment metrics schema.  
- Include `deadledgerref` fields where higher-risk settings require proof envelopes.

### 2.3. Boundary decision telemetry schema

**Repository:** `HorrorPlace-Constellation-Contracts`  
**File (suggested):** `schemas/telemetry/content-boundary-judgment-v1.json`

Fields:

- `eventId`, `sessionId`, `timestamp`.  
- `indices`: SVI, HVI, GXI, NSI, E, Emax, region/tier references.  
- `decision`: `"allow" | "soften" | "refuse" | "imply"`.  
- `policyRef`: reference to the Rivers of Blood policy/config in effect.

Engines and boundary modules must log NDJSON events conforming to this schema.

### 2.4. Audit plan updates

**File:** `audit/api-audit-plan.md`

Add audit tests:

- `AUD-ROB-001 Rivers of Blood Invariants Present`  
  - Verify that `invariantsv1.json` declares R-ROB rules with non-empty descriptions, allowed `enforcement` values, and proper severity.

- `AUD-ROB-002 SVI Bounds`  
  - Scan all applicable schemas (in core and Constellation-Contracts) for SVI fields and verify that public-tier configurations do not allow SVI > 0.

- `AUD-ROB-003 Explicitness Cap Bounds`  
  - Validate that `rivers-of-blood-charter.v1.json` and related policy schemas keep Emax coefficients within pre-agreed governance ranges.

### 2.5. Acceptance test for Rivers invariants

**File:** `audit/acceptance-tests.md`

Add:

- `AT-010 Rivers of Blood Invariants`  
  - Preconditions: `coreschemas/invariantsv1.json` present.  
  - Steps:
    1. Load invariants.  
    2. Assert presence of R-ROB rules with required fields.  
  - Expected:
    - All R-ROB rules exist, with correct `enforcement` and `severity` values.

***

## 3. Surprise Director: Stub and Telemetry

The surprise director’s real heuristics and scare cadence must not live in the public core. Only a stub and schemas are defined here.

### 3.1. Director instruction schema

**File (new):** `coreschemas/director-instructionv1.json`

Schema concept:

- `$id`: `schema.Horror.Place.core.schemas.director-instructionv1`  
- `type`: `"object"`  
- `required`: `["instructionId", "schemaref", "sessionId", "timestamp", "regionId", "tileId", "requestType", "intensity"]`  

Properties:

- `instructionId`: string, UUID format.  
- `schemaref`: const `"schema.Horror.Place.core.schemas.director-instructionv1"`.  
- `sessionId`: string, UUID format.  
- `timestamp`: string, date-time.  
- `regionId`: string.  
- `tileId`: string.  
- `requestType`: string enum, e.g., `["surprise", "relief", "foreshadow", "silence"]`.  
- `intensity`: number, `minimum: 0`, `maximum: 1`.  
- `cooldownUntil`: string, date-time (optional).  
- `tags`: array of strings (optional).

This schema defines the structure of a “director instruction” passed into the engine.

### 3.2. Director decision telemetry schema

**File (new, suggested for Constellation-Contracts or core telemetry namespace):**  
`coreschemas/director-decision-eventv1.json` or `schemas/telemetry/director-decision-eventv1.json` in Constellation-Contracts.

Schema concept:

- `eventId`: string.  
- `sessionId`: string, UUID.  
- `timestamp`: string, date-time.  
- `metricsSnapshot`: object with fields like `UEC`, `EMD`, `STCI`, `CDL`, `ARR`, `DET`, etc.  
- `requested`: object matching `director-instructionv1`.  
- `granted`: object matching `director-instructionv1` (possibly with reduced intensity or changed type).  
- `decision`: enum `"executed" | "softened" | "skipped" | "queued"`.  
- `policyRefs`: array of strings referencing relevant policies (Rivers of Blood, budgets, consent).

### 3.3. Public Lua stub API

**File (new):** `public-api/hdirector.lua`

Stub implementation pattern:

- Expose `H` namespace functions without heuristics.

Signatures:

- `H.Director.requestBeat(sessionId, context)`  
  - `sessionId`: string (UUID).  
  - `context`: table containing at least `regionId`, `tileId`, and a metrics snapshot.  
  - Behavior in public core:
    - Return `{ ok = false, data = nil, error = { code = "DIRECTOR_NOT_IMPLEMENTED", message = "Director implementation is provided by private vaults." } }`.  
    - No decision-making logic.

- `H.Director.logDecision(sessionId, decisionEnvelope)`  
  - `decisionEnvelope`: table expected to validate against `director-decision-eventv1.json`.  
  - Behavior in public core:
    - No-op or basic shape validation only.  
    - Return `{ ok = true, data = {}, error = nil }`.

This stub defines the calling convention; real logic is provided in private engine/vault repos.

### 3.4. Private director implementation

**Repository:** `HorrorPlace-Codebase-of-Death` or equivalent engine repo.  
**File (example):** `runtime/director/surprisedirector.lua`

Responsibilities (in private repo):

- Implement actual heuristics for scare cadence, randomization, cooldowns, and integration with consent, budget, and selector modules.  
- Replace or override `H.Director` from the public stub at build time (e.g., via module path precedence, dependency injection, or packaging).

The public core should not reference this file path; it only defines the interface.

### 3.5. CI guard against director logic in public core

Optional but recommended: extend CI in Constellation-Contracts or a tooling repo to ensure the public core never contains real director logic.

Pattern:

- Scan `horror-place-core/public-api/` for files named `*director*.lua`.  
- Assert that:
  - Functions `H.Director.requestBeat` and `H.Director.logDecision` exist.  
  - File length / number of executable lines stays below a small threshold.  
  - No references to internal engine modules or private repos are present.  
- If the stub grows beyond its intended scope, fail CI.

***

## 4. Neutral Void Mode Definitions

Neutral Void is a defined degraded mode with minimal content, used when Orchestrator is unreachable but registries and schemas validate.

### 4.1. Neutral Void region entry

**File:** `coreregistry/regions.json`

Add a single-line NDJSON entry (example structure):

```json
{"id":"REG-NEUTRAL-VOID","schemaref":"schema.Horror.Place.core.schemas.stylecontractv1","artifactid":"art-neutral-region-void","cid":"bafy-neutral-region-void","metadata":{"name":"Neutral Void","status":"neutral","createdat":"2026-04-02T00:00:00Z","tags":["neutral","void","nexus"]}}
```

Adjust `artifactid`/`cid` to be opaque placeholders consistent with repository rules.

### 4.2. Neutral Void style entry

**File:** `coreregistry/styles.json`

Add a style entry for Neutral Void:

```json
{"id":"STY-NEUTRAL-VOID","schemaref":"schema.Horror.Place.core.schemas.stylecontractv1","artifactid":"art-neutral-style-void","cid":"bafy-neutral-style-void","metadata":{"name":"Neutral Void Style","status":"neutral","createdat":"2026-04-02T00:00:00Z","tags":["neutral","void","low-intensity"]}}
```

The corresponding style contract referenced by this ID (in a vault repo) should use low-intensity profiles (e.g., `mixprofile: "silenceheavy"`).

### 4.3. Startup script binding

**File:** `scripts/engine_startup_check.py`

Extend script logic:

- After validating registries, verify presence of `REG-NEUTRAL-VOID` and `STY-NEUTRAL-VOID`.  
- When determining `startup_mode`:
  - If only entries with `status: "draft"` or `status: "neutral"` exist and Neutral Void region/style are present, set mode `neutral-void`.

### 4.4. Engine behavior contract

**File:** `README.md` (Runtime Consumers section)

Document that engines, when launched in `neutral-void` mode, must:

- Load `REG-NEUTRAL-VOID` as the active region and `STY-NEUTRAL-VOID` as the style.  
- Disable AI / surprise director and avoid dynamic scare scheduling.  
- Use minimal geometry and audio consistent with the Neutral Void style contract.

***

## 5. CI and Cross-Repo Wiring

### 5.1. Existing core CI jobs

**File:** `.circleci/config.yml`

Continue to rely on these jobs:

- `schema-validation`: validate all registry records against their declared schemas.  
- `registry-linter`: enforce NDJSON structure, required fields, canonical `schemaref` prefix.  
- `api-leak-test`: ensure no raw content, asset URLs, base64 blobs, or raw media references in core, public-api, or docs.  
- `lua-lint`: run `luacheck` on all `public-api/*.lua` stubs.

### 5.2. New CI hooks in Constellation-Contracts (optional)

**Repository:** `HorrorPlace-Constellation-Contracts`  
**File (example):** `.github/workflows/core-contract-check.yml`

Workflow concept:

- Clone `Horror.Place` core as a dependency.  
- Run:
  - `python scripts/engine_startup_check.py`  
  - Any Rivers-of-Blood-related validation scripts.  
- Assert that:
  - Invariants include required `R-RUN-*` and `R-ROB-*` rules.  
  - Director schemas exist and validate.  
  - Neutral Void entries are present in registries.

Failures here indicate contract drift between governance and core.

### 5.3. Cross-repo roles summary

Maintain a short reference in this document or a separate governance doc:

- `Horror.Place` (this repo): Tier-1 schemas, registries, public API stubs, audit artifacts.  
- `Horror.Place-Orchestrator`: registry update service; consumes this repo’s schemas and registries.  
- `HorrorPlace-Constellation-Contracts`: governance schemas, policy documents, Lua API specifications, cross-repo CI.  
- `HorrorPlace-Codebase-of-Death`: engine runtime logic, including surprise director implementation, intensity algorithms.  
- `HorrorPlace-Atrocity-Seeds`: PCG seed vault; produces artifacts referencing core schemas and registries.

No private file paths or raw content should be referenced from within Horror.Place core.

***

## 6. Usage Pattern

To use this wiring guide across the constellation:

1. Implement and maintain all schemas, scripts, and stubs specified here in `Horror.Place`.  
2. In Orchestrator and vault repos, treat these as authoritative contracts for:
   - Registry formats.  
   - Startup conditions.  
   - Rivers of Blood constraints.  
   - Director API surfaces and telemetry shapes.  
3. In Constellation-Contracts, maintain alignment by:
   - Referencing core schemas via canonical `schemaref`.  
   - Keeping policy schemas and telemetry envelopes compatible with invariants and stubs.  
   - Running cross-repo CI to detect contract drift.

This guide should be updated whenever the public contracts change, and versioned alongside schema versions (e.g., `v1`, `v2`) to keep engine and vault implementations in sync.
