# Tech Debt / Bitácora transversal

Formato por sesión:

## [FECHA] — [resumen corto]
- Componentes modificados:
- Señales agregadas a EventBus:
- Dependencias nuevas:
- Deuda pendiente:

---

## 2026-07-05 — Fundación: EventBus + PlayerDataResource + pipeline
- Componentes creados: `game/src/core/event_bus.gd` (autoload EventBus), `game/src/core/player_data_resource.gd` (class_name PlayerDataResource), `game/project.godot`, `ai_harness/run_pipeline.py`, `game/.gutconfig.json`.
- Señales en EventBus: serenity_changed, blood_circle_changed, skulls_changed, panic_entered, panic_exited, artifact_read_started, artifact_read_completed, balance_changed.
- Dependencias: GUT 9.6.0 vendorizado en `game/addons/gut/`. Godot 4.7 stable instalado vía winget (exe en `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine*`; el pipeline lo autodetecta, o define GODOT_BIN).
- Tests: 12/12 verdes (`python ai_harness/run_pipeline.py`).
- Deuda pendiente: PlayerDataResource no emite señales al EventBus por sí solo (es Resource puro); el componente de jugador que lo envuelva debe emitir serenity_changed/panic_entered etc. Falta CharacterBase.tscn + FSM.

## 2026-07-06 — FSM + SerenityComponent
- Componentes creados: `game/src/core/state.gd` (class_name State, señal `finished`), `game/src/core/finite_state_machine.gd` (class_name FiniteStateMachine, hijos State, `change_state()` case-insensitive), `game/src/components/serenity_component.gd` (class_name SerenityComponent: decay −1.0/s, `environment_multiplier` para zonas, emite serenity_changed/panic_entered/panic_exited).
- Señales nuevas en EventBus: ninguna.
- Dependencias nuevas: ninguna.
- Tests: 24/24 verdes.
- Deuda pendiente: `decay_rate` es @export en SerenityComponent (no Resource dedicado); falta CharacterBase.tscn, BloodCircleComponent (stun 1.5 s), SkullsComponent, y componente de luz (PointLight2D ← get_light_radius).
