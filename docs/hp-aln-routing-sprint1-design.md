---
invariants_used: [CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI]
metrics_used: [UEC, EMD, STCI, CDL, ARR]
tiers: [standard, mature, research]
deadledger_surface: [zkpproof_schema, verifiers_registry, bundle_attestation, agent_attestation]
---

# Horror.Place Sprint 1 Design — ALN Parser, Routing Engine, and PowerShell Suite

Version: 0.1.0-draft  
Status: Design-only (no code generated)  
Scope: Horror.Place public core repository (Tier 1)  

## 1. Purpose and Constraints

This document specifies the missing Sprint 1 technical components required for Horror.Place to function as a contract-driven Schema Authority:

- Rust ALN parser (`crates/horrorplace_aln/src/parser.rs`).
- Rust routing engine (`crates/horrorplace_core/src/routing/engine.rs`).
- PowerShell integration suite (`crates/horrorplace_powershell/`).

All components are design-only, implementation-ready, and must strictly consume existing public contracts:

- `core/schemas/invariantsv1.json` (safety/history invariants: CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI).
- `core/schemas/entertainmentmetricsv1.json` (UEC, EMD, STCI, CDL, ARR).
- Other public schemas and registries in Horror.Place core (style, event, persona, experiment descriptor, registry schemas, CI config, API spec).

The design:

- Treats schemas and registries as authoritative; ALN and routing logic must never invent fields or behavior outside these contracts.
- Embeds validation rules derived from the VM-Constellation Blueprint, especially invariant enforcement (CIC/AOS/SHCI) and metric alignment (UEC/EMD/STCI).
- Respects the Rivers of Blood Charter and no-raw-content guarantees encoded in invariants, style contracts, and CI config (opaque IDs only, no asset URLs, no inline content).
- Defers structural clean-up (duplicate files, crate naming drift) to later Sprints; this design assumes current paths and names as-is.

Downstream vault/lab repositories (e.g., HorrorPlace-Atrocity-Seeds, Black-Archivum, Spectral-Foundry) must depend only on these public contracts, using their own schemas and files purely as implementations and telemetry, not as new normative contracts.

---

## 2. Shared Concepts and Contracts

### 2.1 Invariants and Metrics as Primary Keys

The ALN parser and routing engine operate on a shared, contract-bound vocabulary:

- Invariants from `schemas/invariantsv1.json`, including: CIC, MDI, AOS, RRM, FCF, SPR, RWF, DET, HVF, LSG, SHCI.
- Entertainment metrics from `schemas/entertainmentmetricsv1.json`, especially UEC, EMD, STCI, CDL, ARR.

The Spectral Library (`src/spectrallibrary.rs`) and Lua `engine/horrorinvariants.lua` already define the narrow `H.` API that exposes region invariants as numeric values and ranges.

The routing engine and ALN parser must:

- Interpret all constraints and rules in terms of these invariants and metrics, not ad-hoc flags.
- Use public registries (`core/registry/*.json` NDJSON) as the only discovery mechanism for events, styles, regions, personas, and experiment descriptors.
- Rely on `H.CIC` / `H.AOS` etc. (via Rust API and Lua adapters) for runtime invariant values; they must not duplicate invariant storage.

### 2.2 ALN and Contract Schema Alignment

Within the VM-Constellation Blueprint, ALN (Autonomous Learning Network / ALN-Googolswarm) is a contract-constrained, blockchain-backed coordination layer, not a content source.

Sprint 1 ALN integration is read-only and core-facing:

- The parser reads ALN contracts that reference Horror.Place schemas by URI (e.g., `schema.Horror.Place.core.schemas.invariantsv1`).
- Parsed ALN structures must be validated against existing schemas and registry entries to ensure schema-first alignment.
- Interactions with Dead-Ledger and ZKP proof envelopes are out-of-scope for Sprint 1; this design ensures the parser and routing engine are ready to plug into those later via `zkpproofv1.json` and `registry/verifiers.json`.

