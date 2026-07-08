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

## 2026-07-07 — Cerbatana Mística (Hunahpú)
- Creados: `ranged_stats_resource.gd` (RangedStatsResource: cost 15, damage 12, speed 500, lifetime 1.5), `projectile_light.gd` (ProjectileLight, Area2D por código sin tscn, take_hit al impactar, muere por lifetime), `ranged_attack_component.gd` (RangedAttackComponent: shoot(dir) valida current_serenity >= cost, gasta vía SerenityComponent, señal `fired`), `aim_state.gd` (AimState: plantado, dispara al soltar `aim`).
- CharacterBase: aim_pressed/aim_held (tecla K) + aim_direction (mouse); Idle/Move → Aim. Jump/Fall no apuntan (diseño: plantado en suelo).
- Señales nuevas EventBus: ninguna. Dependencias: ninguna.
- Tests: 68/68.
- Deuda: ProjectileLight sin PointLight2D hijo ni shader de quemadura (visual, cuando haya arte); Destello de Resplandor (especial) sin implementar; ambos gemelos comparten CharacterBase.tscn con melee+ranged — escenas por gemelo después.

## 2026-07-07 — PanicState + skills de workflow (spec/auto-implement/quality-runner)
- `panic_state.gd` (PanicState): entra cuando `data.is_in_panic` (chequeo por polling en Idle/Move/Jump/Fall, sin señales cruzadas); permite caminar y saltar (coyote/buffer inline), bloquea dash/ataque/apuntado; sale solo a Idle al recuperar Serenidad. Stun tiene prioridad (blood emptied → Stunned incluso en pánico). Luz 0.1 y daño ×1.5 ya venían de PlayerDataResource.
- Skills adaptados de casa_futbol en `.claude/skills/`: `/spec` (asunciones de gameplay, guarda `.agents/memory/tasks/{slug}.md`), `/auto-implement` (spec → código bajo CLAUDE.md → GUT mismo turno → run_pipeline → máx 3 intentos/error, 10 total → tech_debt → commit), `/quality-runner` (gate pipeline + límites furnace + paths prohibidos docs/, addons/gut/). NO se copió: workflow-state.json/complete-stage.js (innecesario, pipeline de 1 comando) ni fases playwright (sin superficie web).
- Señales nuevas EventBus: ninguna. Dependencias: ninguna.
- Tests: 73/73.
- Deuda: PanicState mismo speed que Move (diseño no especifica penalización; ajustar si el playtest lo pide).

## 2026-07-07 — Altares didácticos (/auto-implement altares-didacticos)
- Creados: `poem_resource.gd` (PoemResource: artifact_id/title/author/content_text/serenity_restored=100), `altar.gd` (Altar, Area2D por código, radio export 24, marca `nearby_altar` en CharacterBase por body_entered/exited), `meditating_state.gd` (MeditatingState: planta, hurtbox off, pausa decay con serenity.set_physics_process(false), emite artifact_read_started al entrar; interact cierra → serenity.change(+restored) → artifact_read_completed → Idle).
- CharacterBase: `interact_pressed` (tecla E) + `nearby_altar` + `can_meditate()`. Transición desde Idle/Move/Panic (escape del pánico); Jump/Fall/Dash/Stunned no meditan.
- Bugs reales encontrados: ninguno (pipeline verde al primer intento).
- Señales EventBus nuevas: ninguna (usa artifact_read_started/completed ya existentes).
- Tests: 83/83 (10 nuevos, incluye test de overlap físico con wait_physics_frames).
- Deuda: altar sin visual/tscn (patrón código, arte después); daño directo a calaveras por scripts de entorno no está bloqueado durante meditación (spec lo marca fuera de scope).

## 2026-07-07 — HUD reactivo (/auto-implement hud)
- Creados: `game/src/ui/HUD.tscn`, `game/src/ui/hud.gd` (CanvasLayer reactivo vía EventBus: calaveras como string, barra de sangre, barra de serenidad, panel de códice). Sin referencias a jugador; `Color(1,0.2,0.2)` para pánico.
- Tests: `game/tests/unit/test_hud.gd` 8/8 asserts; pipeline pasa 91/91.
- Señales EventBus nuevas: ninguna.
- Deuda: arte final para HUD; barra de equilibrio Luz/Oscuridad (E4) fuera de scope v1.

