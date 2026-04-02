# CI + KMS Binding for the Horror$Place VM-Constellation

## 1. Purpose

This document declares the CircleCI templates and KMS/HSM policies that all Horror$Place repositories MUST use when validating, hashing, signing, and promoting artifacts across tiers.[file:10][file:12][file:15]

It aligns:
- The **Horror.Place-Orchestrator** service,
- Tier-2 vaults such as **Liminal-Continuum** and **Obscura-Nexus**, and
- Tier-3 labs such as **Neural-Resonance-Lab**, **Redacted-Chronicles**, and **Process-Gods-Research**[file:10][file:11]
with a single, declarative CI/KMS doctrine.

## 2. Canonical CI Templates

### 2.1 Orchestrator CI Template

The file:

- `ci-templates/circleci-orchestrator-template.yml`

is the **only** approved template for orchestrator-style services.[file:15][file:10] It MUST be used by:

- `Horror.Place-Orchestrator` (service repo)
- Any future Tier-1 or Tier-2 coordinator services.

This template is responsible for:

- Validating incoming artifacts (agents, style contracts, registry patches) against Tier-1 schemas.
- Verifying hashes and signatures using public keys managed under the KMS/HSM policy.
- Applying registry updates idempotently, with rollback on failure.[file:10][file:15]

### 2.2 Vault/Lab CI Template

The file:

- `ci-templates/circleci-vault-validate-template.yml`

is the **baseline vault/lab CI template**.[file:14][file:10] It MUST be imported or copied into:

- `HorrorPlace-Neural-Resonance-Lab`
- `HorrorPlace-Redacted-Chronicles`
- `HorrorPlace-Process-Gods-Research`
- `HorrorPlace-Liminal-Continuum`
- `HorrorPlace-Obscura-Nexus`

Each repo specializes only:

- **Paths** to validate (e.g., `telemetry/*.json`, `agents/*.json`, `contracts/styles/*.json`).
- **Schemas** to enforce (e.g., `agent_artifact_v1`, `telemetry_summary_v1`, `style_contract_v1`).
- **Dispatch targets** (e.g., Liminal-Continuum vs Horror.Place-Orchestrator).[file:10][file:11]

All variants MUST keep:

- Schema validation,
- Hash computation,
- KMS-backed signing,
- Secret scanning/leak detection,
unless explicitly exempted for research-only branches.

## 3. Artifact Classes and KMS Policy

KMS/HSM integration is governed by:

- `ops/kms_hsm_integration.md`

which defines Ed25519 as the default algorithm, rotation procedures, and audit requirements.[file:10][file:11]

This project binds signing policy to tiers as follows:

- **Tier-3 Labs (Neural-Resonance-Lab, Redacted-Chronicles, Process-Gods-Research):**
  - Artifact classes: telemetry summaries, BCI rule contracts, persona seed packs.
  - Signing: **single-party** with lab-specific keys (e.g., `kms/neural-lab`, `kms/telemetry-summary`).[file:10][file:11]
  - Purpose: integrity and provenance inside the underground network.

- **Tier-2 Vaults (Liminal-Continuum, Obscura-Nexus):**
  - Artifact classes: agent artifacts (`agents/*.json`), dead-ledger entries (`dead_ledger/*.json`), style and event contracts.[file:10]
  - Signing:
    - Single-party for internal or experimental artifacts.
    - **2-of-N multi-party** for any artifact that:
      - Proposes changes to Tier-1 registries, or
      - Alters long-term agent reputation in the dead ledger.
  - Purpose: enforce trust for marketplace-facing and promotion candidates.

- **Tier-1 Core (Horror.Place):**
  - Artifact classes: registry patches, schema/contract updates.
  - Signing: **2-of-N mandatory** (operator + approver keys) before merge to `main`.
  - Purpose: protect the public rules engine from tampering while keeping it auditable.[file:10][file:12]

## 4. Required .circleci/config.yml Patterns

Each adopting repository MUST create a `.circleci/config.yml` that either:

1. Imports the appropriate template via CircleCI `orbs`/`include`, or  
2. Copies it verbatim and changes only:

   - `VALIDATION_PATHS` and `SCHEMA_MAP`,
   - `KMS_KEY_ALIAS`,
   - `ORCHESTRATOR_REPO` for `repository_dispatch`.[file:14][file:15]

Examples:

- **Neural-Resonance-Lab**:
  - Validate `telemetry/*.json` and `contracts/bci_rules/*.json`.
  - Use `KMS_KEY_ALIAS=neural-lab-telemetry`.
  - Dispatch to `HorrorPlace-Liminal-Continuum` on new summaries.[file:10][file:11]

- **Liminal-Continuum**:
  - Validate `agents/*.json` and `dead_ledger/*.json`.
  - Use `KMS_KEY_ALIAS=liminal-continuum-agents`.
  - Dispatch to `Horror.Place-Orchestrator` on new preferred agents.[file:10][file:15]

- **Obscura-Nexus**:
  - Validate `contracts/styles/*.json` and `contracts/events/*.json`.
  - Use `KMS_KEY_ALIAS=obscura-nexus-styles`.
  - Dispatch to `Horror.Place-Orchestrator` when new styles/events are ready for registry inclusion.[file:10][file:11]

## 5. Scope and Future Extensions

This binding does not define artifact schemas themselves; those remain in:

- `docs/schemas/*.md` and `schemas/*.json` in Horror.Place.[file:10][file:12]

Its purpose is to:

- Ensure all Tier-2 and Tier-3 repositories use consistent validation, hashing, and signing procedures.
- Make the CI/KMS flow a first-class part of the VM-constellation doctrine.
- Provide a clear, auditable path from underground artifacts to public registry entries.

Future revisions may:

- Add explicit ZKP-based access control to CI pipelines.
- Introduce differentiated keys for research vs production artifacts inside the same repo.

For now, any new Horror$Place repository that wishes to participate in the constellation MUST either:
- Adopt these templates and KMS policies, or
- Document, in this file, why it is exempt and how it remains compatible with the doctrine.[file:10][file:11]
