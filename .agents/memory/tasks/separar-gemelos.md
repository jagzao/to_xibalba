# Spec: Separar Gemelos (separar-gemelos)

Fuente de diseño: `docs/02_personajes.md`. Asunciones aprobadas 2026-07-07 con `0` (todas aceptadas sin refinar).

## 1. Descripción
`CharacterBase.tscn` actualmente comparte melee+ranged entre ambos gemelos. Esta spec separa a Hunahpú e Ixbalanqué como escenas propias (`Hunahpu.tscn` / `Ixbalanque.tscn`) que heredan movimiento/FSM de `CharacterBase` e inyectan su `PlayerAbility` correspondiente. `CharacterBase` queda limpio de componentes de ataque específicos.

## 2. Componentes/estados afectados
- **PlayerAbility** (nuevo virtual, `game/src/core/player_ability.gd`): `class_name PlayerAbility extends Node`, export `serenity_cost`, método `execute_ability(player: CharacterBody2D, event_bus: Node) -> void`. Sin escena.
- **HunahpuAbility** (nuevo, `game/src/entities/abilities/hunahpu_ability.gd`): hereda `PlayerAbility`. Conecta tecla `ability` (K) al modo apuntado de cerbatana (`AimState`) y maneja `Destello de Resplandor` (stub v1: señal placeholder).
- **IxbalanqueAbility** (nuevo, `game/src/entities/abilities/ixbalanque_ability.gd`): hereda `PlayerAbility`. Conecta tecla `ability` al `DashState` y maneja ventana de absorción post-dash (reusa `MeleeAttackComponent`) + `Manto de Jaguar` (stub v1: señal placeholder).
- **AbilityResource** (nuevo, `game/src/core/ability_resource.gd`): cost, cooldown, flags para extender por gemelo.
- **Hunahpu.tscn** (nuevo, `game/src/entities/Hunahpu.tscn`): hereda/instancia `CharacterBase.tscn`, inyecta `HunahpuAbility` + `RangedAttackComponent`.
- **Ixbalanque.tscn** (nuevo, `game/src/entities/Ixbalanque.tscn`): hereda/instancia `CharacterBase.tscn`, inyecta `IxbalanqueAbility` + `MeleeAttackComponent`.
- **CharacterBase**: eliminar `MeleeAttackComponent` y `RangedAttackComponent` del tscn; mover hitbox/hurtbox lógica de ataque a abilities. Agregar input genérico `ability_pressed` (tecla K, acción `ability` en input map).

## 3. Flujo
```
[CharacterBase.tscn]  -> movimiento, FSM, componentes de vida/luz
   ├── [HunahpuAbility] -> K = apuntar cerbatana; serenidad >= 15 → AimState
   └── [RangedAttackComponent]

[CharacterBase.tscn]
   ├── [IxbalanqueAbility] -> K = dash; post-dash melee absorbe +2 serenidad
   └── [MeleeAttackComponent]
```
Ambos gemelos comparten `Idle/Move/Jump/Fall/Dash/Panic/Stunned/Meditating`. `AimState` solo en Hunahpú.

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| Cerbatana cost | 15.0 | RangedStatsResource |
| Dash i-frames | 12 | MovementStatsResource |
| Absorción post-dash | +2.0 Serenidad en 2.0 s | CombatStatsResource |
| Destello cooldown | 8.0 s (stub) | HunahpuAbilityResource |
| Manto de Jaguar cost | 10.0 (stub) | IxbalanqueAbilityResource |

## 5. Señales EventBus
Usadas: `serenity_changed`, `blood_circle_changed`, `skulls_changed`, `panic_entered/panic_exited`, `artifact_read_started/completed`. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. `Hunahpu.tscn` instancia sin crash; tiene `RangedAttackComponent` y no `MeleeAttackComponent`.
2. `Ixbalanque.tscn` instancia sin crash; tiene `MeleeAttackComponent` y no `RangedAttackComponent`.
3. `PlayerAbility` virtual ejecuta `execute_ability` y consume `serenity_cost`.
4. Hunahpú con serenidad >= 15 y tecla K entra en `AimState`.
5. Hunahpú con serenidad < 15 y tecla K no entra en `AimState`.
6. Ixbalanqué presiona K en suelo → entra `DashState`; hurtbox off durante 12 frames.
7. Ixbalanqué golpe melee dentro de 2 s post-dash → Serenidad +2.
8. `CharacterBase.tscn` no tiene `RangedAttackComponent` ni `MeleeAttackComponent` directos.
9. Ambos gemelos comparten `data`, `serenity`, `blood_circle`, `skulls`.

## 7. Casos borde
- Gemelo sin `PlayerAbility` asignado → `ability_pressed` es no-op.
- `ability_pressed` en aire, stun, pánico o meditación → bloqueado por FSM.
- `AimState` solo puede entrar desde `Idle`/`Move`/`Panic` en suelo (mismo requisito que antes).
- `DashState` en Ixbalanqué permite aire (aunque el diseño dice dash terrestre/aéreo); CharacterBase actual ya lo permite.