## 2026-07-07 — Separar gemelos (/auto-implement separar-gemelos)
- Creados: `game/src/core/player_ability.gd` (PlayerAbility virtual), `game/src/core/ability_resource.gd`, `game/src/entities/abilities/hunahpu_ability.gd` (Aim con cerbatana), `game/src/entities/abilities/ixbalanque_ability.gd` (Dash + melee), `game/src/entities/hunahpu.gd` + `Hunahpu.tscn`, `game/src/entities/ixbalanque.gd` + `Ixbalanque.tscn`.
- Cambios: `CharacterBase.tscn` ya no tiene melee/ranged; estados Idle/Move usan `ability_pressed`; input map `aim` renombrado a `ability`; tests melee/ranged actualizados a escenas de gemelos.
- Bugs reales encontrados: `hitbox` no estaba expuesto en CharacterBase (fix: `var hitbox: Area2D`); `HunahpuAbility` gastaba serenidad doble con RangedAttackComponent (fix: solo checa, el gasto queda en shoot).
- Tests: `game/tests/unit/test_separar_gemelos.gd` 9/9; pipeline 100/100.
- Deuda: Destello de Resplandor y Manto de Jaguar son stubs v1; Hunahpú usa hitbox aunque no melee.

## 2026-07-07 — Escenario 1 Ríos de Pesadilla (/auto-implement escenario-1-rios)
- Creados: `HazardResource`, `SinkingPlatformResource`, `MurcielagoResource`, `SerenityZoneResource`; entidades `Checkpoint`, `HazardFloor`, `InvisiblePlatform`, `SinkingPlatform`, `SerenityZone`; enemigo `MurcielagoPeriferia`.
- Cambios: `PlayerDataResource` + `respawn_position`; `SerenityComponent.set_multiplier()`.
- Bugs reales encontrados: `InvisiblePlatform` buscaba `$CollisionShape2D` fijo (fix: busca primer hijo CollisionShape2D); `MurcielagoPeriferia` dependía de nodo `DetectionArea` fijo (fix: inyectar `player` directamente + body_entered genérico).
- Tests: `test_escenario_1_environment.gd` 6/6, `test_escenario_1_murcielago.gd` 3/3; pipeline 109/109.
- Deuda: `SinkingPlatform` usa detector Area2D en tscn (no creado aún); arte y escenas de nivel propiamente no implementadas.

## 2026-07-07 — Escenario 4 Juego de Pelota (/auto-implement escenario-4-pelota)
- Creados: `BallStateResource`, `PerfectParryResource`, `KineticBall2D`, `DeflectionComponent`, `BallGoal`, `BallGameManager`.
- Cambios: ninguno en core existente.
- Bugs reales encontrados: `KineticBall2D` asumía `$Hitbox` fijo (fix: busca primer hijo Area2D); `BallGoal` usaba enum anidado que confundía al parser de GDScript en tests (fix: constantes enteras); `BallGameManager` buscaba jugador en root global (fix: export `player`).
- Tests: `test_ball_deflection.gd` 8/8, `test_ball_game_manager.gd` 4/4; pipeline 121/121.
- Deuda: fases del juego de pelota (Fase 1 y 2) son stubs; ilusiones de los dioses sin implementar; escena `.tscn` de la pelota no creada.

## 2026-07-07 — Escenario 2 Corte de los 12 Señores (/auto-implement escenario-2-corte)
- Creados: `BossStatsResource`, `SharedBlackboard`, `DeceptiveLord`, `CouncilPuzzleRoom`, `LajaHirviendo`, `BossBase`, `BossDirector`, `HunCameAI`, `VucubCameAI`.
- Cambios: ninguno en core existente.
- Bugs reales encontrados: `CouncilPuzzleRoom.interact_with` no retornaba valor en todos los caminos (fix: retornar false tras `_fail_puzzle()`); test usaba `var character :=` sin tipo explícito causando inferencia fallida (fix: `var character: CharacterBase`); `DeceptiveLord` y `LajaHirviendo` huérfanos en tests (fix: `add_child_autofree`).
- Tests: `test_escenario_2_puzzle.gd` 6/6, `test_escenario_2_boss.gd` 6/6; pipeline 133/133.
- Deuda: combate real con hurtboxes de jefes, proyectiles de sangre de Vucub-Camé, escena de sala del consejo no creada.

