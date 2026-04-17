---
invariants_used: [CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI]
metrics_used: [UEC, EMD, STCI, CDL, ARR]
tiers: [standard]
deadledger_surface: []
---

# Horror.Place Core Public Contracts: Engine, Charter, Director, Orchestrator, CI

This document defines the Tier 1 public-core contracts for Horror.Place as a schema-first, zero-raw-content repository, focusing on engine startup, Rivers of Blood charter enforcement, Surprise Director stubs, Orchestrator integration, and cross-repo CI workflows. It is an implementation blueprint: everything here is meant to be directly realized as JSON Schemas, Lua APIs, Rust modules, and GitHub Actions, with no behavioral content or asset logic embedded in the public core.[file:38][file:40][file:29]

---

## 1. Engine Startup & Neutral Void

This section specifies the public contracts that define how any Horror Runtime Engine boots against Horror.Place, how failure modes are expressed, and how a Neutral Void state is represented when invariants or contracts are not yet satisfied.[file:38][file:40]

### 1.1 File Layout

The following files live in Horror.Place and are treated as public, versioned contracts:

- `schemas/core/engine-startup-contract.v1.json`  
- `schemas/core/engine-failure-mode.v1.json`  
- `schemas/core/neutral-void-state.v1.json`  
- `scripts/preflight/hp-engine-preflight.ps1`  
- `scripts/preflight/hp-engine-preflight.sh`  

Engine implementations in downstream repos (e.g., Death-Engine or engine modules in Codebase-of-Death) are required to treat these as canonical.[file:40]

### 1.2 Engine Startup Contract Schema

The `engine-startup-contract.v1.json` schema defines how a runtime engine declares its readiness to operate under Horror.Place invariants and metrics.[file:38][file:40]

- Root: object, required fields: `engineId`, `version`, `supportedSchemas`, `invariantRange`, `metricTargets`, `regionBounds`, `failurePolicy`.
- `engineId`: string, canonical identifier for the engine runtime.
- `version`: semantic version string `vMAJOR.MINOR.PATCH`.
- `supportedSchemas`: array of strings; each must be a canonical schema URI from Horror.Place or HorrorPlace-Constellation-Contracts (for invariants, metrics, region contracts, etc.).
- `invariantRange`: object with keys drawn from `{CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI}`; each value is an object `{ "min": number, "max": number }` expressing the invariant band the engine claims to support.[file:38][file:40]
- `metricTargets`: object with keys drawn from `{UEC, EMD, STCI, CDL, ARR}`; each value is an object `{ "min": number, "max": number }`.
- `regionBounds`: defines what regionId coordinate system or tiling the engine expects, including `minRegionId`, `maxRegionId`, and optional `coordinateSystem` (e.g., `tile-grid-v1`).
- `failurePolicy`: object indicating how the engine responds when critical contracts are missing or invalid; must reference failure modes by id from `engine-failure-mode.v1.json`.

Validation rules:

- Every key in `invariantRange` and `metricTargets` must be present in the canonical invariants/metrics spine schemas (Horror.Place or Constellation-Contracts).[file:38][file:34]
- `invariantRange` bands must be subsets of the global allowed ranges defined in the invariants spine: e.g., for CIC in `[0, 1]`, an engine may declare `[0.0, 0.9]` but not `[0.0, 1.5]`.[file:38][file:34]
- The presence of any key outside the defined invariant/metric sets is rejected at schema validation time.

### 1.3 Engine Failure Mode Schema

The `engine-failure-mode.v1.json` schema enumerates named failure modes that may be used by preflight scripts, orchestrator checks, or runtime health monitors.[file:40]

- Root: object, required fields: `failureId`, `severity`, `category`, `description`, `recovery`.
- `failureId`: string, machine-readable ID, e.g., `ENGINE_SCHEMA_MISMATCH`, `NEUTRAL_VOID_REQUIRED`, `REGION_BOUNDARY_TEAR`.
- `severity`: enum: `info`, `warning`, `error`, `fatal`.
- `category`: enum: `schema`, `registry`, `invariants`, `metrics`, `orchestrator`, `io`, `internal`.
- `description`: human-readable summary, implication-only (no assets or narrative).
- `recovery`: object with required `mode` and optional `notes`:
  - `mode`: enum: `retry`, `fallback-neutral-void`, `shutdown`, `ignore-on-dev`.
  - `notes`: optional string for engine operators.

