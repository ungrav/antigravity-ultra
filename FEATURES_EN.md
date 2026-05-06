# Antigravity Ultra: Features & Capabilities 🚀

## 🧠 Persistent & Structured Memory

Never lose your project's context again. Memory is organized into small, focused **Knowledge Items (KIs)** — Markdown files with structured YAML frontmatter.

- **Project DNA:** A compact digest of your project's core context, active risks, and key references. Capped at 50 lines to stay lean.
- **Golden Path Routing:** Agents don't load the entire memory vault. They follow a strict routing table — normal tasks read only target files, bugs check `ERROR_LOG.md`, architecture work reads `PROJECT_HISTORY.md`. This saves thousands of tokens per conversation.
- **Selective Loading:** At most 5 KIs (~1200 tokens) are loaded per task. The selector matches by `tenant_domain`, `entities`, and task keywords.

## 📐 Ultra-Modular Architecture (Zero Monoliths)

Multiple kernel rules work together to prevent monolithic code:

- **"Edit minimally, verify with evidence"** (`GEMINI.md` §2 Golden Path) — agents touch only target files.
- **"Patch the needed surface only"** (`GEMINI.md` §4 Safety) — no overwriting unrelated code.
- **"Build incrementally"** + **"smallest safe textual patch"** (`feature-development-workflow.md`) — changes are granular.
- **"Giant undifferentiated phases that bundle unrelated work" are prohibited** (`implementation-planning.md`) — scope is bounded to 2-3 file clusters.

Benefits:

1. **Scalable code** — Changes touch small surfaces, not 10,000-line files.
2. **Precise edits** — Agents modify specific components without overwriting unrelated code.
3. **Lower token cost** — Smaller files mean less context to load, fewer hallucinations.

## 🔧 Autofix Skill (Eval-Driven Loop)

An on-demand debugging assistant, not autonomous magic. **You invoke it, you control it.**

1. You identify a bug and point the agent to it.
2. The agent reads the error from `ERROR_LOG.md`.
3. It diagnoses, implements a fix, and verifies the result.
4. If the fix fails verification, it iterates until resolved.

This is a structured loop, not a "fire and forget" AI feature.

## 🕵️ Adversarial Verification & Zero Assumptions

Two disciplines baked into the kernel:

- **Misconception Detection:** Before executing, the agent checks if the user's premise is actually correct. If not, it corrects the false assumption before writing code.
- **Evidence-Based Verification:** For complex changes, the agent cannot self-certify. It must run tests or produce real evidence that the change works. Reports use `PASS`, `FAIL`, or `PARTIAL` — never unverified claims.

## 📚 Permanent History (Project Ledgers)

Two immutable ledgers track your project's evolution:

| Ledger | Purpose |
|--------|---------|
| `PROJECT_HISTORY.md` | Durable architectural decisions, milestones, and design rationale |
| `ERROR_LOG.md` | Incidents, root causes, and applied fixes |

Any new agent (or new team member) reads these ledgers and understands *why* decisions were made — without you explaining.

## 💬 Concise Communications

The kernel forces direct, token-efficient responses:

- No robotic greetings ("Hello, I am an AI assistant...")
- No unnecessary summaries of what the agent is about to do
- Straight-to-the-point answers that respect your time and your token budget

## 🤝 Provider Agnostic

Antigravity Ultra is not tied to any AI provider. Start architecture with **Gemini**, run security audits with **Claude**, write complex logic with **Codex**. Any Markdown-aware agent reads the same `GEMINI.md` rulebook and `.agent/` state — and instantly understands your project.

## 🛠️ Automatic Skill Discovery

The system dynamically discovers and connects specialized skills:

- **Design work?** Auto-connects the `impeccable` skill for premium UI/UX.
- **Security audit?** Activates `ghost-scan-code` for SAST analysis.
- **Docker issues?** Loads `docker-expert` for container troubleshooting.

Skills are injected on demand — your agent gets expert-level tools instantly, without manual configuration.

## 🛡️ Security First & Safe Delete

Two safety layers protect your work:

- **Safe Delete:** Agents never permanently delete project files. Deleted files are moved to `_DEPRECATED_TRASH`, giving you a safety net against AI accidents.
- **Permission Tiers:** Routine, low-risk edits run automatically (`AUTO`). Critical operations — deployments, architecture shifts, external integrations — require your explicit confirmation (`CONFIRM`).

## ⚡ Portable Installation (Exactly 5 Files)

The official portable kit ships as exactly 5 root files: `GEMINI.md`, `MEMORY.md`, `GEMINI_BLUEPRINTS.md`, `portable-kernel.sh`, and `portable-kernel-windows.ps1`. Copy those into any project directory and run the installer. Four tiers let you choose your level of tooling:

| Tier | Includes |
|------|----------|
| `minimal` | Core engine, live state, memory vault |
| `recommended` | + Workflows, audit tools |
| `complete` | + MCP templates, evaluations, telemetry, testing |
| `custom` | Pick modules individually |

Cross-platform: macOS, Linux, and Windows PowerShell. No dependencies beyond Bash 4+ or PowerShell 5+.

`.portable/` is generated locally as cache/recovery output by bootstrap/recover/doctor. It is not canon and is not copied as part of the portable kit.
