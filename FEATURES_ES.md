<![CDATA[# Antigravity Ultra: Características y Funciones 🚀

## 🧠 Memoria Persistente y Estructurada

Nunca más pierdas el progreso de tu proyecto. La memoria se organiza en **Knowledge Items (KIs)** pequeños y enfocados — archivos Markdown con frontmatter YAML estructurado.

- **Project DNA:** Un resumen compacto del contexto central de tu proyecto, riesgos activos y referencias clave. Limitado a 50 líneas para mantenerse lean.
- **Golden Path (Enrutamiento Inteligente):** Los agentes no cargan todo el vault de memoria. Siguen una tabla de enrutamiento estricta — las tareas normales solo leen archivos objetivo, los bugs revisan `ERROR_LOG.md`, el trabajo de arquitectura lee `PROJECT_HISTORY.md`. Esto ahorra miles de tokens por conversación.
- **Carga Selectiva:** Se cargan máximo 5 KIs (~1200 tokens) por tarea. El selector filtra por `tenant_domain`, `entities` y palabras clave de la tarea.

## 📐 Arquitecturas Ultra-Modulares (Cero Monolitos)

El kernel instruye a los agentes a estructurar aplicaciones en componentes pequeños y enfocados. Sin archivos monolíticos. Beneficios:

1. **Código escalable** — Los cambios tocan superficies pequeñas, no archivos de 10,000 líneas.
2. **Ediciones precisas** — Los agentes modifican componentes específicos sin sobrescribir código no relacionado.
3. **Menor costo de tokens** — Archivos más pequeños significan menos contexto que cargar, menos alucinaciones.

## 🔧 Skill de Autofix (Loop Eval-Driven)

Un asistente de debugging bajo demanda, no magia autónoma. **Tú lo invocas, tú lo controlas.**

1. Identificas un bug y le indicas al agente qué arreglar.
2. El agente lee el error desde `ERROR_LOG.md`.
3. Diagnostica, implementa la solución y verifica el resultado.
4. Si la corrección no pasa la verificación, itera hasta resolverlo.

Es un loop estructurado, no una feature de "disparar y olvidar".

## 🕵️ Verificación Adversarial y Cero Suposiciones

Dos disciplinas incorporadas en el kernel:

- **Detección de Premisas Falsas:** Antes de ejecutar, el agente verifica si la premisa del usuario es correcta. Si no, corrige la suposición errónea antes de escribir código.
- **Verificación Basada en Evidencia:** Para cambios complejos, el agente no puede auto-certificarse. Debe ejecutar pruebas o producir evidencia real de que el cambio funciona. Los reportes usan `PASS`, `FAIL` o `PARTIAL` — nunca afirmaciones sin verificar.

## 📚 Historial Permanente (Project Ledgers)

Dos registros inmutables rastrean la evolución de tu proyecto:

| Registro | Propósito |
|----------|-----------|
| `PROJECT_HISTORY.md` | Decisiones arquitectónicas duraderas, hitos y razonamiento de diseño |
| `ERROR_LOG.md` | Incidentes, causas raíz y correcciones aplicadas |

Cualquier agente nuevo (o miembro del equipo) lee estos registros y entiende *por qué* se tomaron las decisiones — sin que tú tengas que explicar.

## 💬 Comunicaciones Concisas

El kernel fuerza respuestas directas y eficientes en tokens:

- Sin saludos robóticos ("Hola, soy un asistente de IA...")
- Sin resúmenes innecesarios de lo que el agente va a hacer
- Respuestas directo al grano que respetan tu tiempo y tu presupuesto de tokens

## 🤝 Agnóstico de Proveedor

Antigravity Ultra no está atado a ningún proveedor de IA. Arranca la arquitectura con **Gemini**, ejecuta auditorías de seguridad con **Claude**, escribe lógica compleja con **Codex**. Cualquier agente que lea Markdown lee el mismo reglamento `GEMINI.md` o `AGENTS.md` y el estado `.agent/` — y entiende tu proyecto al instante.

## 🛠️ Descubrimiento Automático de Skills

El sistema descubre y conecta skills especializados dinámicamente:

- **¿Trabajo de diseño?** Auto-conecta el skill `impeccable` para UI/UX premium.
- **¿Auditoría de seguridad?** Activa `ghost-scan-code` para análisis SAST.
- **¿Problemas con Docker?** Carga `docker-expert` para troubleshooting de contenedores.

Los skills se inyectan bajo demanda — tu agente obtiene herramientas de nivel experto al instante, sin configuración manual.

## 🛡️ Seguridad Primero y Borrado Seguro

Dos capas de seguridad protegen tu trabajo:

- **Borrado Seguro (Safe Delete):** Los agentes nunca eliminan archivos del proyecto permanentemente. Los archivos borrados se mueven a `_DEPRECATED_TRASH`, dándote una red de seguridad contra accidentes de IA.
- **Niveles de Permiso:** Ediciones rutinarias y de bajo riesgo se ejecutan automáticamente (`AUTO`). Operaciones críticas — deploys, cambios de arquitectura, integraciones externas — requieren tu confirmación explícita (`CONFIRM`).

## ⚡ Instalación Portable (5 Archivos)

Todo el sistema se distribuye en 5 archivos. Cópialos en cualquier directorio de proyecto y ejecuta el instalador. Cuatro perfiles te permiten elegir tu nivel de herramientas:

| Perfil | Incluye |
|--------|---------|
| `minimal` | Motor básico, estado en vivo, baúl de memoria |
| `recommended` | + Workflows, herramientas de auditoría |
| `complete` | + Plantillas MCP, evaluaciones, telemetría, testing |
| `custom` | Elige módulos individualmente |

Multiplataforma: macOS, Linux y Windows PowerShell. Sin dependencias más allá de Bash 4+ o PowerShell 5+.
]]>
