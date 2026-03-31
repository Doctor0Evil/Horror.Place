# Style Lint Enforcement Module Specification
### Horror$Place Asset Validation Engine v1.0

> *"Every pixel must answer to history. Every shadow must justify its existence."*

***

## 1. Module Overview

The **Style Lint Enforcement Module** is the automated gatekeeper that ensures all visual assets, style configurations, and runtime behaviors comply with Horror$Place's core doctrine. It operates at two levels:

1.  **Static Validation (Pre-Merge):** Scans asset files, textures, and style contracts before they enter the repository.
2.  **Runtime Validation (In-Game):** Monitors active styles during gameplay to detect drift or charter violations.

Inspired by the rigorous asset pipelines of *Darkwood* (Acid Wizard Studio) and the uncompromising design philosophy of *Pathologic* (Ice-Pick Lodge), StyleLint treats style violations not as aesthetic preferences but as **doctrine breaches** that undermine the historical grounding of horror.

### Core Responsibilities
1.  **Contract Validation:** Ensures assets match their declared style contract (`spectral_engraving` or `machine_canyon`).
2.  **Charter Compliance:** Blocks any asset violating the `Rivers of Blood Charter` (explicit violence, gratuitous gore).
3.  **Invariant Binding:** Verifies that assets have proper CIC/AOS/RRM bindings from the `Spectral Library`.
4.  **Metric Alignment:** Checks that assets contribute to target entertainment metrics (UEC, EMD, ARR).
5.  **CI/CD Integration:** Runs automatically on every pull request via GitHub Actions.

***

## 2. Architecture & Pipeline

### 2.1 Validation Flow

```
Asset Submission → StyleLint Static Scan → Charter Check → 
Invariant Binding Verify → CI/CD Gate → Merge/Reject → 
Runtime Monitor (In-Game) → Telemetry Log
```

### 2.2 Tool Components

| Component | Path | Purpose |
|-----------|------|---------|
| **StyleLint Core** | `tools/style_lint.lua` | Main validation engine (Lua-based for cross-engine compatibility). |
| **Contract Loader** | `tools/load_style_contract.lua` | Parses JSON style contracts from `artstyles/` directory. |
| **Charter Validator** | `tools/validate_charter.lua` | Checks assets against `Rivers of Blood Charter` forbidden tags. |
| **Invariant Checker** | `tools/verify_invariants.lua` | Ensures assets have CIC/AOS/RRM bindings from `spectral_library.rs`. |
| **Runtime Monitor** | `src/style_runtime_validator.rs` | In-game style drift detection (logs violations to telemetry). |
| **CI/CD Action** | `.github/workflows/style_lint.yml` | Automated GitHub Actions pipeline for pre-merge validation. |

***

## 3. Static Validation Rules

### 3.1 Style Contract Compliance

Each asset must declare its target style and pass contract-specific checks.

#### Spectral Engraving (Dark Sublime) Rules

| Rule ID | Check | Failure Condition | Severity |
|---------|-------|-------------------|----------|
| `SE-001` | Palette Saturation | Saturation > 60% | **Block** |
| `SE-002` | Accent Colors | Colors outside [`#5C2A2A`, `#2F4F2F`, `#F0F0F0`] | **Block** |
| `SE-003` | Camera Constraints | Asset requires camera rotation | **Block** |
| `SE-004` | FOV Compatibility | Asset invisible at 90° top-down FOV | **Warning** |
| `SE-005` | Occlusion Layers | Asset lacks foreground occlusion mesh | **Warning** |
| `SE-006` | Invariant Binding | Missing CIC/AOS binding metadata | **Block** |
| `SE-007` | Charter Compliance | Contains explicit gore/corpse tags | **Block** |

#### Machine Canyon (Biomech BCI) Rules

| Rule ID | Check | Failure Condition | Severity |
|---------|-------|-------------------|----------|
| `MC-001` | Palette Saturation | Saturation > 50% | **Block** |
| `MC-002` | Accent Colors | Colors outside [`#FFBF00`, `#4A2C2A`, `#E0E0E0`] | **Block** |
| `MC-003` | Corridor Width | Asset requires > 2.0m passage | **Block** |
| `MC-004` | Ceiling Type | Asset exposes open sky | **Block** |
| `MC-005` | Light Source | Asset uses natural light (sun/moon) | **Block** |
| `MC-006` | Invariant Binding | Missing RRM/FCF binding metadata | **Block** |
| `MC-007` | BCI Feature Gate | Experimental features lack `research` flag | **Block** |
| `MC-008` | Charter Compliance | Shows visible bodies in machinery | **Block** |

### 3.2 Charter Compliance Checks

All assets must pass the `Rivers of Blood Charter` validation (File 3).

