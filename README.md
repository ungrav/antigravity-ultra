# Antigravity Ultra 🚀

**Give your AI agents memory that survives between conversations.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Version](https://img.shields.io/badge/kernel-v9.2.3-blueviolet)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)

🌍 *[🇪🇸 Leer en Español](#-español)*

---

Every time you start a new AI chat, you lose context. You waste tokens repeating instructions. Different agents don't share knowledge about your project.

**Antigravity Ultra fixes this.** Install 6 files, and every AI agent — Gemini, Claude, Codex, or any Markdown-aware tool — instantly knows your project's rules, history, and current state.

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

## How It Works

Agents follow a **Golden Path** — they load only what the current task needs:

```
Normal coding → read only target files (0 extra context)
Bug fix       → 10 lines from ERROR_LOG.md (~125 tokens)
Architecture  → Project DNA digest (~300 tokens)
Memory work   → Full memory spec (~1,940 tokens)
```

## ⚡ Why Ultra Saves Tokens

Every agent framework injects context per turn. Ultra's advantage isn't a smaller system prompt — it's **what agents don't need to do** because the project is already documented:

| Without Ultra | With Ultra |
|---------------|------------|
| Re-explain project context every session | Agent reads `current_state.md` and continues |
| Manually repeat architecture decisions | Agent checks `PROJECT_HISTORY.md` |
| Describe past bugs and fixes | Agent reads `ERROR_LOG.md` |
| Re-read the entire codebase to orient | Agent reads `Project DNA` (50 lines) |
| Lose knowledge when switching agents | All agents share the same `.agent/` state |

The Golden Path also controls **additional** context per task — normal coding loads zero extra files, bugs load only the error log, architecture loads only the project digest. Other frameworks load everything on every turn regardless of task type.

### How It Adds Up

The extra context an agent loads **beyond the system prompt** per task type:

| System | Normal task | Bug task | Architecture | Memory work |
|--------|------------|----------|-------------|-------------|
| **Antigravity Ultra** | **+0** | **+125** | **+300** | **+1,940** |
| OpenCode | +661 | +661 | +661 | +661 |
| Everything Claude Code | +2,024 | +2,024 | +2,024 | +2,024 |
| Claude Code | +3,000 | +3,000 | +3,000 | +3,000 |

Over 100 turns (80 normal, 10 bugs, 5 architecture, 5 memory), that extra context totals:

| System | Extra context loaded | vs Ultra |
|--------|---------------------|----------|
| **Antigravity Ultra** | **~12,450** | — |
| OpenCode | ~66,100 | 5× more |
| Everything Claude Code | ~202,400 | 16× more |
| Claude Code | ~300,000 | 24× more |

But the biggest saving is **across sessions**: with per-project memory, session 2 starts where session 1 ended. Without it, you start from zero every time.

## 🌟 Features

| | Feature | What it does |
|---|---------|-------------|
| 🧠 | **Persistent Memory** | Markdown Knowledge Items with structured frontmatter — agents remember decisions, bugs, and architecture |
| ⚡ | **Golden Path** | Task-based routing: agents load zero kernel context for 80% of tasks |
| 🤝 | **Any Provider** | Same rules for Gemini, Claude, Codex, or any Markdown-aware agent |
| 🕵️ | **Verify, Don't Assume** | Agents must prove changes work with evidence — `PASS`, `FAIL`, or `PARTIAL` |
| 📚 | **Project Ledgers** | Immutable `PROJECT_HISTORY.md` + `ERROR_LOG.md` — any new agent reads them and catches up |
| 🛡️ | **Safe Delete** | Files go to `_DEPRECATED_TRASH`, never permanently deleted |
| 📐 | **Zero Monoliths** | Agents patch only the needed surface — no giant rewrites |

Full details → **[FEATURES_EN.md](./FEATURES_EN.md)** · **[FEATURES_ES.md](./FEATURES_ES.md)**

## 📦 The Portable Kit

Everything ships as **exactly 6 files**:

| File | Purpose |
|------|---------|
| `GEMINI.md` | Operational rulebook (87 lines) |
| `MEMORY.md` | Memory system spec (164 lines) |
| `GEMINI_BLUEPRINTS.md` | Recovery contract |
| `portable-kernel.sh` | Installer for macOS / Linux |
| `portable-kernel-windows.ps1` | Installer for Windows |
| `minimum-kernel.bundle.tar.gz` | Runtime payload |

The installer creates everything else: `.agent/`, `.portable/`, configs, scripts. You only carry 6 files.

## 🚀 Install

**One command:**

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

**Choose your tier:**

| Tier | What You Get |
|------|-------------|
| 🌱 `minimal` | Core engine + memory vault |
| ⭐ `recommended` | + Workflows + audit tools |
| 🔥 `complete` | + MCP templates, evals, telemetry |
| ⚙️ `custom` | Pick modules individually |

```bash
# macOS / Linux
bash portable-kernel.sh bootstrap --tier recommended

# Windows
powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Tier recommended
```

**Prerequisites:** Bash 4+ or PowerShell 5+. No other dependencies.

## 🚫 What This Is NOT

- Not an AI model — it makes existing models smarter about *your* project
- Not a chatbot — it manages context and memory, not conversation UI
- Not an IDE replacement — it works inside whatever tools you already use

## 🤝 Contributing

Open source under **GPLv3**. Issues and PRs are welcome.

---

## 🇪🇸 Español

**Dale a tus agentes de IA memoria que sobrevive entre conversaciones.**

Cada vez que inicias un chat nuevo, pierdes el contexto. Desperdicias tokens repitiendo instrucciones. Diferentes agentes no comparten conocimiento sobre tu proyecto.

**Antigravity Ultra lo resuelve.** Instala 6 archivos y cualquier agente — Gemini, Claude, Codex o cualquier herramienta que lea Markdown — entiende al instante las reglas, historia y estado de tu proyecto.

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

### Cómo Funciona

Los agentes siguen un **Golden Path** — cargan solo lo que la tarea necesita:

```
Coding normal  → solo archivos objetivo (0 contexto extra)
Bug fix        → 10 líneas de ERROR_LOG.md (~125 tokens)
Arquitectura   → Project DNA (~300 tokens)
Memoria        → Spec completa de memoria (~1,940 tokens)
```

### ⚡ Por Qué Ultra Ahorra Tokens

Todos los frameworks inyectan contexto por turno. La ventaja de Ultra no es un system prompt más pequeño — es **lo que los agentes no necesitan hacer** porque el proyecto ya está documentado:

| Sin Ultra | Con Ultra |
|-----------|----------|
| Re-explicar contexto cada sesión | El agente lee `current_state.md` y continúa |
| Repetir decisiones de arquitectura | El agente consulta `PROJECT_HISTORY.md` |
| Describir bugs pasados | El agente lee `ERROR_LOG.md` |
| Re-leer todo el código para orientarse | El agente lee `Project DNA` (50 líneas) |
| Perder conocimiento al cambiar de agente | Todos comparten el mismo estado `.agent/` |

El Golden Path también controla el contexto **adicional** por tarea — coding normal carga cero archivos extra, bugs cargan solo el error log, arquitectura solo el digest del proyecto. Otros frameworks cargan todo en cada turno sin importar el tipo de tarea.

#### Cómo se Acumula

El contexto extra que un agente carga **más allá del system prompt** por tipo de tarea:

| Sistema | Tarea normal | Bug | Arquitectura | Memoria |
|---------|-------------|-----|-------------|--------|
| **Antigravity Ultra** | **+0** | **+125** | **+300** | **+1,940** |
| OpenCode | +661 | +661 | +661 | +661 |
| Everything Claude Code | +2,024 | +2,024 | +2,024 | +2,024 |
| Claude Code | +3,000 | +3,000 | +3,000 | +3,000 |

En 100 turnos (80 normales, 10 bugs, 5 arquitectura, 5 memoria), ese contexto extra suma:

| Sistema | Contexto extra cargado | vs Ultra |
|---------|----------------------|----------|
| **Antigravity Ultra** | **~12,450** | — |
| OpenCode | ~66,100 | 5× más |
| Everything Claude Code | ~202,400 | 16× más |
| Claude Code | ~300,000 | 24× más |

Pero el mayor ahorro es **entre sesiones**: con memoria por proyecto, la sesión 2 empieza donde terminó la sesión 1. Sin ella, empiezas de cero cada vez.

### 🌟 Características

| | Característica | Qué hace |
|---|---------------|----------|
| 🧠 | **Memoria Persistente** | Knowledge Items en Markdown con frontmatter estructurado — los agentes recuerdan decisiones, bugs y arquitectura |
| ⚡ | **Golden Path** | Enrutamiento por tarea: cero contexto del kernel para el 80% de las tareas |
| 🤝 | **Cualquier Proveedor** | Mismas reglas para Gemini, Claude, Codex o cualquier agente Markdown |
| 🕵️ | **Verificar, No Asumir** | Los agentes deben probar que los cambios funcionan — `PASS`, `FAIL` o `PARTIAL` |
| 📚 | **Historial Permanente** | `PROJECT_HISTORY.md` + `ERROR_LOG.md` inmutables — cualquier agente nuevo se pone al día |
| 🛡️ | **Borrado Seguro** | Los archivos van a `_DEPRECATED_TRASH`, nunca se eliminan permanentemente |
| 📐 | **Cero Monolitos** | Los agentes parchean solo la superficie necesaria |

Detalles completos → **[FEATURES_ES.md](./FEATURES_ES.md)**

### 📦 Kit Portable

Todo se distribuye en **exactamente 6 archivos**:

| Archivo | Propósito |
|---------|-----------|
| `GEMINI.md` | Reglamento operativo (87 líneas) |
| `MEMORY.md` | Especificación de memoria (164 líneas) |
| `GEMINI_BLUEPRINTS.md` | Contrato de recuperación |
| `portable-kernel.sh` | Instalador para macOS / Linux |
| `portable-kernel-windows.ps1` | Instalador para Windows |
| `minimum-kernel.bundle.tar.gz` | Payload runtime |

El instalador crea todo lo demás: `.agent/`, `.portable/`, configs, scripts. Solo cargas 6 archivos.

### 🚀 Instalación

**Un solo comando:**

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

**Elige tu perfil:**

| Perfil | Qué incluye |
|--------|-------------|
| 🌱 `minimal` | Motor base + baúl de memoria |
| ⭐ `recommended` | + Workflows + herramientas de auditoría |
| 🔥 `complete` | + Plantillas MCP, evals, telemetría |
| ⚙️ `custom` | Elige módulos individualmente |

```bash
# macOS / Linux
bash portable-kernel.sh bootstrap --tier recommended

# Windows
powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Tier recommended
```

**Requisitos:** Bash 4+ o PowerShell 5+. Sin otras dependencias.

### 🚫 Lo que NO Es

- No es un modelo de IA — hace que los modelos existentes sean más inteligentes con *tu* proyecto
- No es un chatbot — gestiona contexto y memoria, no interfaces de conversación
- No reemplaza tu IDE — funciona dentro de las herramientas que ya usas

### 🤝 Contribuir

Open source bajo **GPLv3**. Issues y PRs son bienvenidos.

### ⚖️ Licencia

**GNU GPLv3** — Ver [LICENSE](./LICENSE).
