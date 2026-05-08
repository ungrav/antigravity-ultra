# Antigravity Ultra 🚀

**Give your AI agents memory that survives between conversations.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Version](https://img.shields.io/badge/kernel-v9.2.1-blueviolet)
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
Normal coding → read only target files (0 extra tokens)
Bug fix       → 10 lines from ERROR_LOG.md (~125 tokens)
Architecture  → Project DNA digest (~300 tokens)
Memory work   → Full spec loaded (~1,940 tokens)
```

Most frameworks load their entire context on every turn. Antigravity loads context **proportionally**.

## ⚡ Token Efficiency

In a 100-turn session, overhead context comparison:

| System | Tokens | vs Ultra |
|--------|--------|----------|
| **Antigravity Ultra** | **~12,450** | **baseline** |
| Antigravity (without Ultra) | variable | manual — you repeat context each session |
| OpenCode | ~66,100 | 5× more |
| Everything Claude Code | ~202,400 | 16× more |
| Claude Code | ~300,000 | 24× more |

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

Cada vez que inicias un chat nuevo, pierdes el contexto. Desperdicias tokens repitiendo instrucciones. Antigravity Ultra lo resuelve: instala 6 archivos y cualquier agente — Gemini, Claude, Codex — entiende al instante las reglas, historia y estado de tu proyecto.

```bash
curl -fsSL https://raw.githubusercontent.com/ungrav/antigravity-ultra/main/install.sh | bash
```

### Cómo Funciona

Los agentes siguen un **Golden Path** — cargan solo lo que la tarea necesita:

```
Coding normal  → solo archivos objetivo (0 tokens extra)
Bug fix        → 10 líneas de ERROR_LOG.md (~125 tokens)
Arquitectura   → Project DNA (~300 tokens)
Memoria        → Spec completa (~1,940 tokens)
```

### ⚡ Eficiencia de Tokens

En una sesión de 100 turnos:

| Sistema | Tokens | vs Ultra |
|---------|--------|----------|
| **Antigravity Ultra** | **~12,450** | **baseline** |
| Antigravity (sin Ultra) | variable | manual — repites contexto cada sesión |
| OpenCode | ~66,100 | 5× más |
| Everything Claude Code | ~202,400 | 16× más |
| Claude Code | ~300,000 | 24× más |

### 🌟 Características

| | Característica | Qué hace |
|---|---------------|----------|
| 🧠 | **Memoria Persistente** | Knowledge Items en Markdown — los agentes recuerdan decisiones, bugs y arquitectura |
| ⚡ | **Golden Path** | Enrutamiento por tarea: cero contexto del kernel para el 80% de las tareas |
| 🤝 | **Cualquier Proveedor** | Mismas reglas para Gemini, Claude, Codex o cualquier agente Markdown |
| 🕵️ | **Verificar, No Asumir** | Los agentes deben probar que los cambios funcionan — `PASS`, `FAIL` o `PARTIAL` |
| 📚 | **Historial Permanente** | `PROJECT_HISTORY.md` + `ERROR_LOG.md` inmutables — cualquier agente nuevo se pone al día |
| 🛡️ | **Borrado Seguro** | Los archivos van a `_DEPRECATED_TRASH`, nunca se eliminan permanentemente |
| 📐 | **Cero Monolitos** | Los agentes parchean solo la superficie necesaria |

Detalles completos → **[FEATURES_ES.md](./FEATURES_ES.md)**

### 📦 Kit Portable

Todo se distribuye en **exactamente 6 archivos**. El instalador crea todo lo demás: `.agent/`, `.portable/`, configs, scripts.

```bash
# macOS / Linux
bash portable-kernel.sh bootstrap --tier recommended

# Windows
powershell -ExecutionPolicy Bypass -File .\portable-kernel-windows.ps1 bootstrap -Tier recommended
```

**Requisitos:** Bash 4+ o PowerShell 5+. Sin otras dependencias.

### ⚖️ Licencia

**GNU GPLv3** — Ver [LICENSE](./LICENSE).