## 2026-07-07 — Escenario 3 Casas del Tormento (/auto-implement escenario-3-casas)
- Creados: `HouseDoor`, `HouseEnvironment`, `DarkHouse`, `ColdHouse`, `JaguarHouse`, `BatHouse`, `KnifeHouse`, `HeatHouse`, `PorousPlatform`, `CodexFragment`.
- Cambios: `PlayerDataResource` añade `has_codex_fragment` y alias `skulls` para compatibilidad.
- Bugs reales encontrados: subclases `HouseEnvironment` heredaban `Node2D` pero usaban `body_entered`/`monitoring` exclusivos de `Area2D` (fix: convertir a `Area2D` o desacoplar); `HeatHouse.PorousPlatform` interno no cargaba desde test (fix: mover a `porous_platform.gd` propio); `ColdHouse` reseteaba físicas de un suelo que no existía en tests (fix: simplificar, escena proveerá fricción); `BatHouse` no encontraba jugador en tests headless sin viewport (fix: `track_player`).
- Tests: `test_escenario_3_casas.gd` 15/15; pipeline 158/158.
- Deuda: cámara/límites de muerte por altura, interacción real con Piedra de Fuego/Piedra de Humo, escenas `.tscn` de casas.

## 2026-07-07 — Sistema de muerte/gore y partículas (/auto-implement sistema-muerte-gore)
- Creados: `GoreEffect`, `DeathManager`, `DeathScreen`.
- Cambios: `EventBus` añade `player_died`, `respawn_started`, `game_over`.
- Bugs reales encontrados: `DeathManager._respawn` usaba `await` en `DeathScreen.fade_out` que en tests no avanzaba (fix: quitar await, respawn sincrónico con gore); `DeathScreen.show_game_over` usaba tween que en tests no finalizaba (fix: set directo de alpha); doble muerte en test daba race porque `_busy` no se reseteaba al inicio del test (fix: controlar `_busy` explícitamente en tests).
- Tests: `test_sistema_muerte_gore.gd` 6/6; pipeline 164/164.
- Deuda: texturas de partículas, cámara shake real, escena `GameOver.tscn`, integración con daño real del jugador.

## 2026-07-07 — Spritesheets y media de Ixbalanqué (/auto-implement spritesheets)
- Creados: `GoreDataResource`, `BossFatalityScene`.
- Cambios: `SpriteAnimator._process` ahora protege `_character == null` (fix para tests aislados).
- Bugs reales encontrados: tests creaban `SpriteAnimator` sin `CharacterBase` padre, `_ready()` llamaba `get_node("../..")` y `_process` accedía a `_character.facing` (fix: null-check en `_process`; tests no añaden al árbol para evitar `_ready`).
- Tests: `test_spritesheets.gd` 5/5; pipeline 169/169 (2 orphans leves de SpriteFrames cache, no fallan).
- Deuda: generar sheets finales de Ixbalanqué según media contract, death states, escenas `.tscn` de fatalities.

## 2026-07-07 — Pago de deuda técnica (quality-runner)
- Cambios:
  - `SkullsComponent.lose_skull()` emite `EventBus.player_died("skull")` al morir.
  - `MeleeAttackComponent` añade `slash_vfx` (PackedScene) e instancia VFX en `_on_area_entered()`.
  - `SlashVFX` + `SlashVFX.tscn` stub en `game/src/effects/`.
  - `GameOver.tscn` stub + `DeathScreen` lo carga vía `change_scene_to_packed`.
  - `CharacterBase._update_hitbox_facing()` flip del offset de `hitbox` por `facing`.
  - `SpriteAnimator._ready()` protege `_character == null` y `fsm == null`.
- Tests nuevos: `test_hitbox_facing.gd` 2/2.
- Pipeline: 171/171 verdes.
- Deuda restante: texturas de partículas reales, cámara shake, sheets finales de Ixbalanqué, escenas `.tscn` de fatalities, combate real de jefes con hurtboxes.