Downstream engines must map their internal error types onto these failure IDs and modes for observability and cross-engine consistency.[file:40]

### 1.4 Neutral Void State Schema

The Neutral Void is a public-core abstraction for a safe, non-content state where an engine is online, but no horror logic is active because prerequisites have failed or not yet been satisfied.[file:38][file:40]

`neutral-void-state.v1.json`:

- Root: object, required fields: `stateId`, `reason`, `invariantSnapshot`, `metricSnapshot`, `allowedTransitions`.
- `stateId`: must be the fixed literal `"NEUTRAL_VOID_CORE_V1"`.
- `reason`: enum: `missing-contracts`, `schema-validation-failed`, `charter-violation-risk`, `no-region-boundary`, `startup-unsatisfied`.
- `invariantSnapshot`: object keyed by invariant symbols; values are numbers or `null` when no invariant data is available.
- `metricSnapshot`: object keyed by metric symbols; values are numbers or `null`.
- `allowedTransitions`: array of strings; each entry must be one of:
  - `ACTIVATE_ENGINE` (when all preflight checks pass),
  - `SHUTDOWN_SAFE`,
  - `RETRY_PREFLIGHT`.

Public rules:

- Any Tier 1 engine must be able to enter and maintain a Neutral Void state whenever preflight validation fails (schemas, registries, Orchestrator connectivity, charter enforcement). No runtime horror behaviors may execute while the Neutral Void is active.[file:40]
- The Neutral Void state may be stored and emitted as telemetry but must contain only invariant/metric snapshots and reasons, never assets, text, or scene descriptions.

### 1.5 Preflight Scripts

The public core ships minimal preflight scripts that validate configuration before an engine can claim to run under Horror.Place contracts.[file:38][file:40]

Paths:

- `scripts/preflight/hp-engine-preflight.ps1`
- `scripts/preflight/hp-engine-preflight.sh`

Required preflight checks (logic, not implementation):

1. Validate that all JSON Schemas referenced in `supportedSchemas` of `engine-startup-contract.v1.json` exist and pass `jsonschema` Draft 2020-12 validation.[file:38]
2. Validate that all invariants and metrics in `invariantRange` and `metricTargets` are defined in the canonical invariants and metrics spine schemas.[file:38][file:34]
3. Confirm network or local access to Horror.Place-Orchestrator endpoints for registry checks, or a configured offline mode that relies on signed registry snapshots.[file:40]
4. Ensure that configured region IDs fall within `regionBounds` and that any Orchestrator-issued region contract cards for those regions validate against their schemas.[file:40][file:34]
5. If any critical check fails, emit a `neutral-void-state.v1.json` instance and exit non-zero, mapping errors to a canonical `engine-failure-mode` record.

The scripts themselves do not inspect assets or content; they only operate on schemas, registries, and config.[file:40]

---

## 2. Rivers of Blood Charter Enforcement

The Rivers of Blood charter is enforced at Tier 1 via JSON Schemas and invariant rules only; no content inspection is allowed in the public core. This section defines the enforcement scaffolding that downstream repos must obey.[file:40][file:38]

### 2.1 Charter Schema

File:

- `schemas/core/rivers-of-blood-charter.v1.json`

This schema encodes the high-level charter constraints as data:

- Root: object, required fields: `charterVersion`, `hardProhibitions`, `allowedHorrorModes`, `invariantCaps`, `metricCaps`.
- `charterVersion`: semantic version string.
- `hardProhibitions`: array of strings (e.g., `explicitviolence`, `graphicgore`, `sexualviolence`, `selfharmdetail`, `realworldhate`).
- `allowedHorrorModes`: array of strings describing modes that remain implication-only and GitHub-compliant (e.g., `psychologicalhorror`, `folklore`, `ambientdread`, `implicationonly`).
- `invariantCaps`: object keyed by invariant symbols; each value is `{ "max": number }` describing an absolute upper bound for that invariant at Tier 1.
- `metricCaps`: object keyed by metric symbols; each value is `{ "max": number }` describing an upper bound for certain telemetry-driven effects considered acceptable at Tier 1.[file:40][file:38]

No narrative text is embedded; everything is numeric or categorical for downstream enforcement.

### 2.2 Charter-Linked Invariant Rules

