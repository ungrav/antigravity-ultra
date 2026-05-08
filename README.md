# Antigravity Ultra 🚀

🌍 [🇺🇸 English](#-english) | [🇪🇸 Español](#-español)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Version](https://img.shields.io/badge/kernel-v9.2.1-blueviolet)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)

---

## 🇺🇸 English

**A portable v9 hybrid-strict kernel that gives AI agents persistent memory, a lean daily core, and generated recovery tooling across any project, any provider.**

Antigravity Ultra manages the identity, memory, and operational rules of autonomous AI agents. Native Antigravity starts from `GEMINI.md` + `.agent/current_state.md`; Claude, Codex, and other external agents start from `AGENTS.md` + `.agent/current_state.md`. Install once, and every project gets structured memory that survives across conversations.

Antigravity Ultra is not the Antigravity product itself. It is a portable, optimized kernel for projects where Antigravity, Gemini, Claude, Codex, or any Markdown-aware agent need the same rules, current state, and local project memory.

### The Problem It Solves

Every time you start a new AI chat, you lose context. You waste tokens repeating instructions. Different agents don't share knowledge about your project. Antigravity Ultra fixes this with:

- **Persistent project memory** that agents read when the task needs durable context
- **A single rulebook** that any AI provider understands
- **Structured knowledge** organized so agents load only what they need

### How It Works

```
┌──────────────────────────────────────────────────┐
│                  Your Project                    │
│                                                  │
│  GEMINI.md ─── Operational rules & safety        │
│  MEMORY.md ─── Memory system specification       │
│  .agent/   ─── Live state + knowledge vault      │
│    ├── current_state.md   (session handoff)      │
│    ├── current_state.json (structured state)     │
│    ├── project_state.json (generated cache)      │
│    └── knowledge/         (durable KIs)          │
│  PROJECT_HISTORY.md ──── Architectural decisions │
│  ERROR_LOG.md ────────── Incident ledger         │
│                                                  │
│  Any AI agent reads these files and instantly    │
│  understands your project's rules & history.     │
└──────────────────────────────────────────────────┘
```

Agents follow a **Golden Path**: for normal tasks, they read only the target files. For bugs, they check the error log. For architecture decisions, they read project history. This saves thousands of tokens per conversation.

### 🌟 Features

Full details in **[FEATURES_EN.md](./FEATURES_EN.md)**.

| Feature | Description |
|---------|-------------|
| 🧠 **Persistent Memory** | Markdown-based Knowledge Items (KIs) with structured frontmatter |
| 📐 **Zero Monoliths** | Agents edit minimally, patch only the needed surface, and build incrementally |
| 🔧 **Autofix Skill** | On-demand eval-driven debugging loop |
| 🕵️ **Adversarial Verification** | Agents must verify with evidence, not assumptions |
| 📚 **Project Ledgers** | Immutable history of architectural decisions |
| 🛡️ **Safe Delete** | Files go to `_DEPRECATED_TRASH`, never permanently deleted |
| 🤝 **Provider Agnostic** | Works with Gemini, Claude, Codex, or any Markdown-aware agent |
| ⚡ **Context Efficiency** | Golden Path routing keeps normal tasks focused on target files instead of loading the whole memory vault |

### ⚡ Why Ultra Saves Context

Ultra does not magically reduce model cost. It reduces the extra project context agents need to load before they can work. The benefit is practical: each project has live state and local memory, so Gemini, Claude, Codex, and Antigravity can continue without you repeating the same background.

| System | Project Context | Local Memory | Multi-Agent Handoff | Estimated Overhead |
|---|---|---|---|---|
| Antigravity without Ultra | Manual prompt/chat context | No canonical portable memory | Depends on the user | Variable/manual |
| Antigravity Ultra | Golden Path + live state | KIs + Project DNA | `AGENTS.md` for Claude/Codex/Gemini | Low/proportional |
| OpenCode | Declarative project config | Limited | Partial | ~661 tokens base context |
| Claude Code | Integrated memory + project context | Yes | Mostly Claude | ~3k+ tokens depending on memory/context |
| Everything Claude Code | Large AGENTS/CLAUDE catalog | Manual/contextual | Claude agent catalog | ~2k tokens base context |

These are context-overhead estimates, not total inference cost. They show the strategy difference: Ultra loads context by task type; other systems often rely more on static context or integrated memory prompts.

### 🧠 When Memory Is Saved

Ultra does not save every turn. Memory is captured when a session closes or a durable task is verified. Use natural triggers like **"cerrar sesión"**, **"cierre"**, **"closeout"**, **"wrap up"**, **"handoff"**, or **"continuar luego"**.

The agent then updates the live state, writes a session summary, verifies the project, and only saves durable memory when there is something worth keeping: decisions, architecture, bug fixes, incidents, contracts, configuration, or useful handoff notes.

### 📂 The Portable Kit

The official portable distribution is exactly 6 root files:

| File | Role |
|------|------|
| `GEMINI.md` | The operational rulebook — identity, safety boundaries, Golden Path |
| `MEMORY.md` | Memory system specification — how to create and read Knowledge Items |
| `GEMINI_BLUEPRINTS.md` | Human-readable recovery contract and manifest summary |
| `portable-kernel.sh` | Smart installer for macOS / Linux |
| `portable-kernel-windows.ps1` | Smart installer for Windows PowerShell |
| `minimum-kernel.bundle.tar.gz` | Portable payload used by bootstrap/recover |

`.portable/` is generated locally by `bootstrap`, `recover`, or `doctor` as cache/recovery output. It is not canon and is not a folder users copy by hand. If it is deleted, the launcher regenerates it from `minimum-kernel.bundle.tar.gz`.

The public repository is intentionally minimal: root docs, the public installer, and the six portable kit files. Runtime directories such as `.agent/`, `.portable/`, `config/`, `scripts/`, and `workflows/` are created or restored by `bootstrap` from the portable payload. They are not extra files users need to understand or copy manually.

Operationally, the model stays simple:

- `GEMINI.md` tells Antigravity how to behave.
- `AGENTS.md` is generated during bootstrap for Claude, Codex, and other external agents.
- `.agent/current_state.md` is generated per project as the live handoff.
- `minimum-kernel.bundle.tar.gz` carries the recoverable runtime pieces.
- `.portable/` is only local cache and can be regenerated.

### 🚀 Quick Install

**Prerequisites:** Bash 4+ (macOS/Linux) or PowerShell 5+ (Windows). No other dependencies.

Recommended install from the latest GitHub release:

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

To choose a target directory or tier:

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash -s -- --root ./my-project --tier minimal
```

The installer downloads the 6 portable files, runs `probe`, runs `bootstrap --tier recommended` by default, then runs `doctor`.

You can also download the 6 portable files manually and choose a tier:

| Tier | What You Get |
|------|-------------|
| 🌱 **minimal** | Core engine, live state, memory vault. Bare minimum for persistent context. |
| ⭐ **recommended** | Minimal + workflows + audit tools. Best for most developers. |
| 🔥 **complete** | Full ecosystem: MCP templates, evaluations, telemetry, testing. |
| ⚙️ **custom** | Interactive — choose each module individually. |

**macOS / Linux:**
```bash
bash portable-kernel.sh bootstrap --tier recommended
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Tier recommended
```

> The installer probes the project, creates or repairs `.agent/`, generates `.portable/` cache/recovery files, runs doctor checks, and then resumes the user's original intent.

### 🚫 What This Is NOT

- **Not an AI model.** It's infrastructure that makes existing models smarter about your project.
- **Not a chatbot framework.** It manages context and memory, not conversation UI.
- **Not a replacement for your IDE.** It works inside whatever tools you already use.

### 🤝 Contributing

Antigravity Ultra is open source under GPLv3. Issues and PRs are welcome.

### ⚖️ License

**GNU GPLv3** — See [LICENSE](./LICENSE).

---

## 🇪🇸 Español

**Un kernel portable v9 híbrido estricto que da a los agentes de IA memoria persistente, core diario mínimo y recuperación generada — en cualquier proyecto, con cualquier proveedor.**

Antigravity Ultra gestiona la identidad, memoria y reglas operativas de agentes de IA autónomos. Antigravity nativo empieza desde `GEMINI.md` + `.agent/current_state.md`; Claude, Codex y otros agentes externos empiezan desde `AGENTS.md` + `.agent/current_state.md`. Instálalo una vez y cada proyecto obtiene memoria estructurada que sobrevive entre conversaciones.

Antigravity Ultra no es el producto Antigravity como tal. Es un kernel portable y optimizado para proyectos donde Antigravity, Gemini, Claude, Codex o cualquier agente que lea Markdown necesitan las mismas reglas, estado actual y memoria local del proyecto.

### El Problema que Resuelve

Cada vez que inicias un chat nuevo con IA, pierdes el contexto. Desperdicias tokens repitiendo instrucciones. Diferentes agentes no comparten conocimiento sobre tu proyecto. Antigravity Ultra lo resuelve con:

- **Memoria de proyecto persistente** que los agentes leen cuando la tarea necesita contexto duradero
- **Un único reglamento** que cualquier proveedor de IA entiende
- **Conocimiento estructurado** organizado para que los agentes carguen solo lo necesario

### Cómo Funciona

```
┌──────────────────────────────────────────────────┐
│                  Tu Proyecto                     │
│                                                  │
│  GEMINI.md ─── Reglas operativas y seguridad     │
│  MEMORY.md ─── Especificación del sistema de     │
│                memoria                           │
│  .agent/   ─── Estado en vivo + baúl de          │
│                conocimiento                      │
│    ├── current_state.md   (handoff de sesión)    │
│    ├── current_state.json (estado estructurado)  │
│    ├── project_state.json (caché generado)       │
│    └── knowledge/         (KIs duraderos)        │
│  PROJECT_HISTORY.md ──── Decisiones de           │
│                          arquitectura            │
│  ERROR_LOG.md ────────── Registro de incidentes  │
│                                                  │
│  Cualquier agente de IA lee estos archivos y     │
│  entiende al instante las reglas e historia      │
│  de tu proyecto.                                 │
└──────────────────────────────────────────────────┘
```

Los agentes siguen un **Golden Path**: para tareas normales, leen solo los archivos objetivo. Para bugs, revisan el error log. Para decisiones de arquitectura, leen el historial. Esto ahorra miles de tokens por conversación.

### 🌟 Características

Detalles completos en **[FEATURES_ES.md](./FEATURES_ES.md)**.

| Característica | Descripción |
|---------------|-------------|
| 🧠 **Memoria Persistente** | Knowledge Items (KIs) en Markdown con frontmatter estructurado |
| 📐 **Cero Monolitos** | Los agentes editan mínimamente, parchean solo la superficie necesaria y construyen de forma incremental |
| 🔧 **Skill de Autofix** | Loop de debugging iterativo guiado por evaluaciones |
| 🕵️ **Verificación Adversarial** | Los agentes verifican con evidencia, no con suposiciones |
| 📚 **Historial Permanente** | Registro inmutable de decisiones arquitectónicas |
| 🛡️ **Borrado Seguro** | Los archivos van a `_DEPRECATED_TRASH`, nunca se eliminan permanentemente |
| 🤝 **Agnóstico de Proveedor** | Funciona con Gemini, Claude, Codex o cualquier agente que lea Markdown |
| ⚡ **Eficiencia de Contexto** | Golden Path mantiene las tareas normales enfocadas en archivos objetivo, sin cargar todo el baúl de memoria |

### ⚡ Por qué Ultra ahorra contexto

Ultra no reduce el costo del modelo por arte de magia. Reduce el contexto extra que los agentes necesitan cargar para orientarse. El beneficio real es práctico: cada proyecto tiene estado vivo y memoria local, así que Gemini, Claude, Codex y Antigravity pueden continuar sin que repitas la misma explicación.

| Sistema | Contexto del proyecto | Memoria local | Handoff multiagente | Overhead estimado |
|---|---|---|---|---|
| Antigravity sin Ultra | Manual en cada chat | No portable/canónica | Depende del usuario | Variable/manual |
| Antigravity Ultra | Golden Path + estado vivo | KIs + Project DNA | `AGENTS.md` para Claude/Codex/Gemini | Bajo/proporcional |
| OpenCode | Config declarativa | Limitada | Parcial | ~661 tokens de contexto base |
| Claude Code | Memoria integrada + contexto de proyecto | Sí | Principalmente Claude | ~3k+ tokens según memoria/contexto |
| Everything Claude Code | Catálogo AGENTS/CLAUDE grande | Manual/contextual | Catálogo de agentes Claude | ~2k tokens de contexto base |

Estas cifras son estimaciones de overhead de contexto, no costo total de inferencia. Sirven para mostrar la diferencia de estrategia: Ultra carga contexto según la tarea; otros sistemas suelen depender más de contexto estático o prompts de memoria integrados.

### 🧠 Cuándo se guarda memoria

Ultra no guarda cada turno. La memoria se captura cuando se cierra una sesión o termina una tarea durable verificada. Usa triggers naturales como **"cerrar sesión"**, **"cierre"**, **"closeout"**, **"wrap up"**, **"handoff"** o **"continuar luego"**.

El agente actualiza el estado vivo, escribe un resumen de sesión, verifica el proyecto y solo guarda memoria durable cuando hay algo que vale la pena conservar: decisiones, arquitectura, fixes de bugs, incidentes, contratos, configuración o notas útiles de handoff.

### 📂 El Kit Portable

La distribución portable oficial son exactamente 6 archivos raíz:

| Archivo | Rol |
|---------|-----|
| `GEMINI.md` | El reglamento operativo — identidad, límites de seguridad, Golden Path |
| `MEMORY.md` | Especificación del sistema de memoria — cómo crear y leer Knowledge Items |
| `GEMINI_BLUEPRINTS.md` | Contrato de recuperación legible y resumen del manifest |
| `portable-kernel.sh` | Instalador inteligente para macOS / Linux |
| `portable-kernel-windows.ps1` | Instalador inteligente para Windows PowerShell |
| `minimum-kernel.bundle.tar.gz` | Payload portable usado por bootstrap/recover |

`.portable/` se genera localmente por `bootstrap`, `recover` o `doctor` como caché/recuperación. No es canon y no es una carpeta que el usuario deba copiar manualmente. Si se borra, el launcher la regenera desde `minimum-kernel.bundle.tar.gz`.

El repositorio publico es intencionalmente minimalista: docs raíz, el instalador publico y los seis archivos del kit portable. Directorios runtime como `.agent/`, `.portable/`, `config/`, `scripts/` y `workflows/` se crean o restauran por `bootstrap` desde el payload portable. No son archivos extra que el usuario tenga que entender o copiar manualmente.

Operativamente, el modelo queda simple:

- `GEMINI.md` le dice a Antigravity como comportarse.
- `AGENTS.md` se genera durante bootstrap para Claude, Codex y otros agentes externos.
- `.agent/current_state.md` se genera por proyecto como handoff vivo.
- `minimum-kernel.bundle.tar.gz` contiene las piezas runtime recuperables.
- `.portable/` es solo cache local y se puede regenerar.

### 🚀 Instalación Rápida

**Requisitos previos:** Bash 4+ (macOS/Linux) o PowerShell 5+ (Windows). Sin otras dependencias.

Instalación recomendada desde el último GitHub release:

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

Para elegir directorio o perfil:

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash -s -- --root ./mi-proyecto --tier minimal
```

El instalador descarga los 6 archivos portables, ejecuta `probe`, ejecuta `bootstrap --tier recommended` por defecto y luego ejecuta `doctor`.

También puedes descargar los 6 archivos portables manualmente y elegir un perfil:

| Perfil | Qué Incluye |
|--------|-------------|
| 🌱 **minimal** | Motor básico, estado en vivo, baúl de memoria. Lo mínimo para contexto persistente. |
| ⭐ **recommended** | Minimal + workflows + herramientas de auditoría. Ideal para la mayoría. |
| 🔥 **complete** | Ecosistema completo: plantillas MCP, evaluaciones, telemetría, testing. |
| ⚙️ **custom** | Interactivo — elige cada módulo individualmente. |

**macOS / Linux:**
```bash
bash portable-kernel.sh bootstrap --tier recommended
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Tier recommended
```

> El instalador hace `probe`, crea o repara `.agent/`, genera la caché `.portable/`, ejecuta doctor y retoma la intención original del usuario.

### 🚫 Lo que NO Es

- **No es un modelo de IA.** Es infraestructura que hace que los modelos existentes sean más inteligentes con tu proyecto.
- **No es un framework de chatbot.** Gestiona contexto y memoria, no interfaces de conversación.
- **No reemplaza tu IDE.** Funciona dentro de las herramientas que ya usas.

### 🤝 Contribuir

Antigravity Ultra es open source bajo GPLv3. Issues y PRs son bienvenidos.

### ⚖️ Licencia

**GNU GPLv3** — Ver [LICENSE](./LICENSE).
