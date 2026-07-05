# XIBALBÁ — Reglas de código (INMUTABLES)

Fuente de verdad del diseño: `docs/*.md`. No contradecir esos archivos; si hay conflicto, preguntar.

## Restricciones estrictas
1. Composición sobre herencia. Prohibida herencia profunda. Componentes = nodos hijos reutilizables.
2. UI desacoplada: UI solo escucha `EventBus` (Autoload). Prohibido `get_node("/root/Player")` o refs directas al jugador desde UI.
3. Tipado estático explícito en todo GDScript (`: float`, `: int`, `-> void`).
4. FSM estricta: estados = nodos que heredan de `State`. Prohibidos booleanos de estado (`is_jumping`, `is_attacking`, `is_panicking`) en el script del jugador.
5. Datos estáticos = `Resource` con `class_name` (daño, velocidades, textos de poemas). Prohibido hardcodear valores de balance en lógica.
6. TDD en pareja: cada componente/habilidad nueva lleva su test GUT en `game/tests/unit/` en el mismo turno. Sin test = no se acepta.

## Protocolo de errores (ai_harness)
Si `ai_harness/run_pipeline.py` devuelve error de compilación headless de Godot: prioridad absoluta = parsear línea exacta del fallo y corregir sintaxis ANTES de escribir funciones nuevas.

## Memoria transversal (multi-LLM)
Al terminar cada sesión/refactor exitoso: actualizar `.claude/memories/tech_debt.md` con componentes modificados, señales nuevas en EventBus, dependencias nuevas.

## Estructura
- `docs/` — diseño (inmutable, editado solo por el humano vía Obsidian)
- `game/` — proyecto Godot 4
- `game/tests/unit/` — tests GUT
- `ai_harness/` — pipeline Python de validación headless
- `.agents/` — instrucciones para enjambre de agentes