| Forbidden Tag | Detection Method | Action |
|---------------|------------------|--------|
| `explicit_gore` | Texture analysis + metadata scan | **Block + Log** |
| `gratuitous_violence` | Animation tag inspection | **Block + Log** |
| `random_jump_scare` | Audio trigger analysis | **Block + Log** |
| `sexualized_violence` | Metadata + manual review flag | **Block + Escalate** |
| `real_tragedy_trivialization` | Historical cross-reference check | **Block + Escalate** |

### 3.3 Invariant Binding Verification

Assets must declare which historical invariants they respond to. This ensures the `Spectral Library` (File 2) can drive asset behavior at runtime.

```json
// Example: Asset Metadata Block (embedded in asset file)
{
  "asset_id": "wall_rusted_01",
  "style_contract": "spectral_engraving_dark_sublime",
  "invariant_bindings": {
    "CIC": { "min": 0.5, "max": 1.0, "effect": "decay_density" },
    "AOS": { "min": 0.6, "max": 0.9, "effect": "texture_noise" }
  },
  "entertainment_targets": {
    "UEC": { "contribution": 0.15 },
    "EMD": { "contribution": 0.20 }
  },
  "charter_compliance": {
    "evidence_based": true,
    "implication_only": true
  }
}
```

**Validation Rule:** Assets without `invariant_bindings` are rejected. This prevents "orphan assets" that exist outside the historical grounding system.

***

## 4. Runtime Validation (In-Game)

### 4.1 Style Drift Detection

The `Style Runtime Validator` monitors active styles during gameplay to detect violations that static analysis cannot catch.

| Drift Type | Detection Method | Response |
|------------|------------------|----------|
| **Palette Drift** | Real-time color histogram analysis | Log warning + auto-correct via post-process |
| **Lighting Violation** | Natural light detected in `machine_canyon` | Force artificial light override |
| **Geometry Breach** | Corridor width > 2.0m in `machine_canyon` | Trigger fog occlusion to hide violation |
| **Charter Breach** | Explicit content rendered (debug/cheat) | Immediate session termination + log |
| **Invariant Desync** | Asset active in wrong CIC/RRM zone | Swap asset to correct variant |

### 4.2 Telemetry Logging

Runtime violations are logged to telemetry for analysis. This data feeds back into the `Entertainment Metrics` system (File 1).

```json
// Example: Runtime Violation Log
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2026-01-15T14:32:00Z",
  "violation_type": "palette_drift",
  "style_contract": "spectral_engraving_dark_sublime",
  "detected_value": { "saturation": 0.72 },
  "threshold_value": { "max_saturation": 0.60 },
  "auto_corrected": true,
  "metric_impact": { "UEC_delta": -0.05 }
}
```

***

## 5. CI/CD Integration

### 5.1 GitHub Actions Workflow

```yaml
# .github/workflows/style_lint.yml
name: StyleLint Validation

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  style_lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Lua Runtime
        uses: leafo/gh-actions-lua@v8
        with:
          luaVersion: "5.4"
      
      - name: Run StyleLint
        run: |
          lua tools/style_lint.lua \
            --contracts artstyles/ \
            --assets assets/ \
            --charter docs/rivers_of_blood_charter.md \
            --output lint_report.json
      
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: style_lint_report
          path: lint_report.json
      
      - name: Block on Violations
        if: failure()
        run: |
          echo "StyleLint violations detected. Merge blocked."
          exit 1
```

### 5.2 Report Schema

```json
{
  "lint_version": "1.0.0",
  "scan_timestamp": "2026-01-15T10:00:00Z",
  "total_assets_scanned": 1247,
  "violations": [
    {
      "asset_path": "assets/textures/wall_blood_01.png",
      "rule_id": "SE-007",
      "severity": "block",
      "message": "Charter violation: explicit_gore tag detected",
      "recommendation": "Replace with dried stain variant (wall_rust_01)"
    }
  ],
  "summary": {
    "blocked": 3,
    "warnings": 12,
    "passed": 1232
  },
  "charter_compliance": {
    "evidence_based": true,
    "implication_only": true,
    "all_invariants_bound": true
  }
}
```

***

## 6. Workflow Integration (Asset Generation Sprints)

Inspired by *Darkwood 2* and *Ice-Pick Lodge* development methodologies, StyleLint integrates into asset generation sprints.

### 6.1 Sprint Phases

| Phase | Duration | StyleLint Role |
|-------|----------|----------------|
| **Photogrammetry** | Week 1 | Scan validation (saturation, color space) |
| **Modular Kit Build** | Week 2 | Invariant binding assignment |
| **Integration Test** | Week 3 | Full contract compliance scan |
| **Playtest Validation** | Week 4 | Runtime drift monitoring + telemetry |

### 6.2 Developer Tools

| Tool | Purpose | Integration |
|------|---------|-------------|
| **Unreal Editor Plugin** | Real-time style validation in-editor | Highlights violations as assets are placed |
| **Unity Package** | StyleLint for Unity-based projects | Custom inspector window with contract checks |
| **CLI Tool** | Command-line validation for CI/CD | `style_lint --check assets/` |
| **VS Code Extension** | Inline linting for style contracts | JSON schema validation + quick fixes |

