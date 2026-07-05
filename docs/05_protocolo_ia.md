# Protocolo IA / Automatización

## ai_harness (Python + Godot headless)
- `ai_harness/run_pipeline.py`: compila headless + corre tests GUT.
- Si devuelve error de compilación: prioridad absoluta = parsear línea exacta y corregir sintaxis antes de escribir código nuevo.

## TDD asistido
- Cada componente/habilidad nueva (ej. cálculo de radio de luz) lleva su test GUT en `game/tests/unit/` en el mismo turno.
- Sin aserciones lógicas = código rechazado.

## Multi-LLM (Claude / Gemini / Ollama / Codex)
- Fin de sesión exitosa → actualizar `.claude/memories/tech_debt.md`: componentes tocados, señales nuevas de EventBus, dependencias nuevas.
- `docs/` es solo-lectura para agentes; lo edita el humano (Obsidian).

## Flujo diario
1. Pulir diseño en chat → actualizar notas Obsidian (`docs/`).
2. Agente lee `docs/` y codifica en `game/`.
3. `ai_harness` valida headless con tests.
