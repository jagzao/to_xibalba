# Spec: Escenario 2 — Corte de los 12 Señores (escenario-2-corte)

Fuente de diseño: `docs/03_niveles.md` §2. Asunciones aprobadas por defecto (autonomía total).

## 1. Descripción
Corte de los 12 Señores de Xibalbá: puzzle de maniquíes, trampa de la Laja Hirviente y combate doble contra Hun-Camé y Vucub-Camé con Attack Token Pattern y Fase de Desesperación.

## 2. Componentes/estados afectados
- **DeceptiveLord** (nuevo, `game/src/entities/enemies/deceptive_lord.gd`): `Area2D` o `Node2D` con enum `{ REAL, MANNEQUIN }`. Revelado con Serenidad > 75% (muestra veta de madera). Animación de parpadeo cada 10 s para maniquíes.
- **CouncilPuzzleRoom** (nuevo, `game/src/entities/environment/council_puzzle_room.gd`): gestiona los 12 señores. Recibe interacciones/ataques del jugador, valida si son reales. Éxito = abre paso al boss. Error = -50% Serenidad.
- **LajaHirviendo** (nuevo, `game/src/entities/environment/laja_hirviendo.gd`): altar falso. Interactuar antes de completar puzzle → vacía Círculo de Sangre (100.0 daño) y fuerza StunnedState.
- **BossDirector** (nuevo, `game/src/entities/enemies/boss_director.gd`): sincroniza combate doble.
- **HunCameAI** / **VucubCameAI** (nuevo, `game/src/entities/enemies/hun_came_ai.gd`, `vucub_came_ai.gd`): hermanan con `BossDirector` vía `SharedBlackboard`.
- **SharedBlackboard** (nuevo, `game/src/core/shared_blackboard.gd`): Resource con `attack_token: String`, `player_position: Vector2`, `desperation_active: bool`.
- **BossStatsResource** (nuevo, `game/src/core/boss_stats_resource.gd`): vida, daño, token swap interval 15 s, desperation threshold.

## 3. Flujo
```
[Puzzle]
Jugador ataca/saluda señor → CouncilPuzzleRoom.validar(tipo)
  REAL y líder → éxito
  MANNEQUIN → -50% Serenidad
  LajaHirviendo interactuado antes → blood_circle vacío + Stunned

[Boss]
BossDirector.start_fight()
  ├── token = "HunCame" (melee agresivo)
  └── VucubCame (ranged sangre)
Cada 15 s → swap token
Al morir uno → desperation: luz a mitad, daño físico ignora blood_circle, tamaño aumenta
```

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| Umbral revelador Serenidad | 0.75 | DeceptiveLord (export) |
| Penalización error puzzle | -50% Serenidad | CouncilPuzzleRoom |
| Daño Laja Hirviendo | 100.0 blood circle | LajaHirviendo |
| Token swap interval | 15.0 s | BossStatsResource |
| Daño melee Hun-Camé | 20.0 blood circle (x1.5 pánico) | BossStatsResource |
| Daño ranged Vucub-Camé | -15.0 Serenidad | BossStatsResource |
| Threshold desesperación | un jefe muere | BossDirector |
| Multiplicador daño desesperación a calaveras | infinito (ignora blood) | BossDirector |

## 5. Señales EventBus
Usadas: `serenity_changed`, `blood_circle_changed`, `skulls_changed`, `panic_entered`. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. `DeceptiveLord` con Serenidad 80% se revela como maniquí (visible veta).
2. `DeceptiveLord` con Serenidad 50% no se revela.
3. `CouncilPuzzleRoom`: atacar dos líderes reales → puzzle completado; atacar maniquí → -50% Serenidad.
4. `LajaHirviendo`: interactuar antes de completar puzzle → Círculo de Sangre en 0.
5. `BossDirector`: inicia con token en Hun-Camé.
6. `BossDirector`: swap token a Vucub-Camé tras 15 s.
7. `HunCameAI` en posesión de token ataca melee; sin token patrulla/defiende.
8. Fase de desesperación: ataques físicos ignoran blood_circle (daño directo a calaveras).
9. Morir un jefe activa desesperación en el sobreviviente.

## 7. Casos borde
- Puzzle ya completado → LajaHirviendo inofensiva.
- Múltiples errores seguidos → Serenidad clamp a 0, pánico.
- Jugador ataca señor real no-líder → contabilizado como error.
- Ambos jefes mueren simultáneamente → victoria, no desesperación.