The public invariants spine already defines numeric ranges for invariants.[file:38][file:40] Charter enforcement adds cross-field conditions encoded in JSON Schema for relevant contracts, for example:

- For a region contract card or persona contract:
  - If `CIC >= 0.85` then `AOS >= 0.6` (high consequence implies higher archival opacity).
  - If `SHCI >= 0.8` then `DET <= 8.0` (high historical coupling implies tension must not be extreme continuously).[file:38][file:40]
- For events associated with intense invariant bands, metric caps may be tightened:
  - If `CIC >= 0.9` and `AOS >= 0.7`, then `EMD` (mystery density) must remain below a cap that avoids confusion; e.g., `EMD <= 0.75`.

These rules are applied via `allOf` blocks in the relevant schemas (e.g., `schemas/core/regionContractCard.v1.json` in Constellation-Contracts, and Horror.Place–specific style or region contracts), importing the charter schema where needed.[file:34][file:29]

### 2.3 Audit Hooks Without Asset Inspection

Public charter enforcement is wired into CI and Orchestrator workflows solely via schema-level checks:

- No contract or registry in Horror.Place may define fields for raw assets (no URLs, binary references, scripts, etc.) beyond opaque IDs such as `artifactId`, `cid`, or `deadledgerref`.[file:40][file:34]
- Charter compliance jobs in CI:
  - Validate all changed schema and registry files against `rivers-of-blood-charter.v1.json`, the invariants spines, and entertainment metrics spines.
  - Refuse any change where invariants or metrics exceed charter `invariantCaps` or `metricCaps` for Tier 1.
  - Ensure required `hardProhibitions` are present and that no contract schema introduces fields that could encode prohibited content directly (e.g., narrative text).[file:38][file:29]

Orchestrator integration uses only contract IDs, invariants, metrics, and Dead-Ledger attestations; it never inspects content or assets in the public core.[file:40][file:34]

---

## 3. Surprise Director API Stubs (Lua & Telemetry)

Surprise Director behavior is implemented in private vaults, but Horor.Place defines the public stubs and telemetry envelopes. This maintains narrow APIs and keeps logic in secure repositories.[file:40][file:38][file:34]

### 3.1 File Layout

In Horror.Place:

- `lua/public/surprise_director_api.lua`  
- `schemas/telemetry/surprise-director-call.v1.json`  
- `schemas/telemetry/surprise-director-outcome.v1.json`  

Vault implementations (e.g., Codebase-of-Death, Spectral-Foundry) import `surprise_director_api.lua` and implement private handlers, but the public core owns the function signatures and telemetry schemas.[file:40][file:34]

### 3.2 Lua Function Signatures

The public stub module exports the following functions (signatures only; no behavior):

- `SurpriseDirector.request_event(session_id, region_id, style_id, invariant_snapshot, metric_snapshot) -> request_token`  
- `SurpriseDirector.apply_outcome(session_id, request_token, outcome_envelope) -> boolean`  

Definitions:

- `session_id`: string; must map to telemetry envelopes and invariant snapshots.
- `region_id`: string; must be a valid key in region registries.
- `style_id`: string; must refer to a style in style registries.
- `invariant_snapshot`: Lua table keyed by invariant symbols with numeric values (CIC, MDI, AOS, etc.).
- `metric_snapshot`: Lua table keyed by metrics (UEC, EMD, STCI, CDL, ARR).
- `request_token`: opaque string, usable as a correlation key; carries no behavior or content.
- `outcome_envelope`: Lua table structured to match `surprise-director-outcome.v1.json`.

Public rules:

- Stub functions must not inspect or manipulate any assets; they only shape calls and telemetry.[file:40][file:34]
- All Surprise Director calls must log a `surprise-director-call` telemetry record, and all outcomes must emit a `surprise-director-outcome` record; these envelopes are defined only in terms of invariants, metrics, and IDs.

### 3.3 Telemetry Schemas

#### `surprise-director-call.v1.json`

Fields:

- `schemaVersion`: semantic version.
- `sessionId`: string.
- `regionId`: string.
- `styleId`: string.
- `requestToken`: string.
- `invariants`: object keyed by invariant symbols with numeric values.
- `metrics`: object keyed by metric symbols with numeric values.
- `timestamp`: ISO 8601 string.

#### `surprise-director-outcome.v1.json`

Fields:

- `schemaVersion`: semantic version.
- `sessionId`: string.
- `requestToken`: string.
- `decisionType`: enum: `schedule`, `suppress`, `defer`, `delegate`.
- `targetRegionId`: string (may equal `regionId` from the call or a neighbor).
- `invariantDelta`: object keyed by invariant symbols with numeric changes (e.g., `DET +1`).
- `metricTargets`: object keyed by metrics with target ranges to aim for (e.g., `UEC: { "min": 0.55, "max": 0.7 }`).
- `directorProfileId`: string reference to an internal profile in a private vault (opaque to the public core).
- `timestamp`: ISO 8601 string.

The public core does not define how directors choose outcomes; it only defines envelopes and stubs so that telemetry and contracts remain consistent across repos.[file:40][file:34]

---

## 4. Orchestrator Integration Contracts

Horror.Place does not embed Orchestrator internals but defines the contracts that bind Orchestrator to the core schemas and registries, including registry consistency and region/respawn boundary rules that prevent “Reality Tears.”[file:38][file:40][file:34]

### 4.1 Registry Contract Surface

Horror.Place owns NDJSON registry formats for regions, events, styles, and personas.[file:38][file:40]

Representative files:

- `schemas/registry/registry-regions.v1.json`
- `schemas/registry/registry-events.v1.json`
- `schemas/registry/registry-styles.v1.json`
- `schemas/registry/registry-personas.v1.json`

Core rules:

- Each registry line is a JSON object with required `id`, `schemaRef`, `artifactId` (or `cid`), `tier`, and `deadledgerref` for non-public entries.[file:34][file:29]
- `schemaRef` must be a canonical schema URI from Horror.Place or Constellation-Contracts.
- `tier` is one of `public`, `vault`, `lab`, and must be consistent with Dead-Ledger attestations in downstream repos.[file:40][file:34]

Orchestrator is required to:

- Validate registry entries against these schemas before writing.
- Treat each entry as immutable except for fields explicitly marked as mutable (e.g., `status`, `preferredImplementationId`), according to schema definitions.
- Ensure idempotent writes: the same update must be safe to apply multiple times without changing the effective state.[file:40]

### 4.2 Region / Respawn Boundary Constraints

To avoid “Reality Tears” (structural inconsistencies where region definitions or respawn points conflict), Horror.Place defines explicit region boundary contracts.

File:

- `schemas/core/region-boundary-constraints.v1.json`

Fields:

- `regionId`: string; must match a region ID in `registry-regions`.
- `neighbors`: array of region IDs considered directly adjacent.
- `respawnSafeZones`: array of region IDs where respawn is permitted.
- `hardSeparators`: array of region IDs that must never be stitched directly to this region (e.g., to avoid violating invariant continuity).
- `invariantContinuityRules`: array of rules: each rule describes relationships such as “if neighbor has `CIC >= 0.9` and this region has `CIC <= 0.2`, disallow adjacency unless explicitly annotated.”[file:40]

Orchestrator-level constraints:

- Must reject registry changes that would create adjacency between regions violating `invariantContinuityRules`.
- Must verify that any respawn point references a `respawnSafeZones` entry; otherwise the change is rejected and a failure mode is raised, e.g., `REGION_BOUNDARY_TEAR`.
- May not infer new boundaries; it only enforces consistency based on contracts defined here.

These rules prevent topological inconsistencies without exposing any content or runtime behavior in Tier 1.[file:40]

### 4.3 Contract-Level Integration Expectations

Horror.Place defines expectations for Orchestrator behavior as contracts, without shipping implementation.

File:

- `docs/public-core/orchestrator-contracts.md`

The contract states:

- For any registry update:
  - Fetch the canonical schema from Horror.Place.
  - Validate the proposed registry entry.
  - Verify that region boundary constraints are satisfied.
  - Verify `deadledgerref` via Dead-Ledger services for non-public tiers.
  - Apply changes idempotently and log them via audit entries defined in Dead-Ledger Network.[file:38][file:40][file:34]
- Orchestrator must not write fields or registry entries that are not described in Horror.Place schemas, nor may it bypass region boundary constraints.

---

## 5. Cross-Repository CI Workflows (GitHub Actions)

Horror.Place publishes minimal, functional GitHub Actions workflows that validate core schemas and invariants for itself and for downstream repositories such as Orchestrator, Constellation-Contracts, and Codebase-of-Death.[file:38][file:34][file:29]