---

## 3. Rust ALN Parser — `crates/horrorplace_aln/src/parser.rs`

### 3.1 Responsibilities

The ALN parser is a pure, deterministic module that:

1. Parses ALN contract sources (textual or JSON DSL) into strongly-typed Rust structures.
2. Validates those structures against:
   - Horror.Place canonical schemas (`invariantsv1`, `entertainmentmetricsv1`, style/event/persona/experiment schemas).
   - Schema URIs and patterns defined in the API spec (e.g., `schema.Horror.Place.core.schemas.*`).
3. Emits a normalized routing program (`AlnProgram`) consumed by the routing engine.
4. Enforces no-raw-content rules by rejecting any ALN field that appears to contain URLs, data URIs, embedded asset content, or HTML/script payloads.

It must not:

- Execute network calls, perform I/O, or touch blockchain.
- Generate random behavior; any non-determinism comes from inputs (metrics, invariants) and downstream PCG.

### 3.2 Expected ALN Input Model (Conceptual)

Sprint 1 supports two ALN source types:

- `AlnTextContract`: a line-based DSL (future placement under `aln/contracts/*.aln`, design-only for now).
- `AlnJsonContract`: JSON representation for CI-friendly testing and machine-generated contracts, referencing schemas by URI.

Conceptual fields (to be formalized in a separate schema):

- `contract_id`: unique string, stable across runs.
- `schemaref`: Horror.Place schema URI (e.g., `schema.Horror.Place.core.schemas.invariantsv1`).
- `targets`: list of `TargetBinding` entries (style, event, persona, region IDs from registries).
- `conditions`: set of invariant and metric constraints (e.g., `CIC > 0.7`, `UEC in [0.55, 0.85]`).
- `actions`: routing hints and safety rails (e.g., `ClampMetric STCI in [0.4, 0.8]`).

ALN contracts must reference only IDs and schema URIs that already exist in Horror.Place public schemas and registries.

### 3.3 Rust Types (High-Level Signatures)

The parser module exposes a small public type surface that represents an executable view of schema-validated ALN data:

```rust
// Root program used by routing engine
pub struct AlnProgram {
    pub contracts: Vec<AlnContract>,
    pub version: String,
}

// Parsed contract
pub struct AlnContract {
    pub contract_id: String,
    pub schema_ref: String,
    pub targets: Vec<AlnTargetBinding>,
    pub conditions: Vec<AlnCondition>,
    pub actions: Vec<AlnAction>,
}

// Binding to a registry entry
pub enum AlnTargetKind {
    Event,
    Region,
    Style,
    Persona,
}

pub struct AlnTargetBinding {
    pub kind: AlnTargetKind,
    pub registry_id: String,      // e.g., EVT-0001, STY-DREAD01
    pub schemaref: String,        // must match registry entry schemaref
}

// Condition over invariants or metrics
pub enum AlnConditionKind {
    Invariant,
    Metric,
}

pub enum ComparisonOp {
    Lt,
    Lte,
    Eq,
    Gte,
    Gt,
    InRange,          // [min, max]
}

pub struct AlnCondition {
    pub kind: AlnConditionKind,
    pub key: String,      // "CIC", "AOS", "UEC", "ARR", etc.
    pub op: ComparisonOp,
    pub values: Vec<f64>, // length 1 or 2 depending on op
}

// Actions: routing or enforcement directives
pub enum AlnAction {
    PreferStyle { style_id: String, weight: f32 },
    ForbidStyle { style_id: String },
    ClampMetric { key: String, min: f64, max: f64 },
    RequireInvariantRange { key: String, min: f64, max: f64 },
}
```

These types must remain aligned with schemas and registries and must not introduce new keys or fields.

### 3.4 Public API Functions

The parser exposes synchronous, side-effect-free functions:

