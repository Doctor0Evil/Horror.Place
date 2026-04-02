# Contributing to Horror.Place Public Core

Welcome! We appreciate your interest in contributing to the Horror.Place public
core infrastructure. This document explains how to get involved, what we expect,
and how the process works.

---

## Code of Conduct

All contributors must follow our [Code of Conduct](CODE_OF_CONDUCT.md). Please
read it before participating.

---

## How to Report Issues

Use **GitHub Issues** to report bugs, suggest improvements, or flag concerns.

When filing an issue, include:

- **Title:** concise summary of the problem or suggestion.
- **Description:** detailed explanation with context.
- **Reproduction steps:** numbered steps to reproduce the issue (if applicable).
- **Expected vs. actual behavior.**
- **Environment:** OS, Python version, relevant tool versions.
- **Labels:** apply appropriate labels (bug, enhancement, docs, schema, audit).

---

## Development Setup

### Prerequisites

| Tool        | Version  | Purpose                          |
| ----------- | -------- | -------------------------------- |
| Python      | 3.11+    | Schema validation, linting, tests |
| luacheck    | 1.1+     | Lua linting for public-api/ stubs |
| ruff        | 0.4+     | Python linting (primary)          |
| flake8      | 7.0+     | Python linting (secondary)        |
| jsonschema  | 4.21+    | JSON Schema validation library    |

### Setup

```bash
# Clone the repository
git clone https://github.com/HorrorPlace/horror-place-core.git
cd horror-place-core

# Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify setup
python scripts/validate_schemas.py --registry-dir core/registry/ --schema-dir core/schemas/
luacheck public-api/
```

---

## Branch Naming

All branches must follow this naming convention:

| Prefix       | Use Case                                      |
| ------------ | --------------------------------------------- |
| `feat/`      | New feature or schema addition                 |
| `fix/`       | Bug fix                                        |
| `docs/`      | Documentation-only changes                     |
| `audit/`     | Audit plan, playbook, or acceptance test updates |
| `registry/`  | Registry entry additions or modifications       |

Examples:
- `feat/add-stylecontract-v2-schema`
- `fix/registry-linter-unicode-handling`
- `docs/update-contributing-guide`
- `audit/add-telemetry-sanitization-rules`
- `registry/add-event-carnival-of-shadows`

---

## Pull Request Process

1. **Branch from `main`.** Always start from an up-to-date main branch.

2. **Implement your change.** Follow the style guidelines and constraints below.

3. **Run CI locally.** Before pushing, verify all checks pass:
   ```bash
   python scripts/validate_schemas.py --registry-dir core/registry/ --schema-dir core/schemas/
   python scripts/registry_linter.py core/registry/
   python scripts/api_leak_test.py --scan-dirs core/ public-api/ docs/
   luacheck public-api/
   ruff check .
   ```

4. **Push and open a PR.** Use the PR description template (below).

5. **CI runs.** All CircleCI jobs must pass.

6. **Review.**
   - **Tier 1 changes** (schemas, API spec, audit plans): **2 reviewer approvals**.
   - **Docs-only changes**: **1 reviewer approval**.

7. **Merge.** Squash-merge to main after approval.

---

## Required Checks

All of the following must pass before merge:

- `schema-validation` — all registry entries validate against declared schemas.
- `registry-linter` — NDJSON format, required fields, canonical URI format.
- `api-leak-test` — no raw content, asset URLs, or base64 in public files.
- `lua-lint` — luacheck passes on all .lua files.
- `ruff` / `flake8` — Python style compliance.

---

## Schema Changes

Any change to existing schemas or introduction of new schemas **requires**:

- An accompanying ADR in `docs/ADR/` (see ADR-0001 for the template).
- A version bump for breaking changes (new file, e.g., `invariants_v2.json`).
- 2-reviewer approval.
- A migration plan if the change affects existing registry entries.

---

## Registry Updates

All registry updates **must** follow the process in
[audit/registry-update-playbook.md](../audit/registry-update-playbook.md).

Key rules:
- Maximum **10 entries per PR**.
- Each entry validated independently.
- Conventional commit message required.

---

## No Raw Content Policy

This is a **zero-raw-content** repository. Registries and public files must
**never** contain:

- Direct asset URLs (e.g., `https://cdn.example.com/image.png`).
- Base64-encoded data.
- Inline content (text blobs, media, binary).
- File paths to private vault content.

Registries contain **only opaque references**: artifact IDs, content identifiers
(CIDs), and metadata. The `api-leak-test` CI job enforces this policy.

---

## Linting

| Language | Tool          | Config File        |
| -------- | ------------- | ------------------ |
| Python   | ruff (primary)| `pyproject.toml`   |
| Python   | flake8        | `.flake8`          |
| Lua      | luacheck      | `.luacheckrc`      |

---

## Coverage

- Minimum **70% code coverage** for new Python code.
- Coverage reports generated by `pytest --cov` and uploaded to CI artifacts.

---

## Commit Messages

Use **Conventional Commits** format:

```
<type>: <short description>

[optional body]

[optional footer(s)]
```

Allowed types:

| Type     | Use Case                              |
| -------- | ------------------------------------- |
| `feat`   | New feature or schema                  |
| `fix`    | Bug fix                                |
| `docs`   | Documentation change                   |
| `audit`  | Audit artifact change                  |
| `chore`  | Maintenance, CI config, dependencies   |

Examples:
- `feat: add entertainment_metrics_v1 schema`
- `fix: correct registry linter NDJSON parsing`
- `docs: update contributing guide with coverage requirements`
- `audit: add telemetry sanitization rules to api-audit-plan`

---

## PR Description Template

When opening a PR, use this template:

```markdown
## Summary

[Concise description of what this PR does and why.]

## Changed Files

- `path/to/file1` — [what changed]
- `path/to/file2` — [what changed]

## Acceptance Tests

- [ ] AT-001: Schema Validation passes
- [ ] AT-002: Registry Linter passes
- [ ] AT-003: API Leak Test passes
- [ ] AT-005: Canonical URI Check passes (if registry change)
- [ ] AT-006: Single-Line Format passes (if registry change)
- [ ] AT-007: Lua Lint passes (if Lua change)

## Reviewer Checklist

- [ ] Change follows schema-first principles (ADR-0001)
- [ ] No raw content introduced
- [ ] Commit messages follow Conventional Commits
- [ ] Branch name follows naming convention
- [ ] ADR included (if schema change)
- [ ] Registry update playbook followed (if registry change)
```
