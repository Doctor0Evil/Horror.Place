# Registry Update Playbook

## Purpose

This playbook defines the standardized process for adding, modifying, or
removing entries in Horror.Place registry files (`core/registry/*.ndjson`).
All contributors must follow this process to ensure consistency, auditability,
and compliance with the zero-raw-content policy.

---

## Prerequisites

Before starting a registry update, ensure:

- [ ] You have clone access to the `horror-place-core` repository.
- [ ] You understand the relevant schema(s) in `core/schemas/`.
- [ ] CI is passing on the `main` branch (check CircleCI dashboard).
- [ ] You have read and understood:
  - [ADR-0001: Schema-First Design](../docs/ADR/0001-schema-first.md)
  - [Contributing Guide](../docs/CONTRIBUTING.md)
  - [API Audit Plan](api-audit-plan.md)

---

## Steps

### Step 1: Create a Branch

Create a new branch from `main` using the registry naming convention:

```bash
git checkout main
git pull origin main
git checkout -b registry/add-{type}-{id}
```

Replace `{type}` with the registry type (`event`, `region`, `style`, `persona`)
and `{id}` with a short identifier for the entry.

Examples:
- `registry/add-event-carnival-of-shadows`
- `registry/add-region-abyssal-corridor`
- `registry/modify-style-neo-gothic`
- `registry/remove-persona-deprecated-watcher`

### Step 2: Add or Modify the Registry Entry

Add your entry as a **single line of valid JSON** to the appropriate registry
file in `core/registry/`.

Each entry must include at minimum:

```json
{"id":"unique-entry-id","schema_ref":"schema://Horror.Place/core/schemas/{schema_name}","metadata":{},"artifact_id":"opaque-artifact-identifier"}
```

Or with a `cid` instead of `artifact_id`:

```json
{"id":"unique-entry-id","schema_ref":"schema://Horror.Place/core/schemas/{schema_name}","metadata":{},"cid":"opaque-content-identifier"}
```

**Critical:** The entry must be a single line. No pretty-printing. No trailing
commas. No comments.

### Step 3: Validate Against Schema Locally

```bash
python scripts/validate_schemas.py \
  --registry-dir core/registry/ \
  --schema-dir core/schemas/
```

Fix any validation errors before proceeding.

### Step 4: Verify All References Are Opaque

Manually inspect your entry to confirm:

- [ ] No direct asset URLs (no `https://`, `http://`, `s3://`, `gs://`).
- [ ] No base64-encoded data.
- [ ] No inline content (no text blobs, no media data).
- [ ] `artifact_id` or `cid` is an opaque identifier only.
- [ ] `metadata` contains only non-sensitive, non-content fields.

### Step 5: Run Registry Linter Locally

```bash
python scripts/registry_linter.py core/registry/
```

Verify:
- NDJSON format compliance (one JSON object per line).
- Required fields present (`id`, `schema_ref`, `metadata`, `artifact_id`/`cid`).
- Canonical URI format for `schema_ref`.
- No duplicate `id` values.

### Step 6: Run API Leak Test Locally

```bash
python scripts/api_leak_test.py --scan-dirs core/ public-api/ docs/
```

Verify zero matches for raw content patterns.

### Step 7: Commit with Conventional Message

```bash
git add core/registry/{file}.ndjson
git commit -m "registry: add {type} entry {id}

Added {description} to {registry_file}.
Schema: schema://Horror.Place/core/schemas/{schema_name}
Artifact-ID: {artifact_id}"
```

### Step 8: Push and Open PR

```bash
git push origin registry/add-{type}-{id}
```

Open a PR on GitHub using the
[PR description template](../docs/CONTRIBUTING.md#pr-description-template).

### Step 9: CI Runs

The following CI jobs will execute automatically:

1. `schema-validation` — validates your entry against its declared schema.
2. `registry-linter` — checks NDJSON format, required fields, URI format.
3. `api-leak-test` — scans for raw content and asset URL leaks.

All three must pass. If any fail, fix the issues and push again.

### Step 10: Two Reviewers Approve

Registry updates are **Tier 1 changes** and require **2 reviewer approvals**.
Reviewers will check:

- [ ] Entry validates against schema.
- [ ] No raw content introduced.
- [ ] Opaque references only.
- [ ] Conventional commit message.
- [ ] Branch name follows convention.

### Step 11: Merge to Main

After 2 approvals and all CI jobs passing, **squash-merge** the PR to main.

---

## Post-Merge

After the PR is merged to `main`:

1. **Orchestrator polls for changes.** The `Horror.Place-Orchestrator` service
   polls the public core repository and detects changes within **5 minutes**.

2. **Downstream registries updated.** The orchestrator propagates new entries
   to downstream consumers and private vault index services.

3. **Audit log entry produced.** The orchestrator creates an audit log entry
   documenting the registry change, timestamp, commit SHA, and author.

---

## Rollback Procedure

If a registry entry must be rolled back after merge:

1. **Revert the commit on `main`:**
   ```bash
   git revert {commit-sha}
   git push origin main
   ```

2. **Orchestrator detects the revert** and rolls back downstream registries
   within 5 minutes.

3. **Post-hoc review required.** A follow-up review must be conducted to
   determine root cause and prevent recurrence. Document findings in a
   GitHub Issue.

---

## Emergency Procedure

For critical issues requiring immediate registry changes:

1. **Direct commit to `main`** with explicit **audit lead approval** (written
   confirmation via project communication channel).

2. **Post-hoc PR** opened immediately after the direct commit for review and
   documentation purposes.

3. **Incident report** filed within **24 hours** documenting:
   - What was changed and why.
   - Who approved the emergency change.
   - Root cause analysis.
   - Preventive measures.

---

## Bulk Updates

For multiple registry entries in a single PR:

- **Maximum 10 entries per PR.** If more than 10 entries need to be added,
  split into multiple PRs.
- **Each entry validated independently.** A single invalid entry fails the
  entire PR.
- **Commit message references all entries** or uses a summary description.
- **Reviewers must inspect each entry individually.**