### 6.3 Asset Generation Automation

StyleLint works with AI-assisted asset generation tools to ensure automated content respects style contracts.

```lua
-- Example: AI Asset Generation Hook (tools/ai_asset_gen.lua)
function generate_asset(prompt, style_contract, invariants)
    -- Query StyleLint for contract rules
    local rules = load_style_contract(style_contract)
    
    -- Constrain AI generation parameters
    local constraints = {
        max_saturation = rules.palette_constraints.max_saturation,
        allowed_colors = rules.palette_constraints.allowed_accent_colors,
        forbidden_tags = rules.forbidden_tags
    }
    
    -- Generate asset with constraints
    local asset = ai_generate(prompt, constraints)
    
    -- Validate before saving
    local validation = style_lint_validate(asset, rules)
    if not validation.passed then
        return nil, validation.errors
    end
    
    -- Embed invariant bindings
    asset.metadata.invariant_bindings = invariants
    
    return asset, nil
end
```

***

## 7. Entertainment Metric Correlation

StyleLint does not just validate aesthetics; it tracks how style compliance affects player experience.

### 7.1 Metric Impact Tracking

| Style Rule | Metric Affected | Target Impact |
|------------|-----------------|---------------|
| Saturation < 60% | UEC (Uncertainty Engagement) | Maintain 0.55–0.85 |
| Invariant Binding | EMD (Evidential Mystery Density) | Maintain 0.60–0.90 |
| Lighting Contrast | STCI (Safe-Threat Contrast) | Maintain 0.40–0.70 |
| No Explicit Gore | ARR (Ambiguous Resolution Ratio) | Maintain 0.70–1.00 |
| Claustrophobic Geometry | CDL (Cognitive Dissonance Load) | Maintain 0.70–0.95 |

### 7.2 Telemetry Feedback Loop

```
StyleLint Violation → Runtime Log → Telemetry Aggregation → 
Metric Impact Analysis → Contract Tuning → Sprint Retrospective
```

If a style rule consistently correlates with negative metric impacts (e.g., saturation limits causing player confusion rather than uncertainty), the contract can be amended through the `Rivers of Blood Charter` amendment process (File 3, Section 8).

***

## 8. Reference Cases (Darkwood & Pathologic)

| Feature | Darkwood Implementation | Horror$Place StyleLint Adaptation |
|---------|-------------------------|-----------------------------------|
| **Asset Validation** | Manual review by Acid Wizard team | Automated StyleLint + CI/CD gates |
| **Style Consistency** | Hand-crafted textures, strict palette | Contract-enforced palette + saturation limits |
| **Charter Compliance** | Design philosophy (unwritten) | Machine-enforced `Rivers of Blood Charter` |
| **Runtime Monitoring** | None (static assets) | Real-time drift detection + auto-correction |
| **Telemetry** | Limited (Steam stats only) | Full metric correlation (UEC, EMD, ARR, etc.) |

***

## 9. Compliance Checklist

Before any style-related change is merged:

- [ ] **Contract Check:** Does the asset match its declared style contract?
- [ ] **Charter Check:** Does the asset pass `Rivers of Blood Charter` validation?
- [ ] **Invariant Check:** Are CIC/AOS/RRM bindings present and valid?
- [ ] **Metric Check:** Does the asset contribute to target entertainment metrics?
- [ ] **CI/CD Check:** Did the GitHub Actions StyleLint workflow pass?
- [ ] **Runtime Check:** Has the asset been tested for drift in-game?

***

## 10. Machine-Readable Lint Schema

```json
{
  "lint_schema_version": "1.0.0",
  "validation_endpoints": {
    "static_lint": "tools/style_lint.lua",
    "runtime_validator": "src/style_runtime_validator.rs",
    "charter_check": "tools/validate_charter.lua"
  },
  "severity_levels": {
    "block": "Merge denied, violation must be fixed",
    "warning": "Merge allowed, violation logged for review",
    "info": "Suggestion only, no action required"
  },
  "rule_categories": [
    "palette_compliance",
    "geometry_constraints",
    "invariant_bindings",
    "charter_compliance",
    "metric_alignment"
  ],
  "auto_correct_rules": [
    "palette_drift",
    "lighting_violation",
    "invariant_desync"
  ],
  "escalation_rules": [
    "sexualized_violence",
    "real_tragedy_trivialization",
    "charter_breach_repeat"
  ]
}
```

***

**Document Status:** Active  
**Last Updated:** 2026-01-15  
**Maintainer:** Horror$Place Engine Team  
**Related Files:** `docs/rivers_of_blood_charter.md`, `docs/artstyle_spectral_engraving_dark_sublime.md`, `docs/artstyle_machine_canyon_biomech_bci.md`, `schemas/entertainment_metrics_v1.json`
