# 1. CORE TEMPLATES (DNA)

> [!NOTE]
> This section contains the absolute base templates for project initialization. They are recoverable via `scripts/restore-blueprint-artifact.sh` and the portable bundle manifest.

<!-- BEGIN: DESIGN_SYSTEM.md -->
# Design System Bridge
**Status:** Scaffolded

## 1. Agent Contract
- If project root has `DESIGN.md`, read it before UI/frontend edits.
- `DESIGN.md` follows the google-labs-code/design.md format: YAML tokens plus Markdown rationale.
- Token values in `DESIGN.md` are normative; prose explains how and why to apply them.
- If `DESIGN.md` is missing, use this file to create one instead of inventing visual rules.

## 2. DESIGN.md Minimum Shape
- YAML frontmatter: `version`, `name`, `colors`, `typography`, `spacing`, `rounded`, optional `components`.
- Body sections, in order when present: Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts.
- Component tokens should reference existing tokens with `{path.to.token}` when possible.

## 3. Local Product Notes
- Brand personality: (TBD)
- Primary color / accent: (TBD)
- Typography: (TBD)
- Layout density: (TBD)
- Component library / styling strategy: (TBD)

## 4. Accessibility
- Interactive elements need visible focus states.
- Text and component color pairs should meet WCAG AA contrast.
- Run `npx @google/design.md lint DESIGN.md` when Node/network policy allows it.
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
- Version: `v9.2.3`; structured source: `state/read_contract.json`.
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
> v9.2.3 mantiene el kit distribuible autocontenido en 6 archivos.
> `minimum-kernel.bundle.tar.gz` es el sexto archivo portable oficial y vive en la raíz del kit.
> `.portable/` es cache generada localmente por `bootstrap`, `regen` o `pack`; no es canon ni warmup.
> Los launchers leen primero `minimum-kernel.bundle.tar.gz` en raíz; si falta, usan `.portable/minimum-kernel.bundle.tar.gz` como cache local.
> El bundle incluye runtime scripts, workflows, reglas, configs, estado baseline y las superficies portables de `autofix`; no incluye MCP, registries de skills locales, eval fixtures, checks, scripts evaluate ni experimentos SLM/Hyperlayer.

- Official payload: `minimum-kernel.bundle.tar.gz`
- Generated cache bundle: `.portable/minimum-kernel.bundle.tar.gz`
- Generated cache manifest: `.portable/bundle_manifest.json`
- Blueprint policy: no base64 payload is embedded in this Markdown file.

