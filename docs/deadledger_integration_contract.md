---
title: Horror.Place ↔ Dead-Ledger Integration Contract
status: draft
version: v1.0.0
---

# Horror.Place ↔ Dead-Ledger Integration Contract

This document specifies how the public Horror.Place core interacts with the HorrorPlace-Dead-Ledger-Network. It defines:

- How artifacts and registries embed `deadledgerref`.
- The structure of signed artifact envelopes.
- How Horror.Place services call Dead-Ledger (SessionRegistry, CapabilityAttestor, PolicyGuard).
- How decision tokens influence CI and generation workflows.

The integration is designed around **opaque references and cryptographic attestations**; no raw trauma data or user identity leaves private repositories.

---

## 1. deadledgerref embedding

### 1.1 In registries

Tier-1 registries (events, styles, personas, invariant bundles) may include a `deadledgerref` field in each entry:

- `deadledgerref`: opaque string or URI referencing a Dead-Ledger record that:
  - Binds an artifact to its producer identity.
  - Records invariant and metric envelopes.
  - Records validation and audit outcomes.

Example (invariant bundle entry):

```json
{
  "bundle_id": "EXAMPLE_EIDOVILLEVALLEY_BASELINE",
  "schemaref": "schema://Horror.Place/core/schemas/historyinvariantsv1.json",
  "artifact_ref": "deadledgerref://HorrorPlace-Black-Archivum/invariantbundles/eidoville_valley_v1",
  "deadledgerref": "dl://horrorplace-deadledger/mainnet/records/abc123",
  "metadata": {
    "name": "Eidoville Valley Baseline",
    "safety_tier": "standard",
    "intensity_band": "moderate",
    "tags": ["valley", "industrial_runoff", "irrigation_disaster"]
  }
}
```

Tier-1 code treats `deadledgerref` as opaque; it is only resolved by services with access to Dead-Ledger.

### 1.2 In contracts and signatures

- First-pass signatures may include an optional `dead_ledger_tx` field, populated after a successful registration.
- Event and persona contracts may include `deadledgerref` to indicate that their current version has been attested.

---

## 2. Artifact envelopes

Dead-Ledger stores signed artifact envelopes that summarize the state of a contract or asset without exposing implementation details.

### 2.1 Envelope structure (conceptual)

An artifact envelope (schema defined in the Dead-Ledger repo) includes:

- `artifact_id`: ID of the contract or asset (e.g., event_id, persona_id, bundle_id).
- `schema_ref`: URI of the schema the artifact conforms to.
- `producer_id`: DID or key identifier for the producing VM or repository.
- `impl_hash`: SHA-256 hash of the implementation artifact (code, JSON, or compiled form).
- `constraints_hash`: SHA-256 hash from the signature (schema_ref + contract_id + envelopes).
- `metrics_summary`: compact summary (e.g., mean UEC/EMD/STCI/CDL/ARR, counts).
- `policy_profile_id`: one of STANDARD_V1, MATURE_V1, RESEARCH_V1.
- `signature`: cryptographic signature over the envelope body by the producer or attestor key.

Horror.Place only ever sees the `deadledgerref` and, optionally, the envelope header fields; private repos see full content as permitted.

---

## 3. Dead-Ledger services and APIs

### 3.1 SessionRegistry

The SessionRegistry contract is responsible for session integrity and replay protection.

- **Inputs**:
  - `session_id`
  - `github_actor`, `github_repo`
  - `issued_at`, `expires_at`
  - `network_domain` (e.g., `prod`, `staging`)
  - `constraints_hash`

- **Behavior**:
  - Rejects duplicate active sessions with the same `session_id` and domain.
  - Ensures current time is within `[issued_at, expires_at]`.
  - Records `workflow_run_id` or CI build number to prevent cross-environment replay.

- **Interface**:
  - HTTP(S) endpoints for:
    - `POST /sessions/register`
    - `GET /sessions/{session_id}/status`

Horror.Place CI calls these endpoints from `scripts/validatesignature.py` as part of the signature validation process.

### 3.2 CapabilityAttestor

The CapabilityAttestor contract validates capability tokens and their compatibility with policy profiles.

- **Inputs**:
  - `capability_token_id`
  - `bound_session_id`
  - `policy_profile_id`
  - `entitlement_tier`
  - `constraints_hash`

- **Behavior**:
  - Verifies the capability token signature.
  - Ensures the token’s allowed schemas, repos, and operations cover the request.
  - Ensures the token’s `policy_profile` and `entitlement_tier` are consistent with this document.

- **Outputs**:
  - An attestation ID (opaque) that may be listed in `aln_contract_ids` in signatures.
  - A decision status (APPROVED/DENIED) with a compact reason code.

### 3.3 PolicyGuard

The PolicyGuard contract is responsible for enforcing high-level policy, including:

- Tier boundaries (STANDARD/MATURE/RESEARCH).
- Rivers-of-Blood Charter rules.
- Cross-repo and cross-tier movement restrictions.

- **Inputs**:
  - `policy_profile_id`
  - `entitlement_tier`
  - `schema_ref`
  - `style_ids`
  - `persona_ids`

- **Behavior**:
  - Rejects STANDARD profiles that reference MATURE or RESEARCH-only styles or personas.
  - Rejects signatures that violate invariant or metric caps defined in the policy profiles.
  - Returns a simple allow/deny result and a reason code.

---

## 4. CI and workflow integration

### 4.1 First-pass signature validation

The `scripts/validatesignature.py` script must:

1. Validate the signature against `signaturev1.json`.
2. Verify time bounds and envelope ranges locally.
3. Call Dead-Ledger APIs:
   - `SessionRegistry` to validate the session.
   - `CapabilityAttestor` to validate the capability token.
   - `PolicyGuard` to validate policy and tier constraints.

If any call returns a negative decision, the CI job fails and no generator runs.

### 4.2 Generator and provenance

When the generator completes successfully:

- It writes or updates the artifact at `target_path`.
- CI computes `impl_hash` and reuses `constraints_hash` from the signature.
- CI calls a Dead-Ledger endpoint (e.g., `POST /artifacts/envelope`) to register the new envelope.
- Dead-Ledger returns a `dead_ledger_tx` or record ID.
- CI may update the registry entry or signature metadata to include this ID.

---

## 5. Security and privacy constraints

- No raw trauma data, user identity, or BCI samples are stored in the Horror.Place repo.
- Dead-Ledger only stores envelopes and opaque references; any sensitive content remains in private vaults and labs.
- All interactions with Dead-Ledger are over authenticated HTTPS using standard cryptographic libraries.
- Keys are managed outside the public repo (e.g., in HSM, KMS, or secure secret stores); the repo only contains schema and protocol definitions.

Any change to Dead-Ledger schema or APIs must keep these constraints and update this document accordingly.
