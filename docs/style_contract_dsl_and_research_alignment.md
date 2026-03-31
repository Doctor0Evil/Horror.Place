***

# Style Contract DSL & Research Alignment for Horror$Place  
`docs/style_contract_dsl_and_research_alignment.md`

***

## 1. Purpose and Fit with the 12-File Foundation

This spec defines a **Style Contract DSL** and validator layer that ties directly into your 12-file foundation and the Horror$Place research plan you outlined. It turns the high-level goals (procedural implication, GitHub-compliant horror, underground knowledge tiers) into **machine-enforceable contracts** for every artstyle, script, and AI-assisted output.

When complete, this DSL and validator will:

- Sit beside `entertainment_metrics_v1.json`, the AI chat templates, and the style lint/enforcement modules as the **single source of truth** for horror style rules.  
- Make it trivial for AI chat flows and PCG systems to **ask for a style** (e.g., Rivers of Blood engraving, Machine Canyon/Biomech/BCI) and receive strict constraints in return.  
- Guarantee that all generated content respects:
  - History invariants (CIC, MDI, AOS, etc.).  
  - Player metrics (UEC, EMD, STCI, CDL, ARR).  
  - GitHub-safe **procedural implication** (evidence-based horror only).  

This spec is written to be **safe to host on GitHub**: it encodes *how* to structure horror, not explicit content.

***

## 2. DSL Goals and Principles

### 2.1 Design Goals

The Style Contract DSL must:

1. **Express Artstyles as Data**  
   Everything that defines a style—visual constraints, invariant requirements, metrics, composition, BCI/haptic mapping—is represented in **declarative config** (JSON/YAML) rather than ad-hoc Lua.  

2. **Drive Code Generation and Validation**  
   - Style Router reads contracts to pick styles.  
   - Style Linter reads contracts to enforce them.  
   - AI templates read contracts to condition generation.  

3. **Enforce Procedural Implication**  
   The DSL explicitly distinguishes between **allowed evidence** and **forbidden depictions**. All horror must occur via implication, archival gaps, and spectral residue.

4. **Support Safety Tiers and Build Flags**  
   Each contract has fields for `safety_tier` and `allowed_builds`, which connect directly to `Cargo.toml` feature flags (`standard`, `mature`, `research`).

### 2.2 Core Principle

> Styles are **cryptographically sober contracts** between the history layer, the engine, and AI tools, not just aesthetic hints.

***

## 3. Style Contract DSL Schema

Filename:  
`horror_place_core/docs/schemas/style_contract_v1.json`

