# Spec: Sistema de Altares Didácticos (altares-didacticos)

Fuente de diseño: `docs/01_arquitectura.md` §3 DidacticManager. Asunciones aprobadas 2026-07-07 (todas aceptadas sin refinar).

## 1. Descripción
Altares (Xoloitzcuintle, Jaguar, Colibrí) donde el gemelo medita leyendo poemas prehispánicos (Nezahualcóyotl). Pausa Segura por Software: el mundo sigue corriendo; el jugador queda plantado, inmune y sin inputs de combate. Al cerrar la lectura: Serenidad → 100%.

## 2. Componentes/estados afectados
- **PoemResource** (nuevo, `game/src/core/poem_resource.gd`): `artifact_id: String`, `title: String`, `author: String` (default "Nezahualcóyotl"), `content_text: String`, `serenity_restored: float = 100.0`.
- **Altar** (nuevo, `game/src/entities/altar.gd`, Area2D por código sin tscn — patrón ProjectileLight): `@export var poem: PoemResource`. Detecta al jugador en rango (body_entered/exited sobre CharacterBody2D).
- **MeditatingState** (nuevo, `game/src/entities/states/meditating_state.gd`, hijo de FSM en CharacterBase.tscn): al entrar apaga hurtbox y planta (velocity = 0); al salir restaura hurtbox.
- **CharacterBase**: `interact_pressed` (tecla E, acción `interact` en input map) + referencia al altar en rango (`nearby_altar`, la setea el Altar). Idle/Move/**Panic** transicionan a Meditating con interact_pressed + altar en rango. Jump/Fall/Dash/Stunned NO (debe estar en piso).
- Prohibido: `get_tree().paused`, booleanos de estado, UI leyendo nodos.

## 3. Flujo
```
jugador en rango + interact → FSM → Meditating
  enter: velocity=0, hurtbox.monitoring=false,
         EventBus.artifact_read_started(poem.artifact_id, poem.content_text)
  (decay de serenidad pausado: serenity.set_physics_process(false) o guard)
interact de nuevo → serenity.change(+poem.serenity_restored) [clamp a max]
  EventBus.artifact_read_completed()
  exit: hurtbox.monitoring=true → Idle
```
Pánico: entrar a Meditating permitido; al cerrar, Serenidad 100% ⇒ sale de pánico naturalmente (panic_exited emitida por SerenityComponent).

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| serenity_restored | 100.0 (= full) | PoemResource |
| rango de altar | radio 24 px (CircleShape2D) | export en Altar |
| tiempo mínimo de lectura | 0 (cerrable inmediato) | — |
| reuso | ilimitado, sin cooldown | — |

## 5. Señales EventBus
Usadas (ya existen): `artifact_read_started(id, text)`, `artifact_read_completed()`, `serenity_changed`, `panic_exited`. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. Jugador en rango + interact → `fsm.current_state.name == "Meditating"`; fuera de rango + interact → sin cambio.
2. Al entrar: `hurtbox.monitoring == false` y `velocity == Vector2.ZERO`.
3. `artifact_read_started` emitida con `artifact_id` y `content_text` del PoemResource.
4. Durante meditación la Serenidad no decae (tick de física no resta).
5. Interact de nuevo → Serenidad == max, `artifact_read_completed` emitida, estado Idle, hurtbox restaurada.
6. Desde Panic con altar en rango: interact → Meditating; al cerrar → Idle (no Panic) y `panic_exited` emitida.
7. Desde Jump/Fall (aire): interact no hace nada.
8. Reuso: segunda lectura completa funciona igual.

## 7. Casos borde
- Interact sin altar en rango → no-op.
- Altar sin PoemResource asignado → no activa meditación (guard null, no crash).
- Daño durante meditación: imposible por hurtbox off; daño directo a calaveras por script de entorno NO está protegido (fuera de scope).
- Jugador sale del rango: imposible durante meditación (inputs de movimiento muertos).
- serenity_restored parcial (<100): clamp normal de change(), sigue emitiendo completed.