```rust
/// Parse ALN from a JSON string, perform structural validation,
/// and return an executable AlnProgram or a detailed error.
pub fn parse_json_contracts(json: &str) -> Result<AlnProgram, AlnParseError>;

/// Parse ALN from the line-based DSL form.
pub fn parse_text_contracts(src: &str) -> Result<AlnProgram, AlnParseError>;

/// Validate that an AlnProgram is compatible with Horror.Place schemas.
/// This must be called before wiring into the routing engine.
pub fn validate_program_against_schemas(
    program: &AlnProgram,
    schema_index: &SchemaIndex,
) -> Result<(), AlnValidationError>;
```

Supporting types:

```rust
pub struct SchemaIndex {
    pub invariants_uri: String,        // schema.Horror.Place.core.schemas.invariantsv1
    pub entertainment_uri: String,     // schema.Horror.Place.core.schemas.entertainmentmetricsv1
    pub style_uri: String,
    pub event_uri: String,
    pub persona_uri: String,
}

#[derive(Debug)]
pub enum AlnParseError {
    InvalidJson(String),
    InvalidSyntax(String),
    UnknownField(String),
    DisallowedRawContent(String), // URL, data URI, HTML, Base64, etc.
}

#[derive(Debug)]
pub enum AlnValidationError {
    UnknownSchemaRef(String),
    UnknownInvariantKey(String),
    UnknownMetricKey(String),
    InvalidValueRange { key: String, details: String },
    RegistryMismatch { contract_id: String, registry_id: String },
}
```

`SchemaIndex` is built from the existing Horror.Place schema set and must reference the same URIs used in API spec and registries.

### 3.5 Validation Rules

`validate_program_against_schemas` enforces at least:

1. **Schema URIs**  
   - All `schema_ref` / `schemaref` values must start with the canonical prefix used in core schemas and API spec (e.g., `schema.Horror.Place.core.schemas.`).
   - ALN references to style, event, persona, region, and experiment descriptor schemas must map to URIs known in `SchemaIndex`.

2. **Invariant keys**  
   - Allowed keys are limited to: `CIC`, `MDI`, `AOS`, `RRM`, `FCF`, `SPR`, `RWF`, `DET`, `HVF`, `LSG`, `SHCI`.

3. **Metric keys**  
   - Allowed metric keys are limited to: `UEC`, `EMD`, `STCI`, `CDL`, `ARR`.

4. **Ranges and bounds**  
   - Metric values must lie in `[0.0, 1.0]`.
   - Invariant ranges must respect the ranges encoded in `invariantsv1` (e.g., 0–1 or 0–10, depending on field).

5. **No raw content**  
   - Reject any string that matches leak patterns used in CI (`api-leak-test`) and CIC checks:
     - Direct HTTP(S) URLs, asset extensions, IPFS gateways.
     - `data:` URIs, obvious Base64 blobs.
     - Inline HTML, `<script>` tags, or raw binary hex dumps.

6. **Registry alignment (Sprint 1 scope)**  
   - Enforce basic ID formats (`EVT-`, `STY-`, `REG-`, `PER-`, etc.) as documented in registry schemas.
   - Verify that each `AlnTargetBinding.registry_id` exists in the corresponding registry when a `RegistryIndex` is provided.

### 3.6 Interaction with Experiment Descriptor Schema

ALN conditions may reference experiment descriptors defined by `experimentdescriptorv1`:

- ALN contracts can include actions tied to specific experiment IDs (`EXP-0001`, etc.).
- The parser must ensure that any referenced experiment IDs match the `experimentdescriptorv1` schema and ID pattern but does not interpret experiment internals; it treats them as opaque IDs.

---

## 4. Rust Routing Engine — `crates/horrorplace_core/src/routing/engine.rs`

### 4.1 Responsibilities

The routing engine is the deterministic core router that:

