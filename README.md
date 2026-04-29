# Antigravity Ultra 🚀

**Superpoderes para tus Agentes de IA. Cambia las reglas del juego.**

Antigravity Ultra es un kernel portable y ultra-ligero diseñado para gestionar la identidad, memoria y capacidades operativas de agentes de IA autónomos (como Gemini, Claude, o Codex). 

Se acabaron los días de perder el contexto cada vez que inicias un chat nuevo. Se acabó el desperdicio masivo de tokens repitiendo las mismas instrucciones. Con Antigravity Ultra, cada uno de tus proyectos tiene una memoria única, persistente y estructurada.

---

## 🌟 Características Principales

### 🧠 Memoria Persistente y Eficiente
Nunca más pierdas el progreso de tus proyectos. Antigravity implementa un sistema de memoria basado en Markdown (Knowledge Items o KIs) estructurado jerárquicamente:
- **Project DNA**: Contexto central, reglas de negocio y arquitectura inmutable de tu proyecto.
- **Golden Path**: Un contrato de lectura estricto que asegura que los agentes solo lean lo que necesitan, cuando lo necesitan.
- **Eficiencia de Tokens**: Al evitar el inyectar historiales gigantescos y depender del estado local vivo (`current_state.md`), reduces drásticamente el gasto de tokens por cada llamada a la API.

### 🤝 Compatibilidad Multi-Agente
Antigravity es agnóstico del modelo. Puedes iniciar un proyecto con Gemini, realizar auditorías de seguridad con Claude, y refactorizar con Codex. 
- Gracias a los adaptadores portables (como `AGENTS.md` o `CLAUDE.md`), cualquier agente que introduzcas en el entorno entenderá instantáneamente el estado del proyecto, las reglas locales y dónde retomar el trabajo.

### ⚡ Workflows y Automatización
Evita quemar tokens en tareas repetitivas y ceremoniales. Antigravity soporta la integración de flujos de trabajo (*workflows*) automatizados que ejecutan pruebas, despliegues y análisis en segundo plano, permitiendo que el agente se dedique a la toma de decisiones críticas en lugar de escribir código de infraestructura básico repetidamente.

### 🛠️ Ecosistema de Skills (Habilidades)
No reinventes la rueda en cada proyecto. Antigravity permite instalar y configurar *Skills* modulares específicos:
- ¿Necesitas diseño UI premium? Instala el skill de `impeccable`.
- ¿Necesitas un escáner de seguridad? Conecta `ghost-scan-code`.
- Los skills se instalan bajo demanda y exponen herramientas y patrones pre-entrenados, dando capacidades superhumanas a tu agente de IA sin sobrecargar su contexto inicial.

### 🛡️ Seguridad y Verificación (Test-Driven)
La ejecución libre es peligrosa. Antigravity Ultra opera bajo estrictos contratos de seguridad:
- Diferenciación entre operaciones `AUTO` (seguras, reversibles) y `CONFIRM` (destructivas, despliegues).
- Infraestructura de evaluación continua (*smokes* y validaciones del kernel) para garantizar que el sistema no sufra regresiones cognitivas.

---

## 🚀 Instalación

La instalación es portátil y funciona creando un *bootstrap* en el directorio de tu proyecto. El kernel se adapta al tipo de sistema operativo y al perfil del usuario.

### Para macOS / Linux (Zsh/Bash)
Ejecuta el script de instalación inicial dentro de la raíz de tu proyecto:
```bash
bash portable-kernel.sh --profile native --init
```

### Para Windows (PowerShell)
Para entornos Windows, utiliza el launcher nativo de PowerShell:
```powershell
.\portable-kernel-windows.ps1 -Profile native -Init
```

> **Nota:** La bandera `--init` crea el entorno `.agent/`, inyecta el `GEMINI.md` e inicializa el primer estado vacío (`current_state.md`) para que comiences a interactuar de inmediato con tu agente.

---

## ⚙️ Configuración y Perfiles

Antigravity Ultra soporta diferentes perfiles de ejecución dependiendo de la agresividad y el contexto del usuario:

1. **Perfil `native`**: Para entornos donde el agente tiene permisos completos de ejecución local (ej. tu máquina personal).
2. **Perfil `external`**: Para agentes de navegador web que solo pueden leer archivos y sugerir comandos de copiado y pegado (restringe herramientas de sistema operativo).
3. **Perfil de Idioma**: Modifica la cabecera del kernel para forzar al agente a comunicarse en un idioma específico (ej. `portable_profile: source_forced_es` para respuestas exclusivas en español).

### Configurando un nuevo proyecto
1. Copia los 5 archivos base (`GEMINI.md`, `MEMORY.md`, `GEMINI_BLUEPRINTS.md`, `portable-kernel.sh`, `portable-kernel-windows.ps1`) a tu carpeta.
2. Abre tu chat de IA favorito y adjunta/referencia el archivo `GEMINI.md` o `AGENTS.md`.
3. El agente leerá las reglas, inicializará la memoria, ¡y estarás listo para construir!

---

*Desarrollado para quienes no tienen tiempo de repetir lo mismo dos veces.*