This JSON Schema defines a single **style contract** document.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "HorrorPlaceStyleContract",
  "type": "object",
  "required": ["id", "version", "safety_tier", "invariants", "metrics", "visual", "semantic", "implication_rules"],
  "properties": {
    "id": {
      "type": "string",
      "pattern": "^[A-Z0-9_]+$"
    },
    "version": {
      "type": "string",
      "pattern": "^v[0-9]+\\.[0-9]+$"
    },
    "safety_tier": {
      "type": "string",
      "enum": ["standard", "mature", "research"]
    },
    "allowed_builds": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["standard", "mature", "research"]
      },
      "minItems": 1
    },
    "invariants": {
      "type": "object",
      "required": ["min", "recommended"],
      "properties": {
        "min": {
          "type": "object",
          "properties": {
            "CIC": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "MDI": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "AOS": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "RRM": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "FCF": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "SPR": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "RWF": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "DET": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "LSG": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
            "SHCI": { "type": "number", "minimum": 0.0, "maximum": 1.0 }
          },
          "additionalProperties": false
        },
        "recommended": {
          "type": "object",
          "additionalProperties": { "type": "number", "minimum": 0.0, "maximum": 1.0 }
        }
      }
    },
    "metrics": {
      "type": "object",
      "properties": {
        "UEC": { "type": "object", "properties": { "min": { "type": "number" }, "max": { "type": "number" } }, "required": ["min", "max"] },
        "EMD": { "type": "object", "properties": { "min": { "type": "number" }, "max": { "type": "number" } }, "required": ["min", "max"] },
        "STCI": { "type": "object", "properties": { "min": { "type": "number" }, "max": { "type": "number" } }, "required": ["min", "max"] },
        "CDL": { "type": "object", "properties": { "min": { "type": "number" }, "max": { "type": "number" } }, "required": ["min", "max"] },
        "ARR": { "type": "object", "properties": { "min": { "type": "number" }, "max": { "type": "number" } }, "required": ["min", "max"] }
      },
      "additionalProperties": false
    },
    "visual": {
      "type": "object",
      "properties": {
        "palette": {
          "type": "object",
          "properties": {
            "monochrome_only": { "type": "boolean" },
            "max_saturation": { "type": "number", "minimum": 0.0, "maximum": 1.0 }
          }
        },
        "composition_tags_required": {
          "type": "array",
          "items": { "type": "string" }
        },
        "lighting_tags_required": {
          "type": "array",
          "items": { "type": "string" }
        }
      }
    },
    "semantic": {
      "type": "object",
      "properties": {
        "mood_tags_required": { "type": "array", "items": { "type": "string" } },
        "subject_tags_required": { "type": "array", "items": { "type": "string" } }
      }
    },
    "bci_haptics": {
      "type": "object",
      "properties": {
        "requires_bci": { "type": "boolean" },
        "channels": { "type": "array", "items": { "type": "string" } }
      }
    },
    "implication_rules": {
      "type": "object",
      "required": ["explicit_violence_forbidden", "evidence_types_allowed"],
      "properties": {
        "explicit_violence_forbidden": { "type": "boolean" },
        "evidence_types_allowed": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": [
              "bloodstained_object",
              "disturbed_earth",
              "contradictory_record",
              "missing_person_reference",
              "spectral_testimony_fragment",
              "empty_space_implication"
            ]
          }
        }
      }
    }
  }
}
```

This schema is fully GitHub-safe: it defines ranges, tags, and implication categories. It never contains explicit content.

***

## 4. Example Style Contracts (Data-Only)

### 4.1 Rivers-of-Blood Engraving Style (Compact Example)

Filename:  
`horror_place_core/docs/styles/spectral_engraving_dark_sublime.json`

```json
{
  "id": "SPECTRAL_ENGRAVING_DARK_SUBLIME",
  "version": "v1.0",
  "safety_tier": "mature",
  "allowed_builds": ["mature", "research"],
  "invariants": {
    "min": {
      "CIC": 0.75,
      "MDI": 0.70,
      "AOS": 0.60,
      "SPR": 0.70,
      "SHCI": 0.80
    },
    "recommended": {
      "LSG": 0.70,
      "RRM": 0.50
    }
  },
  "metrics": {
    "UEC":  { "min": 0.60, "max": 0.80 },
    "EMD":  { "min": 0.70, "max": 0.90 },
    "STCI": { "min": 0.50, "max": 0.70 },
    "CDL":  { "min": 0.70, "max": 0.90 },
    "ARR":  { "min": 0.75, "max": 1.00 }
  },
  "visual": {
    "palette": {
      "monochrome_only": true,
      "max_saturation": 0.05
    },
    "composition_tags_required": [
      "composition_radial_divine_core",
      "composition_lone_figure_scale_anchor"
    ],
    "lighting_tags_required": [
      "lighting_backlit_celestial_shaft",
      "lighting_halo_corona_edges"
    ]
  },
  "semantic": {
    "mood_tags_required": [
      "mood_cosmic_dread",
      "mood_devotional_horror"
    ],
    "subject_tags_required": [
      "subject_human_body_cluster_entity",
      "subject_lone_cloaked_observer"
    ]
  },
  "bci_haptics": {
    "requires_bci": false,
    "channels": []
  },
  "implication_rules": {
    "explicit_violence_forbidden": true,
    "evidence_types_allowed": [
      "bloodstained_object",
      "contradictory_record",
      "spectral_testimony_fragment",
      "empty_space_implication"
    ]
  }
}
```

### 4.2 Machine Canyon Biomech + BCI Style (Compact Example)

Filename:  
`horror_place_core/docs/styles/machine_canyon_biomech_bci.json`

```json
{
  "id": "MACHINE_CANYON_BIOMECH_BCI",
  "version": "v1.0",
  "safety_tier": "mature",
  "allowed_builds": ["mature", "research"],
  "invariants": {
    "min": {
      "CIC": 0.60,
      "MDI": 0.50,
      "AOS": 0.70,
      "FCF": 0.60,
      "SPR": 0.65,
      "SHCI": 0.70
    },
    "recommended": {
      "RRM": 0.50,
      "LSG": 0.60
    }
  },
  "metrics": {
    "UEC":  { "min": 0.50, "max": 0.75 },
    "EMD":  { "min": 0.60, "max": 0.85 },
    "STCI": { "min": 0.40, "max": 0.70 },
    "CDL":  { "min": 0.70, "max": 0.90 },
    "ARR":  { "min": 0.70, "max": 1.00 }
  },
  "visual": {
    "palette": {
      "monochrome_only": false,
      "max_saturation": 0.20
    },
    "composition_tags_required": [
      "composition_canyon_corridor",
      "composition_lone_figure_bottom_center"
    ],
    "lighting_tags_required": [
      "lighting_internal_furnace_glow",
      "lighting_env_foggy_smoke"
    ]
  },
  "semantic": {
    "mood_tags_required": [
      "mood_existential_mechanical_dread",
      "mood_lost_in_megastructure"
    ],
    "subject_tags_required": [
      "subject_machine_walls",
      "subject_cable_web"
    ]
  },
  "bci_haptics": {
    "requires_bci": true,
    "channels": [
      "haptic_floor_vibration",
      "haptic_cable_tension",
      "haptic_breath_chest"
    ]
  },
  "implication_rules": {
    "explicit_violence_forbidden": true,
    "evidence_types_allowed": [
      "disturbed_earth",
      "contradictory_record",
      "missing_person_reference",
      "spectral_testimony_fragment",
      "empty_space_implication"
    ]
  }
}
```

These JSON files are what your linters, router, and AI templates read.

***

## 5. DSL Integration Points with the 12-File Plan

This DSL threads through the remaining foundation files:

- **File 8 (pcg_generator.rs)**  
  - PCG reads style contracts to know **what environmental evidence** it can place (e.g., `bloodstained_object`, `disturbed_earth`) and what it must avoid.  

- **File 9 (audio_automation.rs)**  
  - Audio system reads `visual.lighting_tags_required` and `semantic.mood_tags_required` to pick **sound palettes** aligned with style.  

- **File 10 (entertainment_metrics_v1.json)**  
  - Metrics schema includes validation similar to `metrics` fields here; DSL just binds particular ranges to each style.  

- **File 11 (ai_chat_templates.lua)**  
  - Chat templates read `implication_rules` and `evidence_types_allowed` to automatically **block explicit descriptions** and steer responses toward evidence, archival gaps, or spectral fragments.  

- **File 12 (Cargo.toml)**  
  - Feature flags `standard`, `mature`, `research` are validated against `allowed_builds` and `safety_tier` for each style: in `standard` builds, mature styles are simply not routable.

***

## 6. Validator: Linking DSL to StyleLint & Runtime

You already have a style linter and runtime validator spec. Now they simply read the DSL instead of hardcoding ranges.

- Static tools:
  - Validate style JSON against `style_contract_v1.json`.  
  - Validate content packs to ensure:
    - Tags satisfy `composition_tags_required`, `lighting_tags_required`, etc.  
    - `explicit_violence_forbidden` is respected in AI templates and metadata (only evidence types in `evidence_types_allowed` appear).  

- Runtime:
  - When StyleRouter chooses a style, `RuntimeStyleValidator` compares actual invariants/metrics against `invariants.min` and `metrics.*`.  
  - Telemetry captures deviations to refine PCG and pacing over time. [oneuptime](https://oneuptime.com/blog/post/2026-02-06-monitor-game-analytics-pipeline-opentelemetry/view)

***

## 7. GitHub & Underground Alignment

Because this DSL:

- Explicitly forbids explicit violence at the contract level.  
- Restricts horror to **evidence types** that are safe and implication-based.  

It supports your plan:

- **Tier 1 (GitHub Core):** All style contracts in the repo are safe; they describe structure, not gore.  
- **Tier 2 (Codebases-of-Death):** Additional styles or extended ranges could live off-GitHub, but still use the same schema.  
- **Tier 3 (Research Sandbox):** `safety_tier = "research"` styles integrate with BCI/fMRI data while respecting explicitness constraints.

***