- Consumes:
  - `AlnProgram` from the ALN parser.
  - Current region invariants from `SpectralLibrary` / `H.` API.
  - Current entertainment metrics (UEC, EMD, STCI, CDL, ARR) from the metrics subsystem (`metricsv1`-shaped state).
  - Public registries for events, styles, regions, personas (NDJSON).
- Produces routing decisions:
  - Style selection for the current region.
  - Event eligibility and priority.
  - Persona surfacing hints (e.g., Archivist vs Witness) for a context.

It concretely implements the style router module spec: invariants + metrics → style/event/persona IDs, under schema and registry control.

### 4.2 Core Data Structures

#### 4.2.1 Invariant and Metric Snapshot

```rust
pub struct InvariantSnapshot {
    pub region_id: String, // e.g., REG-0001
    pub cic: f64,
    pub mdi: f64,
    pub aos: f64,
    pub rrm: f64,
    pub fcf: f64,
    pub spr: f64,
    pub rwf: f64,
    pub det: f64,
    pub hvf: f64,
    pub lsg: f64,
    pub shci: f64,
}

pub struct MetricSnapshot {
    pub uec: f64,
    pub emd: f64,
    pub stci: f64,
    pub cdl: f64,
    pub arr: f64,
}
```

These snapshots are constructed by higher-level services:

- Invariants via `SpectralLibrary` and Lua `H.` binding.
- Metrics via the entertainment metrics subsystem and associated APIs.

#### 4.2.2 Routing Context and Decision Types

```rust
pub struct RoutingContext {
    pub invariants: InvariantSnapshot,
    pub metrics: MetricSnapshot,
    pub region_registry_id: Option<String>,   // REG-*
    pub persona_registrations: Vec<String>,   // PER-* IDs currently active
}

pub struct StyleDecision {
    pub style_id: String,     // STY-*
    pub confidence: f32,      // 0–1
}

pub struct EventDecision {
    pub event_id: String,     // EVT-*
    pub eligible: bool,
    pub priority: f32,        // 0–1
}

pub struct PersonaDecision {
    pub persona_id: String,   // PER-*
    pub activation_weight: f32,
}
```

These must be serializable to JSON for use in HTTP APIs and Lua bridges. They contain only IDs, scalar scores, and no raw content.

### 4.3 Public Routing API

```rust
/// Main entry point: compute routing decisions from ALN program and current context.
pub fn route(
    program: &AlnProgram,
    context: &RoutingContext,
    registries: &RegistryIndex,
) -> Result<RoutingResult, RoutingError>;
```

Where:

```rust
pub struct RegistryIndex {
    pub events: Vec<RegistryEntry>,
    pub regions: Vec<RegistryEntry>,
    pub styles: Vec<RegistryEntry>,
    pub personas: Vec<RegistryEntry>,
}

pub struct RegistryEntry {
    pub id: String,          // EVT-*, REG-*, STY-*, PER-*
    pub schemaref: String,
    pub artifactid: String,  // opaque
    pub cid: String,         // opaque
    pub metadata: serde_json::Value,
}

pub struct RoutingResult {
    pub style: Option<StyleDecision>,
    pub events: Vec<EventDecision>,
    pub personas: Vec<PersonaDecision>,
}

#[derive(Debug)]
pub enum RoutingError {
    InvalidContext(String),
    MetricOutOfBounds(String),
    InvariantOutOfBounds(String),
    ProgramValidationFailed(String),
}
```

`RegistryIndex` is populated by a separate loader that validates NDJSON entries against registry schemas and leak rules.

### 4.4 Algorithmic Outline

1. **Program validation hook**  
   - Verify that `program` has been validated against schemas (e.g., by keeping a `validated: bool` flag or by re-running structural checks). If invalid, return `RoutingError::ProgramValidationFailed`.

2. **Context validation**  
   - Confirm metric values lie in `[0.0, 1.0]`; error or clamp based on configuration.
   - Confirm invariants lie within declared ranges in `invariantsv1`; error or clamp based on configuration.
   - Ensure `region_registry_id`, if present, refers to a valid `RegistryEntry` in `regions`.