~~~~json
{
  "version": 1,
  "generated_at": "2026-05-08T20:13:19Z",
  "profile": "portable_minimum",
  "portable_root_files": [
    "GEMINI.md",
    "MEMORY.md",
    "GEMINI_BLUEPRINTS.md",
    "portable-kernel.sh",
    "portable-kernel-windows.ps1",
    "minimum-kernel.bundle.tar.gz"
  ],
  "component_contract": {
    "core": [
      "rules/",
      "config/",
      "state/",
      ".portable/"
    ],
    "memory": [
      "knowledge/"
    ],
    "runtime_scripts": [
      "scripts/"
    ],
    "advanced_workflows": [
      "workflows/",
      "skills/autofix/",
      "templates/autofix/"
    ],
    "telemetry_on_demand": [
      "logs/"
    ]
  },
  "artifact_count": 83,
  "categories": [
    {
      "category": "blueprints",
      "count": 2
    },
    {
      "category": "config",
      "count": 14
    },
    {
      "category": "knowledge",
      "count": 5
    },
    {
      "category": "logs",
      "count": 1
    },
    {
      "category": "rules",
      "count": 5
    },
    {
      "category": "scripts",
      "count": 29
    },
    {
      "category": "skills",
      "count": 2
    },
    {
      "category": "state",
      "count": 10
    },
    {
      "category": "templates",
      "count": 5
    },
    {
      "category": "workflows",
      "count": 10
    }
  ],
  "artifacts": [
    {
      "path": "blueprints/README.md",
      "category": "blueprints",
      "component": "core_runtime"
    },
    {
      "path": "blueprints/manifest.json",
      "category": "blueprints",
      "component": "core_runtime"
    },
    {
      "path": "config/approval-categories.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/approval-grant-policies.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/chat_response_profiles.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/external-capability-surfaces.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/guardrails.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/lifecycle-hooks.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/observability-contract.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/post-publish-dispatch-policies.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/post-publish-surface-playbooks.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/provider-environment-profiles.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/routing-contract.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/runtime-adapters.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/skills-curation.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "config/tool-policies.json",
      "category": "config",
      "component": "core_runtime"
    },
    {
      "path": "knowledge/.memory_maintenance.json",
      "category": "knowledge",
      "component": "memory"
    },
    {
      "path": "knowledge/advisories/README.md",
      "category": "knowledge",
      "component": "memory"
    },
    {
      "path": "knowledge/global_patterns/README.md",
      "category": "knowledge",
      "component": "memory"
    },
    {
      "path": "knowledge/global_profile/README.md",
      "category": "knowledge",
      "component": "memory"
    },
    {
      "path": "knowledge/metadata.json",
      "category": "knowledge",
      "component": "memory"
    },
    {
      "path": "logs/lightweight_audit.log",
      "category": "logs",
      "component": "telemetry_on_demand"
    },
    {
      "path": "rules/implementation-planning.md",
      "category": "rules",
      "component": "core_runtime"
    },
    {
      "path": "rules/manifest.json",
      "category": "rules",
      "component": "core_runtime"
    },
    {
      "path": "rules/memory-runtime.md",
      "category": "rules",
      "component": "core_runtime"
    },
    {
      "path": "rules/skills-arsenal.md",
      "category": "rules",
      "component": "core_runtime"
    },
    {
      "path": "rules/system-integrity.md",
      "category": "rules",
      "component": "core_runtime"
    },
    {
      "path": "scripts/audit-surface-usage.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/build-blueprint-manifest.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/build-blueprints.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/capture-ki.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/emit-antigravity-plan-event.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/emit-codex-plan-event.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/emit-memory-access-trace.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/emit-trace-event.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/ingest-plan-event.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/kernel-closeout.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/kernel-feature-enabled.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/kernelctl.py",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/logctl.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/normalize-foreign-project-context.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/planctl.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/read-targeted-context.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/render-current-state-md.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/render-project-agents-md.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/render-project-state-cache.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/render-read-contract-surfaces.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/render-read-contract.py",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/resolve-read-context.py",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/restore-blueprint-artifact.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/run-memory-maintenance.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/select-memory-context.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/statectl.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/sync-skills-registry.js",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/sync-skills-registry.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "scripts/verify-blueprint-manifest.sh",
      "category": "scripts",
      "component": "core_runtime"
    },
    {
      "path": "skills/autofix/SKILL.md",
      "category": "skills",
      "component": "advanced_workflows"
    },
    {
      "path": "skills/autofix/scripts/autofix-loop.sh",
      "category": "skills",
      "component": "advanced_workflows"
    },
    {
      "path": "state/approval-grants.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/plan-event.schema.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/post-publish-dispatch-queue.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/post-publish-dispatch-queue.schema.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/project_state.schema.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/read_contract.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/run_state.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/traces/README.md",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/traces/portable-bootstrap.jsonl",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "state/traces/trace.schema.json",
      "category": "state",
      "component": "core_runtime"
    },
    {
      "path": "templates/autofix/eval.sh",
      "category": "templates",
      "component": "advanced_workflows"
    },
    {
      "path": "templates/autofix/program.md",
      "category": "templates",
      "component": "advanced_workflows"
    },
    {
      "path": "templates/autofix/result.json",
      "category": "templates",
      "component": "advanced_workflows"
    },
    {
      "path": "templates/autofix/spec.json",
      "category": "templates",
      "component": "advanced_workflows"
    },
    {
      "path": "templates/autofix/state.json",
      "category": "templates",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/auto-pilot-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/autofix-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/bug-fix-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/dependency-safety-baseline-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/feature-development-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/project-init-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/quality-assurance-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/skills-lifecycle-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/system-health-check-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    },
    {
      "path": "workflows/web-safety-workflow.md",
      "category": "workflows",
      "component": "advanced_workflows"
    }
  ]
}
~~~~

