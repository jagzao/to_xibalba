---
name: auto-implement
description: Pipeline autónomo de implementación desde una spec de .agents/memory/tasks/ - implementa bajo las reglas del proyecto, escribe tests GUT en el mismo turno, valida con ai_harness, autocorrige, actualiza tech_debt y commitea. Usar cuando el usuario dice "/auto-implement", "implementa la spec" o "ejecuta el pipeline".
metadata:
  author: xibalba
  version: "1.0"
  language: es
---

# Skill: Auto-Implement (Xibalbá)

Ciclo completo spec → código commiteado sin pedir confirmación entre fases. El loop eres tú.

## ANTES DE EMPEZAR
1. Argumento slug → lee `.agents/memory/tasks/{slug}.md`. Sin argumento o inexistente → lista slugs disponibles y detente.
2. Extrae: componentes/estados a crear, valores de balance, señales EventBus, criterios de aceptación, casos borde.
3. Lee los archivos existentes que la spec toca ANTES de editar.
4. Lee `.claude/memories/tech_debt.md` — si el área tiene deuda/error conocido documentado, aplica el fix conocido desde el inicio.
5. Resumen 3-5 líneas de lo que harás. No esperes respuesta.

## FASE 1 — Implementación
**Reglas absolutas (de `.claude/CLAUDE.md`):**
- Composición sobre herencia; componentes = nodos hijos.
- FSM: estados = nodos que heredan `State`. Prohibidos booleanos de estado en el script del jugador.
- Tipado estático explícito en todo GDScript.
- Balance = Resource con `class_name`. Nunca hardcodear números en lógica.
- UI solo escucha EventBus.
- Solo tocar archivos que la spec menciona.

## FASE 2 — Tests GUT (mismo turno, no negociable)
Por cada componente/estado nuevo: `game/tests/unit/test_{nombre}.gd`. Cada criterio de aceptación de la spec = al menos un assert. Regla de oro: el test debe FALLAR si deshaces el cambio.

## FASE 3 — Validación
```bash
python ai_harness/run_pipeline.py
```
- Error de compilación → prioridad absoluta: parsear línea exacta, corregir sintaxis antes que nada.
- Test fallido → fix mínimo → re-correr pipeline COMPLETO. Máx 3 intentos por error, máx 10 correcciones totales. Superado → BLOQUEANTE, detente y reporta.

## FASE 4 — Memoria
Si hubo bug real (no typo): entrada en `.claude/memories/tech_debt.md` (síntoma/causa/fix). Siempre: registrar componentes nuevos, señales EventBus, deuda pendiente.

## FASE 5 — Commit
```
feat: {slug} — [resumen]
```
Solo `game/`, `.claude/memories/`, `.agents/`. Push si origin existe. Reporte final: archivos, tests N/N, deuda anotada, bloqueantes (o ninguno).
