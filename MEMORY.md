# MEMORY TECHNICAL SPEC: v9.2.5 - STRUCTURED MARKDOWN MEMORY
*Last updated: 2026-05-13*

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
- Repo/runtime facts outrank KIs, chat context, and model heuristics.
- Keep this file under 180 lines and 8,500 bytes; consolidate before expanding.

## How To Audit This Kernel
Use this section only for kernel audits, critiques, architecture changes, or portability work. It is not normal warmup.

- External agents start with `AGENTS.md` -> `.agent/current_state.md`; native Antigravity starts with `GEMINI.md` -> `rules/memory-runtime.md` -> `.agent/current_state.md`.
- `GEMINI.md` is the runtime canon, not a history document. If it conflicts with projections, generated views, chat, or memory, follow current repo/runtime facts and `GEMINI.md`.
- `AGENTS.md` is generated onboarding for external agents, not a second source of truth. Its job is interoperability.
- `.agent/current_state.md` is the live handoff. It does not replace canon, memory, ledgers, or KIs.
- `MEMORY.md` defines the memory contract. The memory itself is small Markdown KIs with frontmatter; folders are layout, frontmatter carries meaning.
- `scripts/`, `evals/`, `rules/`, registries, caches, and trash are local runtime surfaces. Do not judge portable complexity by raw directory size without separating active contract, generated cache, deprecated trash, and ignored local tooling.
- Official portability for other users is the root kit plus bundle, not copying the entire `.gemini` directory.

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
- Authority hierarchy: current repo/runtime facts > KIs > chat context > model heuristics.

## Before Recommending from Memory
A KI is a dated claim. If it names a file, function, script, flag, config, or current decision, verify the claim before recommending action.

- File path claims: check the path exists or report it as historical.
- Function/script/flag claims: search the repo/runtime before treating them as live.
- Decision claims: if repo/runtime contradicts the KI, trust observed reality and update or retire the stale KI when the task scope includes memory.
- Phrase uncertain memory as historical: "The KI says..." until verified.

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

- secrets, credentials, tokens, personal data, hidden reasoning, or raw tool dumps
- raw transcripts, raw logs, stack traces without a durable fix, copied source code, or full plans
- worklogs, `git status` snapshots, file inventories, PR lists, recent-activity recaps, or session transcripts
- ordinary task chatter, unverified guesses, preferences without project impact, typo-only edits, formatting, or rename-only changes
- patterns derivable from the current repo, recipes already reflected in code/scripts, git history, or content already documented in canon

Explicit "save this" or "remember this" requests do NOT override exclusion rules. Capture only a surprising, non-obvious, reusable lesson.

## Project DNA
`.agent/knowledge/.project_dna.md` is a compact digest for agents.

Limits:

- max 50 lines
- max 8 KI references
- concise stack/domain summary
- active risks or durable constraints only

It is regenerated from active notes when memory maintenance is explicitly requested. It is not a transcript and does not replace live state.

## State and Plan Boundaries
- `.agent/current_state.json` is the structured source, `.agent/current_state.md` is the operational view, and `.agent/project_state.json` is generated cache.
- If live-state views disagree, revalidate repo/runtime facts, update the structured state, and rerender generated views.
- `context_state` KIs are durable handoff summaries only; they do not replace live state.
- Implementation Plan Persistence Boundary: full plan bodies stay in the host/session. Disk stores only normalized `plan_state` receipts such as `producer_agent`, `approval_source`, `next_action`, and `receipt_ref`.

## Global Memory Layer
Global memory is optional and conservative. `knowledge/global_patterns/` stores reusable patterns, `knowledge/advisories/` stores time-bound warnings, `knowledge/global_profile/` stores durable operator preferences, and `knowledge/metadata.json` describes those directories.

Project bootstrap may import relevant global patterns into the local vault, but must not blindly copy advisories or profile notes. Global Promotion & Demotion Contract: promote local knowledge globally only when it is reusable beyond one project, confirmed by at least two projects or by one project with strong durable evidence and no contradiction. Demote or expire global knowledge when it becomes project-specific, contradicted, obsolete, or time-bound and expired.

## Maintenance
`scripts/run-memory-maintenance.sh` and memory maintenance smokes are explicit tools, not normal warmup. Their active responsibilities are simple:

- mark exact duplicates or superseded notes
- promote valid inbox drafts if that workflow is explicitly used
- archive invalid drafts
- regenerate `.project_dna.md`
- consolidate when active KI count exceeds 15 for this personal kernel profile; use 30 only when operating it as a product/framework with CI coverage

Use `evals/checks/check-memory-maintenance-eligibility.sh` before broad maintenance to verify the vault actually qualifies.

For this personal profile, a vault at or below 15 active KIs should usually be maintained by direct Markdown review. Do not run maintenance tooling just to satisfy ceremony.

Maintenance must not create generated ranking artifacts.

`inbox/` is legacy experimental-only staging. Bootstrap does not create `inbox/` during normal flow.

## Portability
Portable bundles carry the root docs, restore bundle, launchers, simple global memory readmes, and core runtime scripts. They do not carry local user credentials, MCP config, tests/evals, dynamic skill registries, or generated memory state.
