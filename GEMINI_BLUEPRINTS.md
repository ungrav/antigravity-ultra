# 1. CORE TEMPLATES (DNA)

> [!NOTE]
> This section contains the absolute base templates for project initialization. They are recoverable via `scripts/restore-blueprint-artifact.sh` and the portable bundle manifest.

<!-- BEGIN: DESIGN_SYSTEM.md -->
# Project Design Memory
**Status:** Scaffolded

## 1. Agent Contract
- `DESIGN_SYSTEM.md` is the project design memory: screenshots, references, visual decisions, component intent, UX notes, and product-specific style rules.
- If project root has `DESIGN.md`, read it as a compatible agent-readable design standard; it does not replace this file.
- Precedence: current user request/captures > existing product UI > `DESIGN_SYSTEM.md` > `DESIGN.md` > model taste.
- Keep durable summaries and useful asset paths here; do not paste raw transcripts, private assets, or unrelated inspiration dumps.

## 2. Capture & References
- Screenshot/reference path: (TBD)
- What to preserve: (TBD)
- What to change: (TBD)
- Important interaction/state notes: (TBD)

## 3. Product Design Notes
- Brand personality: (TBD)
- Primary color / accent: (TBD)
- Typography: (TBD)
- Layout density: (TBD)
- Component library / styling strategy: (TBD)

## 4. Optional DESIGN.md Compatibility
- `DESIGN.md` may follow the google-labs-code/design.md convention: Markdown design guidance with structured tokens/rationale.
- When both files exist, use `DESIGN.md` for portable visual language and this file for local project memory, screenshots, and decisions.
- Run `npx @google/design.md lint DESIGN.md` when Node/network policy allows it.

## 5. Accessibility
- Interactive elements need visible focus states.
- Text and component color pairs should meet WCAG AA contrast.
<!-- END: DESIGN_SYSTEM.md -->

<!-- BEGIN: PROJECT_HISTORY.md -->
# Project History & Architecture Log
**Intent:** Track major decisions, architectural shifts, and system state.

