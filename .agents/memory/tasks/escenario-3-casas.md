# Spec: Escenario 3 — Las Seis Casas del Tormento (escenario-3-casas)

Fuente de diseño: `docs/03_niveles.md` §3. Asunciones aprobadas por defecto (autonomía total).

## 1. Descripción
Las Seis Casas de Xibalbá: cada una aplica un modificador de entorno distinto sobre `PlayerDataResource` y `SerenityComponent`. Al cruzar puerta: autosave de posición. No se puede salir sin el Fragmento de Códice del final.

## 2. Componentes/estados afectados
- **HouseDoor** (nuevo, `game/src/entities/environment/house_door.gd`): `Area2D`. Al entrar guarda `respawn_position` y bloquea salida si no se tiene `has_codex_fragment`.
- **HouseEnvironment** (nuevo, `game/src/entities/environment/house_environment.gd`): base abstracta para modificadores de casa. Cada subclase implementa `apply()`.
- **DarkHouse (Quequma-ha)** (`game/src/entities/environment/dark_house.gd`): antorcha temporal. Si encendida: `-5.0 Serenidad/s`. Serenidad 0 aquí = muerte instantánea.
- **ColdHouse (Xuxulim-ha)** (`game/src/entities/environment/cold_house.gd`): congelación. `>4 s` sin tocar Piedra de Fuego → `-10% Círculo de Sangre/s`. Suelo fricción 0.02.
- **JaguarHouse (Balami-ha)** (`game/src/entities/environment/jaguar_house.gd`): jaguares espectrales acechan. Contacto = -1 Calavera directa.
- **BatHouse (Zotzi-ha)** (`game/src/entities/environment/bat_house.gd`): Camazotz gigante invulnerable. `>0.5 s` por encima del límite superior de cámara → -1 Calavera.
- **KnifeHouse (Chayin-ha)** (`game/src/entities/environment/knife_house.gd`): navajas autónomas. Dash mal timed → Círculo de Sangre vaciado instantáneo.
- **HeatHouse (Chonay-ha)** (`game/src/entities/environment/heat_house.gd`): lava, plataformas porosas se destruyen tras 1 s de contacto. Humo `-3.0 Serenidad/s`.
- **CodexFragment** (nuevo, `game/src/entities/environment/codex_fragment.gd`): ítem que permite salir.

## 3. Flujo
```
[Jugador entra a HouseDoor] → respawn_position = posición
[Según casa activa] → HouseEnvironment.apply(player)
[Recoger CodexFragment] → player.data.has_codex_fragment = true
[Intentar salir sin fragmento] → bloqueado
```

## 4. Balance
| Valor | Default | Resource |
|---|---|---|
| Antorcha Serenidad/s | -5.0 | DarkHouseResource |
| Muerte instantánea Serenidad | 0.0 | DarkHouse |
| Congelación delay | 4.0 s | ColdHouseResource |
| Congelación daño/s | -10% blood | ColdHouseResource |
| Fricción suelo frío | 0.02 | ColdHouseResource |
| Jaguar daño | -1 calavera | JaguarHouse |
| Camazotz umbral | 0.5 s sobre cámara | BatHouseResource |
| Navajas daño dash mal | 100.0 blood | KnifeHouseResource |
| Calor Serenidad/s | -3.0 | HeatHouseResource |
| Plataforma porosa duración | 1.0 s | HeatHouseResource |

## 5. Señales EventBus
Usadas: `serenity_changed`, `blood_circle_changed`, `skulls_changed`, `panic_entered`. Nuevas: ninguna.

## 6. Criterios de aceptación (asserts GUT)
1. `HouseDoor` entra → `respawn_position` guardada.
2. `HouseDoor` bloquea salida sin `has_codex_fragment`; permite con él.
3. `DarkHouse`: antorcha encendida → Serenidad desciende -5/s; Serenidad 0 → muerte (`skulls == 0`).
4. `ColdHouse`: sin Piedra de Fuego 4 s → blood baja 10%; suelo tiene fricción 0.02.
5. `JaguarHouse`: contacto jaguar → -1 calavera.
6. `BatHouse`: 0.6 s sobre límite cámara → -1 calavera.
7. `KnifeHouse`: dash mal timed → blood en 0 y Stunned.
8. `HeatHouse`: humo -3 Serenidad/s; plataforma porosa colapsa tras 1 s.
9. `CodexFragment` otorga flag `has_codex_fragment`.

## 7. Casos borde
- Antorcha apagada en Casa Oscura → visión cero pero no muerte.
- Tocar Piedra de Fuego reinicia timer de congelación.
- Salir de una casa antes de recoger fragmento: imposible.
- Múltiples jaguares: cada contacto -1 calavera separado.