3. **Contract evaluation**  
   - For each `AlnContract`:
     - Evaluate `conditions` against `InvariantSnapshot` and `MetricSnapshot`.
     - If all conditions pass, add its `actions` to an accumulator (per kind: style, metrics, invariants).

4. **Style routing**  
   - Start from registry-based style defaults as defined in the style router spec (e.g., mapping invariant bands to default style families).
   - Apply accumulated `PreferStyle` and `ForbidStyle` actions:
     - Maintain a weight map `style_id -> weight`, adding or subtracting per action.
     - Remove forbidden styles from consideration.
   - Select the style with the highest effective weight; derive a `confidence` score based on margin vs. next candidate and action coverage.
   - If no style is selected, fall back to a default style determined solely by invariants and metrics (as per style router guidelines).

5. **Event eligibility and priority**  
   - For each event in registries:
     - Check any ALN contracts targeting that event and evaluate their conditions.
     - Mark `eligible` only if:
       - Conditions pass, and
       - The event registry metadata indicates an allowed `status` (e.g., `draft` or `active`).
     - Compute `priority` from:
       - ALN-provided weights.
       - Invariant compatibility (e.g., high CIC + high AOS for certain event families).
       - Metric safety (events that increase EMD while preserving ARR and STCI within safe bands).

6. **Persona selection**  
   - For each active persona (from `persona_registrations` and registries):
     - Evaluate relevant ALN contracts and conditions.
     - Use SHCI, AOS, MDI, and entertainment metrics to compute an `activation_weight` consistent with persona and style contracts.
   - Produce a ranked list in `RoutingResult.personas`.

7. **Metric safety rails**  
   - Compute hypothetical future metric states by applying `ClampMetric` and related actions.
   - Expose these as guidance to downstream systems; do not mutate metrics inside `route`, but surface recommended clamping bands.

The engine is pure: it returns a `RoutingResult` (and potentially suggested metric clamps) but does not persist or mutate any state.

### 4.5 Style Router Integration

The style router module spec defines rules like:

- Use invariant bands and metrics to pick style contracts via `registrystyles.json`.
- Enforce Rivers of Blood constraints by selecting only styles whose contracts disallow explicit depictions.

The routing engine builds on that by exposing:

```rust
pub fn resolve_style_decision(
    result: &RoutingResult,
    registries: &RegistryIndex,
) -> Option<StyleDecision>;
```

This helper:

- Verifies that the chosen `style_id` exists in `registrystyles.json`.
- Ensures the style’s `schemaref` matches `stylecontractv1`.
- Checks that tier and tone metadata in `metadata` align with the current context:
  - Public builds use only Tier 1 compatible styles.
  - Mature/research modes may use more intense styles but still honor invariants and safety bounds.

### 4.6 Experiment-Aware Routing

To support experiment descriptors and microstudies:

- The routing engine should accept an optional experiment context (experiment ID, metric band targets).
- It can annotate `RoutingResult` with experiment-specific tags, allowing labs (especially Neural-Resonance-Lab and Redacted-Chronicles) to correlate routing decisions with experiment telemetry.

This remains metadata-only in Sprint 1; full experiment scheduling lives in higher layers.

---

## 5. PowerShell Integration Suite — `crates/horrorplace_powershell/`

### 5.1 Role and Scope

The PowerShell suite provides cross-platform, CI-friendly tooling for:

- Validating schemas and registries (wrapping existing Python/JSON-schema checks).
- Running ALN parsing and routing validation from the CLI.
- Interacting with the Horror.Place HTTP API for schema and registry queries.

It must:

- Be safe for public release (no secrets, no raw content handling).
- Run on Windows, macOS, and Linux (matching CI runner environments).

### 5.2 Module Layout

Proposed structure:

```text
crates/horrorplace_powershell/
  HorrorPlace.Tools.psd1         # Module manifest
  HorrorPlace.Tools.psm1         # Core functions
  Tests/
    HorrorPlace.Tools.Tests.ps1  # Pester tests
  scripts/
    Invoke-AlnValidation.ps1
    Invoke-RoutingDryRun.ps1
    Invoke-SchemaSync.ps1
```

Module manifest (`HorrorPlace.Tools.psd1`) must declare:

- Version, author, license.
- Exported functions (`Invoke-HpSchemaValidation`, `Invoke-HpRegistryValidation`, etc.).
- Compatibility info (PowerShell 7+, CoreCLR).

### 5.3 Core Functions

#### 5.3.1 Schema and Registry Validation

PowerShell wraps CI behaviors, providing consistent local and pipeline commands:

- `Invoke-HpSchemaValidation`
  - Validates all `core/schemas/*.json` with JSON Schema tools (Python `jsonschema` or Node `ajv`).
  - Fails on any schema error; returns non-zero exit code.

- `Invoke-HpRegistryValidation`
  - Validates NDJSON registries under `core/registry/*.json`.
  - Checks presence and types of `id`, `schemaref`, `metadata`, and at least one of `artifactid` or `cid`.
  - Enforces ID patterns (`EVT-`, `STY-`, `REG-`, `PER-`, etc.).

- `Invoke-HpLeakScan`
  - Wraps the same leak rules as `.circleci/config.yml`:
    - Rejects files containing raw asset URLs, IPFS HTTP gateways, data URIs, Base64 blobs, or private keys.
  - Scans core code, schemas, registries, and docs.

Each function must:

- Emit structured error records (`Write-Error` with meaningful `CategoryInfo`).
- Honor `$ErrorActionPreference` and CI expectations (fail fast on issues).

#### 5.3.2 ALN and Routing Validation

Assuming Rust crates expose a CLI or library (to be bound later), PowerShell acts as orchestration:

- `Invoke-HpAlnParse`
  - Parameters:
    - `-Path` to an ALN JSON or DSL file.
  - Behavior:
    - Invokes the Rust ALN parser (e.g., `hpaln parse --input <path>`).
    - Fails if parse or validation errors occur.
  - Output:
    - Optional JSON summary of ALN contracts (IDs, targets, condition counts).

- `Invoke-HpRoutingDryRun`
  - Parameters:
    - `-AlnPath` to ALN program JSON.
    - `-InvariantSnapshotPath` JSON containing `InvariantSnapshot`.
    - `-MetricSnapshotPath` JSON containing `MetricSnapshot`.
    - Optional: `-RegistryPath` for registries JSON/NDJSON.
  - Behavior:
    - Runs routing engine in dry-run mode (no persistence).
    - Writes `RoutingResult` as JSON to stdout.

These commands must treat `artifactid` and `cid` as opaque and never dereference them.

#### 5.3.3 Public HTTP API Utilities

To interoperate with the Horror.Place HTTP API:

- `Get-HpRegistryEntry`
  - Calls `GET /registries/{registryname}/{id}`.
  - Parameters: `-RegistryName`, `-Id`, optional `-BaseUri`.
  - Returns parsed JSON.

- `Get-HpSchema`
  - Calls `GET /schemas/{schemaname}`.
  - Parameters: `-Name`, `-BaseUri`, optional `-OutFile`.
  - Stores schema locally or returns the JSON.

- `Invoke-HpMetricsIngest` (stub or limited in Sprint 1)
  - Calls `POST /metrics/ingest` with `entertainmentmetricsv1` payload.
  - Used by integration tests or demo pipelines.

Authentication, rate limiting, and TLS configuration are delegated to environment variables and configuration files consistent with the API spec; PowerShell must not hard-code secrets.

### 5.4 Tests (Pester)

PowerShell tests should cover:

- `Invoke-HpSchemaValidation` on a known-good snapshot of `core/schemas` (all pass).
- Synthetic malformed schemas causing predictable failures.
- `Invoke-HpRegistryValidation` on:
  - Valid registry entries.
  - Entries with missing fields or bad ID patterns (fail).
- `Invoke-HpLeakScan` on:
  - Clean test trees (pass).
  - Test files with injected URLs or data URIs (fail).
- `Invoke-HpAlnParse` and `Invoke-HpRoutingDryRun` against:
  - A minimal ALN program and synthetic invariant/metric snapshots.

Tests must be cross-platform (no hard-coded path separators or OS-specific assumptions).

---

## 6. Test Criteria and Acceptance Conditions

### 6.1 ALN Parser (Rust)

Unit tests:

- Parsing:
  - Valid ALN JSON with invariant and metric conditions (success).
  - Invalid JSON, unknown fields → `AlnParseError::InvalidJson` / `UnknownField`.
  - Bad ranges (e.g., metric > 1.0) → `AlnValidationError::InvalidValueRange`.
- Validation:
  - Unknown invariant key → `UnknownInvariantKey`.
  - Unknown metric key → `UnknownMetricKey`.
  - Disallowed content patterns (URLs, data URIs, HTML) → `AlnParseError::DisallowedRawContent`.

Property tests:

- Randomly generated ALN contracts that:
  - Use only known invariants and metrics.
  - Restrict metric ranges to `[0, 1]` and invariants to schema ranges.
  - Should never produce `InvalidValueRange` errors when validated.

### 6.2 Routing Engine (Rust)

Unit tests:

- Deterministic style decision for a fixed `AlnProgram`, `RoutingContext`, and `RegistryIndex`.
- Correct fallback behavior when no ALN contracts match (style selected purely by invariants/metrics per router spec).
- Event eligibility toggling when metrics cross thresholds (e.g., ARR below target disables certain events).

Integration tests:

- Load live `core/registry/*.json` and ensure:
  - All styles selected by routing exist in `registrystyles.json` and match the `stylecontractv1` schema.
  - Event decisions always reference events whose `schemaref` and tier are allowed for the context.

### 6.3 PowerShell Suite

Pester tests:

- Commands exit non-zero when underlying Python/Node validators fail.
- `Invoke-HpLeakScan` detects URLs, data URIs, and Base64 patterns in temp directories.
- `Invoke-HpAlnParse`:
  - Succeeds on valid ALN JSON.
  - Fails on invalid invariant/metric keys.
- `Invoke-HpRoutingDryRun`:
  - Produces well-formed JSON decisions for a minimal setup.
- Cross-platform behavior on Windows and Linux containers:
  - Validate path handling and external tool invocation.

---

## 7. Schema Authority Behavior (Sprint 1 Outcome)

Once implemented according to this design, Horror.Place gains:

1. **Central contract enforcement**  
   - ALN contracts and routing behavior are constrained by public schemas and registries; engines and vaults cannot define new behavior without updating core schemas.

2. **Invariant/metric-governed routing**  
   - Styles, events, and personas are chosen by evaluating invariants (CIC, AOS, SHCI, etc.) and metrics (UEC, EMD, STCI, CDL, ARR) rather than by ad-hoc logic.

3. **CI-enforced compliance**  
   - PowerShell tools plus existing CI pipelines validate schemas, registries, ALN programs, and routing decisions on every change, forming a stable base for later Dead-Ledger and ZKP integration.

4. **Safe downstream reuse**  
   - Vault and lab repositories reference Horror.Place contracts as their doctrinal spine; their own files remain implementation details and telemetry envelopes, projecting back into these canonical schemas.

This Sprint 1 design activates the ALN parser, routing engine, and PowerShell integration suite as the core technical components needed for Horror.Place to operate as a contract-driven Schema Authority while remaining compatible with the VM-Constellation and Dead-Ledger doctrine.  