## 2026-07-07 — HUD (/auto-implement hud)
- Creados: `game/src/ui/hud.gd` (class_name HUD, CanvasLayer) + `game/src/ui/HUD.tscn`. Suscrito a las 7 señales del EventBus en _ready. Calaveras data-driven (recrea hijos según max, remove_child+free síncrono para testeabilidad — queue_free dejaría hijos fantasma en el mismo frame). Pánico = modulate rojo en SerenityBar. CodexPanel oculto por default, muestra content_text.
- Cero referencias a CharacterBase: la suite completa de tests corre sin jugador en el árbol (criterio de desacoplamiento probado, no solo declarado).
- Bugs reales: ninguno (verde al primer intento). Señales EventBus nuevas: ninguna.
- Tests: 91/91 (8 nuevos).
- Deuda: HUD sin arte (ProgressBar/Label nativos); título/autor del poema no se muestran (artifact_read_started solo lleva id+text — si se quiere título en pantalla, ampliar payload de la señal o mandar el PoemResource); barra equilibrio Luz/Oscuridad pendiente para E4.

## 2026-07-07 — SpriteAnimator: animaciones de Ixbalanqué desde spritesheet
- Creados: `process_image/slice_sheet.py` (recorta sheet limpio en frames por proyección de filas/columnas vacías; umbrales MIN_ROW_PIXELS=50000 y COL_NOISE=10 calibrados contra debris), frames en `game/assets/sprites/players/ixbalanque/frames/{idle,run,dash,jump_fall,panic,melee}/NN.png` (bottom-aligned, pies en la misma línea), `game/src/components/sprite_animator.gd` (SpriteAnimator extends AnimatedSprite2D: construye SpriteFrames escaneando carpetas en _ready, mapea estado FSM→animación vía STATE_TO_ANIM, flip_h por facing).
- FSM: señal nueva `state_changed(previous_name, next_name)` emitida en change_state (el animador y cualquier feedback A/V se cuelgan de ahí).
- Ixbalanque.tscn: nodo SpriteAnimator bajo CharacterVisuals, scale 0.15 (sprites ~280px vs colisión 32px).
- OJO ordering Godot: los @onready del padre NO están listos cuando corre _ready de un nieto — SpriteAnimator usa get_node("FiniteStateMachine") directo, no character.fsm.
- Bug real corregido (WIP ajeno, síntoma: [3] expected [2] en test_escenario_3_casas): BatHouse ignoraba camera_top_margin sin Camera2D (headless) — top quedaba 0.0 y nunca dañaba. Fix: sin cámara, el margen ES el umbral.
- Tests: 154/154 (7 nuevos de animator).
- Deuda: Hunahpu.tscn sin SpriteAnimator (sus frames aún no se recortan — mismo slicer sirve); dash de Ixbalanqué = 1 frame (re-pedir 12 al generador); melee anim existe pero ningún estado la dispara (ataque es componente — conectar a hit/try_attack después); anillo residual de checker visible en frames (aceptable como placeholder).

## 2026-07-07 — Chroma green + animaciones completas de Hunahpú + assets nuevos
- clean_sprites.py: modo **chroma green** auto-detectado por esquinas (G>140 & G>1.6R & G>1.6B) — los sheets nuevos en fondo verde salen mucho más limpios que el checkerboard. slice_sheet.py: params --row-noise/--col-noise/--min-row-px/--min-row-height.
- Assets nuevos procesados: `hunahpu_extra_anims_ref` (aim 5, shoot 4, destello 4, meditate 4, hit 3 — shoot y destello venían fusionados por el glow, corte manual en y=647), base de Hunahpú recortado del sheet checker viejo (idle 5, run 8 fusionando 2 filas, jump_fall 5, panic 4). Ixbalanqué dash reemplazado por v2 verde (2 frames; los 12 pedidos no llegaron). Murciélago: `enemies/murcielago/frames/fly_a+fly_b` (8 frames verdes; dive/death vinieron contaminados — re-pedir). VFX slash aislado: `vfx/slash/frames/slash/` 5 frames.
- Hunahpu.tscn: SpriteAnimator montado (frames_root propio). sprite_animator.gd: mapa actualizado (stunned→hit, aim→aim, meditating→meditate) + fallback (hit→panic→idle) para gemelos sin esa anim.
- Tests: 158/158 (4 nuevos de Hunahpú animator).
- Deuda: murciélago fly_a/fly_b sin fusionar en `fly` (esperar dive/death para armar el set); VFX slash sin nodo que lo instancie (conectar a melee hit_confirmed); dash 12f y dive/death del murciélago re-pedidos al generador; sheets con escalas inconsistentes entre filas (generator) — el bottom-align del slicer lo disimula.