## Abstract
(Write a 2-line summary of the project's current state and main goal here)

## Milestones & Decisions
- Project Initialized via Agentic Framework.
<!-- END: PROJECT_HISTORY.md -->

<!-- BEGIN: ERROR_LOG.md -->
# Error & Resolution Log
**Intent:** Track failures, root causes, and applied fixes to prevent regressions.

## Active Issues
- (None currently)

## Resolved Incidents
*(Use this structure: Problem -> Root Cause -> Fix)*
- Initial setup completed safely.
<!-- END: ERROR_LOG.md -->

> [!IMPORTANT]
> `implementation_plan.md` dejó de ser un template recuperable de proyecto.
> El plan completo vive dentro del host/sesión que lo produce, y el repo solo conserva `plan_state` + memoria durable.

<!-- BEGIN: AGENTS.md -->
# AGENTS.md

> Stable onboarding for external agents. The generated block is maintained by `scripts/render-project-agents-md.sh`.

<!-- AGENTS_HUMAN_START -->
## Hot Path Override
- External warmup is `AGENTS.md` + `.agent/current_state.md`; inspect canon, ledgers, or KIs only when the task needs them. KI folders are layout; frontmatter carries meaning.
<!-- AGENTS_HUMAN_END -->

<!-- AGENTS_GENERATED_START -->
## Project Summary
- Project: <project-name>
- Canon: GEMINI.md; live handoff: .agent/current_state.md; structured state: .agent/current_state.json.

## How To Start
- Read AGENTS.md, then .agent/current_state.md; inspect target files after task classification.
- Run bash scripts/gemini-doctor.sh --runtime after live-state or kernel-surface edits.
- Run bash scripts/run-core-evals.sh only for broad kernel validation.

## Golden Path
- Version: `v9.2.5`; structured source: `state/read_contract.json`.
- Start here: `AGENTS.md` -> `.agent/current_state.md`.
- Optional helper: `scripts/resolve-read-context.py --profile external --task "<task>" --json`; if it fails, use the table and report `resolver unavailable`.

## Manual Reading Table
1. Normal/local: target files only.
2. Bug ambiguous: target files + latest `ERROR_LOG.md` rows.
3. Architecture/refactor: latest `PROJECT_HISTORY.md` + Project DNA if useful.
4. Memory/kernel: `MEMORY.md` + targeted KIs.
5. Restore/portable: `GEMINI_BLUEPRINTS.md` + launchers.

## Local Canon
- `GEMINI.md` is local canon, but not normal external warmup; if files disagree, follow `GEMINI.md`.
- No shared exports; read `GEMINI.md` surgically only when needed.

## Memory
- Normal tasks use no vault. For "what did we decide", "why did we do X", prior errors, or architecture, read Project DNA then run `scripts/select-memory-context.sh --root . --query "<task>" --limit 5`.
- Verify KI claims against repo/runtime before recommending current files, scripts, flags, or decisions.

## Memory Capture
- Closeout triggers include "cerrar sesión", "closeout", "wrap up", "handoff", and "continuar luego".
- Closeout command: `scripts/kernel-closeout.sh --root . --close-session --session-summary "<summary>" --next-step "<next>" --verify runtime`; add `--memory-summary` only for durable memory.
<!-- AGENTS_GENERATED_END -->
<!-- END: AGENTS.md -->

## 2. PORTABLE RECOVERY MANIFEST

> [!NOTE]
> Esta seccion ya no pega workflows completos como Markdown humano.
> El kit portable visible conserva exactamente 6 archivos raíz: `GEMINI.md`, `MEMORY.md`, `GEMINI_BLUEPRINTS.md`, `portable-kernel.sh`, `portable-kernel-windows.ps1` y `minimum-kernel.bundle.tar.gz`.
> Los tres primeros son canon semantico/documental; los dos launchers son entrypoints de plataforma; el sexto archivo es el payload portable oficial.
> `.portable/` se genera localmente como cache/recovery; no se distribuye como carpeta y no es parte del warmup.
> Los artefactos se restauran desde `minimum-kernel.bundle.tar.gz` o desde la cache local `.portable/`.
> `autofix` es el unico nombre canonico y restaurable para el loop eval-driven.

### 2.1 Artifact Summary

| Kind | Count |
|------|-------|
| `skill` | 2 |
| `template` | 9 |
| `workflow` | 10 |

### 2.2 Restore Contract

- El primer mensaje en Antigravity ejecuta `probe`, guia idioma/perfil, llama al launcher de plataforma y luego corre `doctor`.
- `portable-kernel.sh bootstrap` y `portable-kernel-windows.ps1 bootstrap` expanden el bundle completo sin prompts interactivos cuando el agente ya recopilo preferencias.
- `portable-kernel.sh recover workflow:<name>` restores from marker blocks when present, otherwise from the portable bundle.
- Core templates remain visible in section 1 for direct restore.
- User-facing routes and restore ids must use `autofix` only.

### 2.3 Portable Minimum Bundle

> [!NOTE]
> v9.2.5 mantiene el kit distribuible autocontenido en 6 archivos.
> `minimum-kernel.bundle.tar.gz` es el sexto archivo portable oficial y vive en la raíz del kit.
> `.portable/` es cache generada localmente por `bootstrap`, `regen` o `pack`; no es canon ni warmup.
> Los launchers leen primero `minimum-kernel.bundle.tar.gz` en raíz; si falta, usan `.portable/minimum-kernel.bundle.tar.gz` como cache local.
> El bundle incluye runtime scripts, workflows, reglas, configs, estado baseline y las superficies portables de `autofix`; no incluye MCP, registries de skills locales, eval fixtures, checks, scripts evaluate ni experimentos SLM/Hyperlayer.

- Official payload: `minimum-kernel.bundle.tar.gz`
- Generated cache bundle: `.portable/minimum-kernel.bundle.tar.gz`
- Generated cache manifest: `.portable/bundle_manifest.json`
- Detailed machine manifest: generated in `.portable/bundle_manifest.json` and inside `minimum-kernel.bundle.tar.gz`; this Markdown intentionally does not embed it.
- Blueprint policy: no base64 payload is embedded in this Markdown file.

