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

## 2026-07-06 — CharacterBase.tscn + componentes de vida
- Componentes creados: `game/src/components/blood_circle_component.gd` (señal local `emptied`), `game/src/components/skulls_component.gd` (señal local `died`, guard anti re-muerte), `game/src/entities/states/stunned_state.gd` (StunnedState, 1.5 s exactos, vuelve a Idle), `game/src/entities/character_base.gd` + `CharacterBase.tscn` (CharacterBody2D con FSM[Idle,Stunned], 3 componentes, CharacterVisuals/PointLight2D; inyecta PlayerDataResource compartido; blood emptied → Stunned; Serenidad → texture_scale de la luz).
- Señales nuevas en EventBus: ninguna (emptied/died son locales de componente; UI usa blood_circle_changed/skulls_changed).
- Dependencias nuevas: ninguna.
- Tests: 39/39 verdes.
- Deuda pendiente: CharacterBase sin estados de movimiento (Move/Jump/Fall/Dash) ni coyote/buffering; PointLight2D sin textura asignada (radio se controla con texture_scale); `duration` del stun es @export, no Resource.

## 2026-07-06 — Movimiento: Idle/Move/Jump/Fall + coyote/buffer + docs Módulo 7
- Componentes creados: `game/src/core/movement_stats_resource.gd` (MovementStatsResource: speed, jump_velocity, gravity, coyote 0.1, buffer 0.1), estados `idle/move/jump/fall_state.gd` en `game/src/entities/states/`.
- Cambios: `State` ahora tiene `actor` (lo inyecta la FSM con su padre). `CharacterBase` centraliza input/coyote/buffer (`can_coyote_jump`, `has_buffered_jump`, `consume_jump`, `apply_gravity`) y controla el orden por frame: input → estado → move_and_slide (fsm.set_physics_process(false)). Input map agregado a project.godot (A/D/flechas + espacio). Estados NO llaman move_and_slide (puros, testeables).
- Docs: `docs/07_sistema_muerte.md` (GoreDataResource, muertes procedimentales, fatalities). Carpeta de assets: `game/assets/sprites/hunahpu/`.
- Señales nuevas en EventBus: ninguna. Dependencias nuevas: ninguna.
- Tests: 49/49 verdes.
- Deuda pendiente: falta DashState (12 i-frames Ixbalanqué), PanicState, animaciones (AnimatedSprite2D con spritesheets de Hunahpú cuando se suban), GoreDataResource sin implementar.

## 2026-07-06 — DashState + reorganización de assets + contrato Ixbalanqué
- Componentes creados: `game/src/entities/states/dash_state.gd` (DashState: 12 i-frames a 60 fps desde MovementStatsResource, hurtbox off, sin gravedad, usa facing si no hay input, exit abre `time_since_dash = 0`). Hurtbox (Area2D) agregada a CharacterBase.tscn. `dash_pressed`/`facing`/`time_since_dash` en CharacterBase. Acción `dash` (Shift) en input map. MovementStatsResource: +dash_speed(400), dash_iframes(12), frames_per_second(60).
- Assets: sheets de Hunahpú SON REFERENCIAS (alpha 255 plano, ajedrezado horneado, textos incluidos) → movidos a `game/assets/sprites/players/hunahpu/reference/`; concept art en `concept/hunahpu_selection_art.png`. Árbol creado: players/ixbalanque, enemies, bosses, sacred_creatures, artifacts, vfx, tilesets, ui, audio/{music,sfx}, fonts.
- Docs: `docs/08_ixbalanque_media.md` (contrato media Ixbalanqué + regla de calidad de spritesheets: alpha real, grid fijo 64/96, sin etiquetas).
- Señales nuevas EventBus: ninguna. Dependencias nuevas: ninguna.
- Tests: 55/55 verdes.
- Deuda pendiente: ventana de absorción (2 s) solo se trackea (`time_since_dash`), falta el componente de ataque melee que la consuma; sprites de producción de Hunahpú pendientes de re-export con alpha real; PanicState/MeditatingState/AttackState sin implementar.

## 2026-07-06 — Herramienta process_image (sprite-cleaner)
- Creado `process_image/`: clean_sprites.py (CLI: --input/--output/--scale/--remove-text/--text-top-ratio/--alpha-threshold/--debug), requirements.txt, README.
- Lógica: 2 tonos grises dominantes → máscara por RANGO de luminancia entre ambos (incluye transiciones) + conectividad al borde (protege grises internos) → alpha 0; texto = componentes opacos oscuros anchos/bajos; despeckle (<150 px grises); blur 1 px anti-halo.
- Validado contra los 4 sheets de Hunahpú: fondo y textos fuera, sprites/gore/partículas intactos. Limitación conocida: anillo de checker teñido por el glow queda pegado al sprite (gris contaminado deja de ser neutro); checker encerrado entre extremidades no se borra (por diseño).
- Dependencias nuevas: opencv-python 5.0 (pip local; OJO: la red del equipo intercepta SSL — instalar con --trusted-host pypi.org --trusted-host files.pythonhosted.org).
- Tests Godot: sin cambios (55/55).

## 2026-07-06 — MeleeAttackComponent + absorción post-dash + sheets limpios
- Componentes creados: `game/src/core/combat_stats_resource.gd` (CombatStatsResource: damage 10, cooldown 0.35, active_time 0.15, absorption_window 2.0, absorption_serenity 2.0), `game/src/components/melee_attack_component.gd` (MeleeAttackComponent: setup() inyecta character/serenity/hitbox, try_attack() con cooldown, hitbox activa active_time, golpe en ventana post-dash → serenity.change(+2), convención `take_hit(damage)` en el target, señal local `hit_confirmed`).
- CharacterBase: nodo Hitbox (Area2D monitoring=false, offset x+16) + MeleeAttackComponent en tscn; `attack_pressed` (tecla J) pollleado; estados Idle/Move/Jump/Fall disparan melee.try_attack() (Stunned/Dash no → inputs bloqueados por FSM).
- Assets: versiones `*_clean.png` generadas en `players/hunahpu/reference/` con process_image (--alpha-threshold 22).
- Convención nueva: los hurtbox de enemigos deben implementar `take_hit(damage: float)`.
- Señales nuevas EventBus: ninguna. Dependencias nuevas: ninguna.
- Tests: 62/62 verdes.
- Deuda pendiente: Hitbox no se voltea con `facing` (offset fijo +16 a la derecha) — corregir cuando exista flip de visuales; falta cerbatana Hunahpú (apuntado 360° + ProjectileLight), PanicState, MeditatingState, HUD.
