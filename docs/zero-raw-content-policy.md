# Horror.Place Zero‑Raw‑Content Policy

This repository is the public, schema‑first core of Horror.Place. It defines contracts, not content. No raw horror content, media, or personal data may ever live here. This policy summarizes the non‑negotiable rules all contributors must follow.

---

## 1. What “zero raw content” means

For this repository, **raw content** includes:

- Narrative text that directly describes scenes, characters, dialogue, or events.
- Any media payloads: images, audio, video, 3D models, or their encoded forms.
- Direct links to assets hosted elsewhere (CDNs, S3 buckets, etc.).
- Embedded binary or base64 blobs, even if they are “just placeholders”.

Horror.Place must contain only:

- Schemas, registries, API specs, and code stubs.
- Opaque identifiers that point to content handled in private vaults.
- Documentation about process, architecture, invariants, and metrics.

---

## 2. Allowed vs. forbidden data

### Allowed

- Short, non‑descriptive labels and IDs:
  - `id`, `artifactid`, `cid`, `schemaref`.
  - Brief metadata like `status: "draft"` or `tags: ["persona","watcher"]`.
- JSON Schemas, NDJSON registry entries, and API definitions.
- Audit plans, acceptance tests, and contributing guidelines.
- Lua and Python code that operates on opaque references and contracts.

### Forbidden

- Any inline story, lore, or descriptive horror text (even “for testing”).
- Any direct URLs to media or content:
  - e.g., `https://...png`, `s3://...wav`, `gs://...mp4`.
- Any base64 or hex‑encoded payloads that could represent media or large text.
- Any reproduction of copyrighted or explicit material, in whole or in part.

If you are unsure whether something counts as raw content, assume it is not allowed and raise a question in an issue or review comment before committing.

---

## 3. Registries and schemas

Registries in this repo are indexes, not storage:

- Each registry entry is a single‑line JSON object (NDJSON).
- Entries must use only opaque references:
  - `artifactid` and `cid` must be meaningless outside internal systems.
- Metadata fields must not contain:
  - Descriptions of scenes or characters.
  - Dialogue, transcripts, or narrative summaries.
  - Embedded media or links to media.

Schemas must describe structure and constraints only. They may include:

- Field names, types, enums, ranges, and validation rules.
- Abstract descriptions of what a field represents.
- No embedded examples that include horror content or media.

---

## 4. Contributor checklist

Before opening a PR, confirm:

- [ ] No new files contain narrative, dialogue, or scene descriptions.
- [ ] No direct asset URLs, base64 blobs, or binary encodings appear in any file.
- [ ] Registry changes add or update only opaque IDs, schema references, and safe metadata.
- [ ] Documentation changes describe process, architecture, invariants, or metrics—not specific horror content.
- [ ] All local leak/scan scripts and CI checks related to content have been run and pass.

If any part of your change needs real content for testing, move that work into a private vault repository and keep only the contract surface (schema, ID, or reference) in Horror.Place.

---

## 5. Enforcement and escalation

Maintainers are required to:

- Block or revert any change that violates this policy.
- Ask for clarification whenever a field or value could be interpreted as content.
- Prefer minimal, abstract, and contract‑focused representations for all public artifacts.

If you notice a possible violation:

1. Open an issue describing the file and line(s) of concern.
2. Mark it with an appropriate label (for example, “content‑leak”).
3. Propose either removing the content or replacing it with an opaque reference.

This policy is not optional. It protects contributors, users, and the broader VM‑constellation by ensuring that Horror.Place remains a safe, auditable rules core rather than a content repository.
