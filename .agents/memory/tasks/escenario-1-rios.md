# Spec: Escenario 1 — Ríos de Pesadilla (escenario-1-rios)

Fuente de diseño: `docs/03_niveles.md` §1. Asunciones aprobadas 2026-07-07 con `0` (todas aceptadas sin refinar).

## 1. Descripción
Primer escenario de Xibalbá: ríos de cañas espinosas, ríos de sangre y pus con decaimiento de Serenidad duplicado, plataformas móviles que se hunden, plataformas invisibles condicionadas a la Serenidad y murciélagos que cobran agresividad cuando la luz del jugador se encoge.

## 2. Componentes/estados afectados
- **HazardFloor** (nuevo, `game/src/entities/environment/hazard_floor.gd`): `Area2D` por código. Toca cuerpo del jugador → `-1 calavera` directa (ignora Círculo de Sangre) y teletransporta al último `Checkpoint` activo.
- **Checkpoint** (nuevo, `game/src/entities/environment/checkpoint.gd`): `Area2D` por código. Al entrar el jugador, guarda su posición como respawn en `PlayerDataResource` (o un componente global ligero). Sin curación.
- **SinkingPlatform** (nuevo, `game/src/entities/environment/sinking_platform.gd`): `AnimatableBody2D`/`StaticBody2D`. Al detectar contacto con el jugador, espera `sink_delay` y luego desplaza/mueve la colisión hacia abajo hasta desaparecer; respawn después.
- **InvisiblePlatform** (nuevo, `game/src/entities/environment/invisible_platform.gd`): `StaticBody2D` con colisión condicional. `collision_layer` se activa solo si `current_serenity / max_serenity >= 0.30`; si baja de 30%, colisión off (visual placeholder gris).
- **MurcielagoPeriferia** (nuevo, `game/src/entities/enemies/murcielago_periferia.gd`): `CharacterBody2D` con dos modos:
  - Pasivo: vuela horizontalmente a baja velocidad.
  - Carga: si `serenity_ratio < 0.30`, acelera hacia la posición del jugador.
  - Al contacto: daño al **Círculo de Sangre** (no calaveras directas).
- **SerenityZone** (nuevo, `game/src/entities/environment/serenity_zone.gd`): `Area2D` por código. Al entrar el jugador, setea `environment_multiplier` de su `SerenityComponent` (ej. 2.0 para duplicar decaimiento); al salir, restaura a 1.0.

## 3. Flujo
```
[Jugador entra a Checkpoint] → guarda posición
[Jugador toca HazardFloor] → -1 skull + teleport a checkpoint
[Jugador pisa SinkingPlatform] → Timer 1.5 s → hundir
[Serenidad < 30%] → InvisiblePlatform collision off + murciélagos cargan
[Jugador entra a SerenityZone] → multiplier 2.0 → Serenity decae -2.0/s
```

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| Hazard daño | 1 calavera directa | HazardResource |
| Sinking delay | 1.5 s | SinkingPlatformResource |
| Sinking speed/distance | 48 px en 1.0 s | SinkingPlatformResource |
| Murciélago pasivo speed | 30 px/s | MurcielagoResource |
| Murciélago carga speed | 180 px/s | MurcielagoResource |
| Umbral agresividad murciélago | 0.30 ratio | MurcielagoResource |
| Daño murciélago | 25.0 Círculo de Sangre | MurcielagoResource |
| Multiplicador zona sangre/pus | 2.0 | SerenityZoneResource |
| Umbral plataforma invisible | 0.30 ratio | InvisiblePlatform (export) |

## 5. Señales EventBus
Usadas: `serenity_changed` (UI/HUD), `blood_circle_changed`, `skulls_changed`. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. `HazardFloor` contacto → `skulls.current == max - 1` y posición del jugador == checkpoint activo.
2. `Checkpoint` activado → `PlayerDataResource.respawn_position` se actualiza.
3. `SinkingPlatform` contacto 1.5 s → plataforma se desplaza hacia abajo/la colisión se desactiva.
4. `InvisiblePlatform`: serenidad 50% → colisión activa; serenidad 20% → colisión inactiva.
5. `MurcielagoPeriferia`: serenidad 50% → velocidad pasiva; serenidad 20% → velocidad de carga y dirección hacia jugador.
6. `SerenityZone`: dentro → `serenity.environment_multiplier == 2.0`; fuera → 1.0.
7. `HazardFloor` no afecta Círculo de Sangre (sólo calaveras).
8. `MurcielagoPeriferia` no daña calaveras directas (sólo Círculo de Sangre).

## 7. Casos borde
- Sin checkpoint activo: hazard no crashea, respawn en posición original o Vector2.ZERO.
- SinkingPlatform: si jugador sale antes de 1.5 s, timer se cancela.
- InvisiblePlatform: ratio exactamente 0.30 → activa (incluyente).
- Murciélago: jugador fuera de rango de detección → sigue patrulla pasiva.
- Múltiples SerenityZones solapadas: la última en entrar gana; salir de una restaura a 1.0 (aceptado v1).
