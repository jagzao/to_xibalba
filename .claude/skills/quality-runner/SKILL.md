---
name: quality-runner
description: Gate de calidad antes de PR/merge - corre el pipeline headless completo (compilación Godot + tests GUT), autocorrige con límites estrictos y produce reporte de veredicto. Usar cuando el usuario dice "/quality-runner", "valida todo", "quality gate" o "preparar para PR".
metadata:
  author: xibalba
  version: "1.0"
  language: es
---

# Skill: Quality Runner (Xibalbá)

Último gate antes de PR. Puede corregir código productivo y reintentar — con límites.

## LÍMITES (furnace)
```
max_intentos_por_error    : 3
max_correcciones_total    : 10   → superado: DETENER, todo BLOQUEANTE
max_archivos_por_fix      : 15
paths_permitidos          : game/src/, game/tests/, ai_harness/
paths_prohibidos          : docs/, .claude/skills/, game/addons/gut/, game/project.godot (salvo input map explícitamente requerido)
```
Fix requiere path prohibido → DETENER, reportar BLOQUEANTE.

## REGLAS ABSOLUTAS
1. No declarar listo si algo falla. 2. No ocultar errores corregidos — todos al reporte. 3. **No borrar tests para que pasen** — detener y preguntar. 4. No relajar asserts sin justificar. 5. No cambiar balance/reglas definidos en `docs/` — detener y preguntar. 6. Fallo ambiguo → preguntar, no adivinar. 7. Tras cualquier fix productivo → re-correr pipeline COMPLETO, no solo el test que falló.

## FASE 1 — Contexto
Verificar: implementación presente, tests GUT del feature existen, `.claude/memories/tech_debt.md` tiene entrada de la sesión. Falta algo → reportar y detener.

## FASE 2 — Pipeline
```bash
python ai_harness/run_pipeline.py
```
Dos gates internos: import headless (errores de parseo/sintaxis) y GUT (asserts).

## FASE 3 — Loop de reparación
```
error → leer línea exacta → clasificar:
  bug productivo confirmado por test/compilación → corregir (fix mínimo)
  test refleja cambio de diseño en docs/        → DETENER y preguntar
  error de entorno (Godot ausente, PATH)        → reportar, no corregir
→ re-correr pipeline → contador +1 → 3 intentos = BLOQUEANTE
```
Documentar cada fix: archivo, error, cambio, resultado.

## FASE 4 — Reporte
```
REPORTE QUALITY RUNNER
Feature: [nombre]
Compilación headless: ✅/❌
Tests GUT: N passed / M failed
Correcciones aplicadas: [lista o ninguna]
BLOQUEANTES: [lista o ninguno]
tech_debt.md actualizado: ✅/❌
VEREDICTO: ✅ LISTO | ❌ BLOQUEADO
```
Veredicto BLOQUEADO → no commit, listar qué necesita humano.
