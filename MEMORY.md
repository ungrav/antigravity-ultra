# MEMORY TECHNICAL SPEC: v9.0 - STRUCTURED MARKDOWN MEMORY
*Last updated: 2026-04-30*

## Purpose
Memory exists to preserve durable project knowledge without making normal agents study the kernel. The active model is simple:

- Markdown Knowledge Items (KIs) with frontmatter.
- `.agent/knowledge/.project_dna.md` as a compact project digest.
- `PROJECT_HISTORY.md` for durable changes.
- `ERROR_LOG.md` for incidents and fixes.
- Targeted selection by task keywords, `tenant_domain`, entities, status, and recency.

No derived scoring system is part of the active contract. Agents and scripts must not require generated ranking artifacts or calculated memory scores.

## Runtime Contract
- Normal tasks do not read the vault.
- Architecture, incident, memory, and recovery tasks may read memory through the Golden Path in `GEMINI.md` and `rules/memory-runtime.md`.
- `MEMORY.md` is loaded only for memory/kernel changes or audits.
- The selector should return a small set of paths plus a plain reason.
- If selector tooling is unavailable, use targeted grep over active Markdown notes.
- Memory scripts are helpers for consistency and verification, not a required detour for obvious native Markdown edits.

## KI Shape
KIs are Markdown files under `.agent/knowledge/`:

- `architecture/`: decisions, patterns, API/config/schema notes.
- `incidents/`: bug resolutions, test insights, debug dead ends.
- `ecosystem/`: dependencies, tools, providers, environment notes.
- `research/`: research conclusions and external findings.
- `context/`: durable handoffs that outlive the live state.

Folders are storage layout. Meaning comes from frontmatter.

Recommended frontmatter:

```yaml
---
ki_id: "stable-id"
category: "architecture"
kind: "decision"
status: "active"
timestamp: 1775200000
tenant_domain: "kernel"
entities: ["resolver", "memory"]
related_kis: []
---
```

Required behavior:

- `status: active` is the normal selectable state.
- `status: superseded` or `archived` stays out of normal retrieval unless explicitly requested.
- `tenant_domain`, `entities`, and `kind` guide targeted selection.

## Selection
Selection should be boring and inspectable:

- Start from `.project_dna.md` for memory-heavy work.
- Prefer notes matching the task's `tenant_domain`, entities, and keywords.
- Prefer `status: active`.
- Break ties with recency and direct entity match.
- Return at most 5 notes or about 1200 tokens.
- Revalidate repo/runtime facts before treating a note as current truth.

## Capture
Use native Markdown when the durable lesson is already clear. Use `scripts/capture-ki.sh` for standard/deep closeout when state-derived suggestions are useful.

Normal closeout:

```bash
scripts/capture-ki.sh --suggest-from-current-state --json
```

Write only when the suggestion is durable:

```bash
scripts/capture-ki.sh --suggest-from-current-state --json --write
```

Native KI edits are acceptable for explicit memory/kernel work when the durable lesson is clear, frontmatter is valid, and the note follows the exclusion rules below.

Capture only durable decisions, reusable patterns, verified bug fixes, API/config/schema contracts, important research, or handoff-worthy constraints.

Do not capture:

- secrets or credentials
- raw transcripts
- copied source code
- hidden reasoning
- raw tool dumps
- ordinary task chatter
- pure typo/docs/format changes
- PR lists, recent activity recaps, `git status` snapshots, file inventories, and worklogs

Explicit "save this" or "remember this" requests do NOT override exclusion rules. Capture only a surprising, non-obvious, reusable lesson.

## Project DNA
`.agent/knowledge/.project_dna.md` is a compact digest for agents.

Limits:

- max 50 lines
- max 8 KI references
- concise stack/domain summary
- active risks or durable constraints only

It is regenerated from active notes when memory maintenance is explicitly requested. It is not a transcript and does not replace live state.

## Live State Boundary
- `.agent/current_state.json` is the structured source used by renderers.
- `.agent/current_state.md` is the operational view agents read first.
- `.agent/project_state.json` is generated cache.
- If these views disagree, treat live state as stale, revalidate repo/runtime facts, update the structured state, and rerender the Markdown/cache views.
- `context_state` KIs are durable handoff summaries only; they do not replace live state.

## Implementation Plan Persistence Boundary
- Plan bodies stay in the host/session.
- Disk stores only normalized `plan_state` fields in `.agent/current_state.json` and generated cache views.
- `producer_agent`, `approval_source`, `next_action`, and `receipt_ref` are receipt metadata, not the plan body.

## Global Memory Layer
Global memory is optional and conservative:

- `knowledge/global_patterns/`: reusable durable patterns.
- `knowledge/advisories/`: time-bound warnings.
- `knowledge/global_profile/`: durable user/operator preferences.
- `knowledge/metadata.json`: describes the global memory directories.

Project bootstrap may import relevant global patterns into the local vault. It must not blindly copy advisories or global profile notes.

## Global Promotion & Demotion Contract
Promote local knowledge globally only when it is reusable beyond one project:

- at least two projects confirm it, or
- one project confirms it with strong durable evidence and no contradiction.

Demote or expire global knowledge when it becomes project-specific, contradicted, obsolete, or time-bound and expired.

## Maintenance
`scripts/run-memory-maintenance.sh` and `workflows/memory-delta-archiver-workflow.md` are explicit tools, not normal warmup. Their active responsibilities are simple:

- mark exact duplicates or superseded notes
- promote valid inbox drafts if that workflow is explicitly used
- archive invalid drafts
- regenerate `.project_dna.md`
- consolidate when active KI count exceeds 15 for this personal kernel profile; use 30 only when operating it as a product/framework with CI coverage

Maintenance must not create generated ranking artifacts.

`inbox/` is legacy experimental-only staging. Bootstrap does not create `inbox/` during normal flow.

## Portability
Portable bundles carry the root docs, restore bundle, launchers, simple global memory readmes, and core runtime scripts. They do not carry local user credentials, MCP config, tests/evals, dynamic skill registries, or generated memory state.
