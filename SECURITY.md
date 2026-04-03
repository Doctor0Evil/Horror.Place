# Security Policy & Threat Model

> **Repository:** `Horror.Place` (Public)  
> **Last Updated:** `2026-01-22`  
> **Contact:** `security@horror.place` (PGP: `0xDEADBEEFCAFE`)

---

## Supported Versions

| Version | Supported | End of Life |
|---------|-----------|-------------|
| `v1.2.x` | ✅ Yes | 2027-01-22 |
| `v1.1.x` | ✅ Yes | 2026-06-22 |
| `v1.0.x` | ⚠ Security fixes only | 2026-03-22 |
| `< v1.0` | ❌ No | EOL |

---

## Threat Model Overview

Horror.Place operates across three repository tiers with distinct trust boundaries:

```
┌─────────────────────────────────────┐
│ Tier 1: Public (Horror.Place)       │
│ • Schemas, specs, validation logic  │
│ • No raw horror content             │
│ • Attack surface: prompt injection, │
│   schema bypass, routing manipulation│
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Tier 2: Vault (Private, User-Gated) │
│ • AI personas, trauma archives,     │
│   spectral entities, PCG seeds      │
│ • Attack surface: data exfiltration,│
│   persona hijacking, seed poisoning │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ Tier 3: Lab (Private, Research)     │
│ • BCI/fMRI data, neural tuning,     │
│   ZKP/ledger infrastructure         │
│ • Attack surface: privacy leakage,  │
│   model inversion, consensus attacks│
└─────────────────────────────────────┘
```

### Key Assumptions
1. **Public repo is untrusted**: Any artifact from `Horror.Place` must be validated before use in Vault/Lab contexts.
2. **Vault repos are authenticated**: Access requires cryptographic identity (DID/KYC) and multi-sig approval.
3. **Lab repos are air-gapped**: Research data never leaves controlled environments; only aggregated, anonymized metrics flow upward.
4. **Orchestrator is the trust anchor**: All cross-repo syncs are mediated by `Horror.Place-Orchestrator` with hash/signature verification.

---

## Attack Vectors & Mitigations

### 1. Prompt Injection via Style Definitions
**Risk**: Malicious tokens in style specs could manipulate AI generators to produce harmful content or leak system prompts.

**Mitigations**:
- ✅ **Token sanitization**: All style artifacts scanned against blocked token list (`gore`, `blood`, etc.) via `validate_styles.ps1`.
- ✅ **Schema validation**: ALN/JSON Schema enforces structure; unknown keys ignored but logged.
- ✅ **Lua sandboxing**: `interop.rs` disables `os.execute`, `io.popen`, `loadfile` in embedded Lua VMs.
- ✅ **Routing rule validation**: Weight expressions restricted to enum values; no arbitrary code execution.

### 2. Palette Poisoning / Color-Based Attacks
**Risk**: Malicious hex codes could trigger generator vulnerabilities (e.g., buffer overflows in color parsing) or embed steganographic payloads.

**Mitigations**:
- ✅ **Hex format validation**: Strict regex `^#[0-9A-Fa-f]{6}$` enforced at schema and runtime.
- ✅ **Palette role whitelisting**: Only predefined roles (`background_base`, `highlight`, etc.) accepted.
- ✅ **Drift monitoring**: Generated palettes compared to canonical set; >5% deviation triggers alert.

### 3. Cross-Repo Consistency Attacks
**Risk**: Attacker modifies public spec but not vault reference, causing desync that could be exploited during sync.

**Mitigations**:
- ✅ **Cryptographic hashing**: All style artifacts have `.sha256` sidecar files; Orchestrator verifies before sync.
- ✅ **Signature verification**: `.sig` files (GPG/age) required for Vault→Public promotions.
- ✅ **Audit logging**: All cross-repo operations logged to Dead-Ledger with ZKP-based integrity proofs.

### 4. Metric Manipulation / Routing Subversion
**Risk**: Attacker crafts metric values to bypass safety filters or force undesirable prompt weights.

**Mitigations**:
- ✅ **Metric bounds enforcement**: All metrics clamped to [0.0, 1.0] at deserialization.
- ✅ **Routing rule conflict detection**: Positive/negative token conflicts flagged during validation.
- ✅ **Weight clamping**: Token weights restricted to [0.1, 2.0] regardless of metric value.

### 5. Privacy Leakage from Research Data
**Risk**: BCI/fMRI or physiological data from Tier 3 could be re-identified or misused.

**Mitigations**:
- ✅ **Data minimization**: Only aggregated metrics (UEC, EMD, etc.) flow to public tier; raw data never leaves Lab.
- ✅ **Differential privacy**: Research datasets include calibrated noise before aggregation.
- ✅ **Access controls**: Lab repos require multi-sig + ZKP age-gating; all accesses logged to Dead-Ledger.

---

## Responsible Disclosure

