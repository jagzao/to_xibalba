# Spec: Escenario 4 — Juego de Pelota Final (escenario-4-pelota)

Fuente de diseño: `docs/06_juego_pelota.md`. Asunciones aprobadas por defecto (autonomía total).

## 1. Descripción
Clímax del Popol Vuh: enfrentamiento deportivo/místico contra Hun-Camé y Vucub-Camé. No es hack'n'slash: solo redirigir la pelota. Gestión de Serenidad, plataformas y destreza.

## 2. Componentes/estados afectados
- **BallGameManager** (nuevo, `game/src/core/ball_game_manager.gd`): Autoload/singleton que coordina la partida. Sigue `balance` (0=Luz, 100=Oscuridad), fases, spawn de pelota, puntuación de paredes.
- **KineticBall2D** (nuevo, `game/src/entities/kinetic_ball_2d.gd`): `RigidBody2D`. `bounce = 1.0`, `friction = 0.0`. Estados según último golpeador: `LIGHT` (gemelo) / `DARKNESS` (Señores).
- **BallStateResource** (nuevo, `game/src/core/ball_state_resource.gd`): `enum { LIGHT, DARKNESS }`, multiplicadores de daño/velocidad.
- **DeflectionComponent** (nuevo, `game/src/components/deflection_component.gd`): adjunto a cada gemelo. Detecta pelota en rango, calcula ventana de parry, redirige pelota y aplica Serenidad/velocidad.
- **PerfectParryResource** (nuevo, `game/src/core/perfect_parry_resource.gd`): ventana 0.1 s, velocidad ×2, serenity +20.
- **BallGoal** (nuevo, `game/src/entities/environment/ball_goal.gd`): Area2D en fondo de dioses/jugador. Golpear pared de dioses → balance hacia Luz; golpear fondo jugador → balance hacia Oscuridad.

## 3. Flujo
```
[BallGameManager.start_game()] → spawnea KineticBall2D en centro
[Jugador ataca pelota] → DeflectionComponent redirige hacia dioses
[Señores devuelven] → KineticBall cambia a DARKNESS; rozar = -25% Círculo de Sangre
[Perfect Parry] → velocidad ×2, Serenidad +20
[Pelota toca BallGoal dioses] → balance -= 10 (hacia Luz)
[Pelota toca BallGoal jugador] → balance += 10 (hacia Oscuridad)
[balance == 100] → -1 Calavera instantánea
```

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| Velocidad base pelota | 250 px/s | BallStateResource |
| Velocidad Luz | ×1.2 | BallStateResource |
| Velocidad Oscuridad | ×1.0 | BallStateResource |
| Daño rozar Oscuridad | 25.0 Círculo de Sangre | BallStateResource |
| Rango de desvío | 24 px | DeflectionComponent |
| Ventana Perfect Parry | 0.1 s | PerfectParryResource |
| Bonus Perfect Parry | +20 Serenidad, ×2 velocidad | PerfectParryResource |
| Cambio balance por gol | ±10 | BallGameManager |
| Extremo Oscuridad | -1 Calavera | BallGameManager |

## 5. Señales EventBus
Usadas: `serenity_changed`, `blood_circle_changed`, `skulls_changed`, `balance_changed` (ya existe). Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. `KineticBall2D` spawnea con estado LIGHT/DARKNESS según último golpeador.
2. `KineticBall2D` rebote elástico (velocidad conserva magnitud aproximada).
3. `DeflectionComponent.try_deflect(ball)` redirige la pelota y gasta/gana serenidad según parry.
4. Perfect Parry dentro de ventana → `+20` Serenidad y velocidad ×2.
5. Parry normal fuera de ventana → solo redirige, no bonus.
6. Pelota en estado DARKNESS rozando al jugador → `-25%` Círculo de Sangre.
7. `BallGoal` en fondo de dioses → balance hacia Luz; en fondo jugador → balance hacia Oscuridad.
8. `BallGameManager` reinicia pelota al centro tras gol.
9. Extremo Oscuridad (`balance == 100`) → `-1` Calavera.

## 7. Casos borde
- Pelota quieta: desvío le da velocidad mínima.
- Múltiples deflections seguidos: solo cuenta el último ataque.
- Jugador sin Serenidad: perfect parry imposible (no hay +20).
- Pelota DARKNESS toca dioses: igual cuenta como punto para Luz (el rebote final no importa).