### 5.1 Workflow Files

In Horror.Place:

- `.github/workflows/schema-validate.yml`
- `.github/workflows/charter-enforce.yml`
- `.github/workflows/cross-repo-spine-check.yml`

Downstream repos are expected to import these via `uses:` syntax where appropriate.[file:34][file:29]

### 5.2 `schema-validate.yml`

Purpose: Validate all JSON Schemas and NDJSON registry examples on PRs.

Key behavior:

- Trigger on `pull_request` and `workflow_dispatch`.
- Steps:
  1. Check out repository.
  2. Set up Python (3.11).
  3. Install `jsonschema` and any minimal tooling scripts referenced (e.g., `hpc-validate-schema.py` from Constellation-Contracts).
  4. Run schema validation across `schemas/**.json`.
  5. Validate registry examples against registry schemas.

This workflow is self-contained and does not require secrets.[file:34][file:29]

### 5.3 `charter-enforce.yml`

Purpose: Enforce Rivers of Blood charter invariants and metrics caps for all relevant schemas and registry entries.

Key behavior:

- Trigger on `pull_request` and `workflow_dispatch`.
- Steps:
  1. Check out repository.
  2. Set up Python and run a charter linter script that:
     - Loads `rivers-of-blood-charter.v1.json`.
     - Ensures all invariant/metric constraints in contract schemas remain within charter caps.
     - Scans registry examples to ensure no entry exceeds charter-defined caps for invariants or metrics (where these are present).
  3. Fail the workflow on any violation.

The linter only reads contracts and registry lines, never assets or behavior files.[file:40][file:38][file:29]

### 5.4 `cross-repo-spine-check.yml`

Purpose: Validate that Horror.Place’s invariants and metrics spines stay consistent with the shared spine in HorrorPlace-Constellation-Contracts, and that downstream repos remain aligned.

Key behavior:

- Trigger on `workflow_dispatch` and optionally scheduled runs.
- Steps:
  1. Check out Horror.Place.
  2. Clone HorrorPlace-Constellation-Contracts in a sibling directory (read-only).
  3. Run a Python script (e.g., `schemaspine/spineindexbuilder.py` from Constellation-Contracts) to build a spine index from both repos.
  4. Check that:
     - All invariants and metrics defined in Horror.Place exist in the shared spine.
     - There are no conflicting ranges or types.
     - There are no orphan invariants or metrics referenced by Horror.Place schemas but absent from the spine.[file:34][file:29]
  5. Optionally emit a human-readable report and fail on drift.

Downstream repos may adopt similar workflows to validate their contracts against both cores.[file:34][file:29]

---

## 6. Summary of Deterministic Contracts for Downstream Repos

The following artifacts in Horror.Place form deterministic, public contracts that downstream repositories must consume:

| Area                        | Contract Artifact(s)                                        | Downstream Dependents                                                           |
|----------------------------|-------------------------------------------------------------|---------------------------------------------------------------------------------|
| Engine startup             | `engine-startup-contract.v1.json`, `engine-failure-mode.v1.json`, `neutral-void-state.v1.json` | Death-Engine, Codebase-of-Death engine glue, Orchestrator health checks        |
| Rivers of Blood charter    | `rivers-of-blood-charter.v1.json`, charter-linked invariants/metrics caps | All Tier 1 schemas and registries, Constellation-Contracts charter mirrors     |
| Surprise Director stubs    | `surprise_director_api.lua`, `surprise-director-call.v1.json`, `surprise-director-outcome.v1.json` | Codebase-of-Death, Spectral-Foundry, other director implementations            |
| Orchestrator integration   | Registry schemas, `region-boundary-constraints.v1.json`, orchestrator contract docs | Horror.Place-Orchestrator, Dead-Ledger Network (for audit/log schemas)         |
| Cross-repo CI workflows    | `schema-validate.yml`, `charter-enforce.yml`, `cross-repo-spine-check.yml` | Horror.Place, Constellation-Contracts, Orchestrator, vault and lab repos       |

Each of these artifacts is free of raw content and describes only structure, invariants, metrics, and wiring patterns, allowing downstream systems to implement behavior in private vaults while remaining provably aligned with the public core.[file:38][file:40][file:34][file:29]