### Reporting a Vulnerability
1. **Do not disclose publicly** until coordinated fix is released.
2. Email `security@horror.place` with:
   - Affected component(s) and version(s)
   - Steps to reproduce (minimal PoC preferred)
   - Potential impact assessment
   - Suggested mitigation (optional)
3. Encrypt reports with PGP key `0xDEADBEEFCAFE` (fingerprint: `ABCD EF01 2345 6789 ABCD EF01 2345 6789 ABCD EF01`).

### Response Timeline
| Severity | Acknowledgment | Fix Timeline | Disclosure |
|----------|---------------|--------------|------------|
| Critical | ≤ 24 hours | ≤ 7 days | Coordinated after fix |
| High | ≤ 48 hours | ≤ 14 days | Coordinated after fix |
| Medium | ≤ 72 hours | ≤ 30 days | Public after fix |
| Low | ≤ 7 days | Next release | Public with release notes |

### Bug Bounty Program
- **Eligible findings**: Remote code execution, auth bypass, data exfiltration, prompt injection leading to harmful output.
- **Rewards**: $500–$5,000 USD based on severity and impact (paid in XMR for anonymity).
- **Exclusions**: DoS (unless combined with RCE), theoretical attacks without PoC, social engineering.

---

## Security Development Lifecycle

### Pre-Commit Hooks
```bash
# .githooks/pre-commit
#!/bin/bash
# Run style validation on changed files
git diff --cached --name-only | grep -E '\.(md|aln|lua|toml)$' | \
  xargs -r ./scripts/validate_styles.ps1 -Mode CI -Strict || exit 1
```

### CI/CD Security Gates
```yaml
# .github/workflows/security.yml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run style validation
        run: ./scripts/validate_styles.ps1 -Mode CI -OutputFormat JUnit
      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: validation-results
          path: test-results.xml
```

### Dependency Scanning
- **Rust crates**: `cargo-audit` run on every PR; critical vulnerabilities block merge.
- **PowerShell modules**: `Invoke-ScriptAnalyzer` with `PSAvoidUsingPlainTextForPassword` rule enforced.
- **Lua dependencies**: Only vendored, pinned versions allowed; no dynamic `require`.

---

## Incident Response Playbook

### Phase 1: Detection & Triage
1. Alert triggered via:
   - Validation pipeline failure (schema/security)
   - Orchestrator hash mismatch
   - Dead-Ledger anomaly detection
2. Triage team (`@horrorplace/security`) assesses severity within SLA.

### Phase 2: Containment
1. **Public repo**: Revert suspicious commits; tag affected versions as `vX.Y.Z-insecure`.
2. **Vault repos**: Revoke compromised credentials; rotate signing keys.
3. **Lab repos**: Isolate affected research environments; preserve forensic images.

### Phase 3: Eradication & Recovery
1. Patch vulnerability; backport to supported versions.
2. Re-validate all artifacts with updated validation rules.
3. Re-sync repos via Orchestrator with fresh signatures.

### Phase 4: Post-Mortem
1. Publish anonymized incident report within 30 days.
2. Update threat model and validation rules based on lessons learned.
3. Compensate bug bounty reporter if applicable.

---

## Cryptographic Specifications

### Key Management
- **Signing keys**: Ed25519 for artifact signatures; rotated quarterly.
- **Encryption**: XChaCha20-Poly1305 for Vault/Lab data at rest.
- **Key storage**: Hardware security modules (HSMs) for root keys; age for user keys.

### Zero-Knowledge Proofs
- **Age gating**: ZKP-based proof of age ≥ 18 without revealing DOB.
- **Access proofs**: ZKP that user holds valid DID + KYC attestation without exposing identity.

### Dead-Ledger Integration
- All cross-repo operations recorded as transactions.
- Merkle proofs enable lightweight verification of artifact integrity.
- Gossip protocol ensures eventual consistency across Orchestrator nodes.

---

## Compliance & Certifications

| Standard | Status | Scope |
|----------|--------|-------|
| ISO 27001 | 🟡 In progress | Tier 1 public infrastructure |
| SOC 2 Type II | 🔴 Planned | Vault repository access controls |
| GDPR | ✅ Compliant | No personal data in public tier; Lab data anonymized |
| NIST AI RMF | 🟡 Mapping in progress | Metric definitions, routing logic |

---

## Contact & Resources

- **Security team**: `security@horror.place`
- **PGP key**: `0xDEADBEEFCAFE` ([download](https://horror.place/security/pgp))
- **Threat model diagrams**: [`/docs/security/threat-model.pdf`](docs/security/threat-model.pdf)
- **Validation schema**: [`/docs/schemas/style_schema.aln`](docs/schemas/style_schema.aln)
- **Incident history**: [`/SECURITY-INCIDENTS.md`](SECURITY-INCIDENTS.md) (private; access via security team)

> **Note**: This policy is itself versioned and validated. Changes require security team approval and are logged to Dead-Ledger.
