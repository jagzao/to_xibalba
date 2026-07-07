---
name: spec
description: Define una especificación de feature de gameplay desde una idea, refinando asunciones una a una. Usar cuando el usuario dice "/spec", "define spec", "quiero especificar", o da una idea de mecánica/nivel/enemigo a elaborar.
metadata:
  author: xibalba
  version: "1.0"
  language: es
---

# Skill: Definir Especificación (Xibalbá)

Convierte una idea de gameplay en spec completa, refinando asunciones una a una. `docs/*.md` es la fuente de verdad del diseño — la spec NO puede contradecirlos; si hay conflicto, pregunta.

## FASE 1 — Leer idea y rellenar huecos
1. Sin idea del usuario → pídela.
2. Lee los `docs/*.md` relevantes al tema ANTES de asumir nada.
3. Elabora spec inicial: mecánica, entidades/componentes afectados, valores de balance (→ Resources), señales EventBus nuevas, criterios de aceptación (= asserts GUT verificables), casos borde.
4. Lista **asunciones de gameplay/balance** hechas (comportamiento, números, feel, interacciones). No técnicas de infraestructura.

## FASE 2 — Mostrar asunciones
Lista numerada + instrucción: "números a refinar, o `0` si todo bien". Espera respuesta.

## FASE 3 — Refinamiento
Una pregunta por turno, formato:
```
**Progreso:** [████░░░░░░] N de M
**Asunción #X:** [texto]
  1-4. [opciones concretas del dominio]
  5. Otra (especifica)
```
Espera cada respuesta antes de avanzar.

## FASE 4 — Spec final
Con todo respondido, genera spec con secciones:
1. **Descripción** 2. **Componentes/estados afectados** (composición, FSM, Resources) 3. **Flujo de gameplay** 4. **Balance** (tabla de valores → qué Resource) 5. **Señales EventBus** (nuevas/usadas) 6. **Criterios de aceptación** (formulados como asserts GUT) 7. **Casos borde**

## GUARDAR
1. Slug kebab-case del feature (ej. `panic-state`, `murcielago-seek`).
2. Guarda en `.agents/memory/tasks/{slug}.md`.
3. Commit: `docs(spec): {slug} — especificación` (solo archivos de `.agents/memory/tasks/`).
4. Muestra: `▶ Siguiente paso: /auto-implement {slug}`
