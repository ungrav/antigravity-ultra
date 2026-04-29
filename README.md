<![CDATA[# Antigravity Ultra 🚀

🌍 [🇺🇸 English](#-english) | [🇪🇸 Español](#-español)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Version](https://img.shields.io/badge/kernel-v8.26-blueviolet)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)

---

## 🇺🇸 English

**A portable kernel that gives AI agents persistent memory, structured workflows, and safety guardrails — across any project, any provider.**

Antigravity Ultra manages the identity, memory, and operational rules of autonomous AI agents. It works with Gemini, Claude, Codex, or any agent that reads Markdown context files. Install once, and every project gets structured memory that survives across conversations.

### The Problem It Solves

Every time you start a new AI chat, you lose context. You waste tokens repeating instructions. Different agents don't share knowledge about your project. Antigravity Ultra fixes this with:

- **Persistent project memory** that agents read automatically
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
│    ├── current_state.md  (session handoff)        │
│    └── knowledge/        (durable KIs)           │
│  PROJECT_HISTORY.md ──── Architectural decisions  │
│  ERROR_LOG.md ────────── Incident ledger          │
│                                                  │
│  Any AI agent reads these files and instantly     │
│  understands your project's rules & history.     │
└──────────────────────────────────────────────────┘
```

Agents follow a **Golden Path**: for normal tasks, they read only the target files. For bugs, they check the error log. For architecture decisions, they read project history. This saves thousands of tokens per conversation.

### 🌟 Features

Full details in **[FEATURES_EN.md](./FEATURES_EN.md)**.

| Feature | Description |
|---------|-------------|
| 🧠 **Persistent Memory** | Markdown-based Knowledge Items (KIs) with structured frontmatter |
| 📐 **Zero Monoliths** | Pushes agents toward small, focused components |
| 🔧 **Autofix Skill** | On-demand eval-driven debugging loop |
| 🕵️ **Adversarial Verification** | Agents must verify with evidence, not assumptions |
| 📚 **Project Ledgers** | Immutable history of architectural decisions |
| 🛡️ **Safe Delete** | Files go to `_DEPRECATED_TRASH`, never permanently deleted |
| 🤝 **Provider Agnostic** | Works with Gemini, Claude, Codex, or any Markdown-aware agent |

### 📂 The Portable Kit

The entire system lives in 5 files:

| File | Role |
|------|------|
| `GEMINI.md` | The operational rulebook — identity, safety boundaries, Golden Path |
| `MEMORY.md` | Memory system specification — how to create and read Knowledge Items |
| `GEMINI_BLUEPRINTS.md` | Recovery templates and portable restore bundle |
| `portable-kernel.sh` | Smart installer for macOS / Linux |
| `portable-kernel-windows.ps1` | Smart installer for Windows PowerShell |

### 🚀 Quick Install

**Prerequisites:** Bash 4+ (macOS/Linux) or PowerShell 5+ (Windows). No other dependencies.

Download the 5 portable files and run the installer. Choose a tier:

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
.\portable-kernel-windows.ps1 -InstallTier recommended
```

> The installer creates the `.agent/` folder, injects initial context, and your AI is ready from the first prompt.

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

**Un kernel portable que da a los agentes de IA memoria persistente, workflows estructurados y controles de seguridad — en cualquier proyecto, con cualquier proveedor.**

Antigravity Ultra gestiona la identidad, memoria y reglas operativas de agentes de IA autónomos. Funciona con Gemini, Claude, Codex o cualquier agente que lea archivos Markdown de contexto. Instálalo una vez y cada proyecto obtiene memoria estructurada que sobrevive entre conversaciones.

### El Problema que Resuelve

Cada vez que inicias un chat nuevo con IA, pierdes el contexto. Desperdicias tokens repitiendo instrucciones. Diferentes agentes no comparten conocimiento sobre tu proyecto. Antigravity Ultra lo resuelve con:

- **Memoria de proyecto persistente** que los agentes leen automáticamente
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
│    ├── current_state.md  (handoff de sesión)      │
│    └── knowledge/        (KIs duraderos)         │
│  PROJECT_HISTORY.md ──── Decisiones de           │
│                          arquitectura            │
│  ERROR_LOG.md ────────── Registro de incidentes   │
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
| 📐 **Cero Monolitos** | Empuja a los agentes hacia componentes pequeños y enfocados |
| 🔧 **Skill de Autofix** | Loop de debugging iterativo guiado por evaluaciones |
| 🕵️ **Verificación Adversarial** | Los agentes verifican con evidencia, no con suposiciones |
| 📚 **Historial Permanente** | Registro inmutable de decisiones arquitectónicas |
| 🛡️ **Borrado Seguro** | Los archivos van a `_DEPRECATED_TRASH`, nunca se eliminan permanentemente |
| 🤝 **Agnóstico de Proveedor** | Funciona con Gemini, Claude, Codex o cualquier agente que lea Markdown |

### 📂 El Kit Portable

Todo el sistema vive en 5 archivos:

| Archivo | Rol |
|---------|-----|
| `GEMINI.md` | El reglamento operativo — identidad, límites de seguridad, Golden Path |
| `MEMORY.md` | Especificación del sistema de memoria — cómo crear y leer Knowledge Items |
| `GEMINI_BLUEPRINTS.md` | Templates de recuperación y bundle de restauración portable |
| `portable-kernel.sh` | Instalador inteligente para macOS / Linux |
| `portable-kernel-windows.ps1` | Instalador inteligente para Windows PowerShell |

### 🚀 Instalación Rápida

**Requisitos previos:** Bash 4+ (macOS/Linux) o PowerShell 5+ (Windows). Sin otras dependencias.

Descarga los 5 archivos portables y ejecuta el instalador. Elige un perfil:

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
.\portable-kernel-windows.ps1 -InstallTier recommended
```

> El instalador crea la carpeta `.agent/`, inyecta el contexto inicial y tu IA está lista desde el primer prompt.

### 🚫 Lo que NO Es

- **No es un modelo de IA.** Es infraestructura que hace que los modelos existentes sean más inteligentes con tu proyecto.
- **No es un framework de chatbot.** Gestiona contexto y memoria, no interfaces de conversación.
- **No reemplaza tu IDE.** Funciona dentro de las herramientas que ya usas.

### 🤝 Contribuir

Antigravity Ultra es open source bajo GPLv3. Issues y PRs son bienvenidos.

### ⚖️ Licencia

**GNU GPLv3** — Ver [LICENSE](./LICENSE).
]]>
