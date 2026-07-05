# Arquitectura Técnica Fundacional

## 1. PlayerDataResource (extends Resource, class_name PlayerDataResource)
| Campo | Tipo | Default |
|---|---|---|
| max_serenity | float | 100.0 |
| current_serenity | float | 100.0 |
| max_blood_circle | float | 100.0 |
| current_blood_circle | float | 100.0 |
| max_skulls | int | 3 |
| current_skulls | int | 3 |
| is_in_panic | bool | false |

- Serenidad = luz. Círculo de Sangre = postura/armadura de impacto. Calaveras = vida real (estilo máscaras Hollow Knight).

### Regla de la Luz/Serenidad
- Decaimiento pasivo: `-1.0/s` (zonas especiales lo modifican, ver [[03_niveles]]).
- `radio_luz = radio_maximo * (current_serenity / max_serenity)` aplicado a `PointLight2D`.
- Serenidad `== 0.0` → estado Pánico: radio fijo `0.1`, daño recibido al Círculo de Sangre `× 1.5`.

## 2. EventBus (Autoload singleton)
Señales globales (UI y entorno solo se suscriben aquí):
- `serenity_changed(current: float, max: float)`
- `blood_circle_changed(current: float, max: float)`
- `skulls_changed(current: int, max: int)`
- `panic_entered()` / `panic_exited()`
- `artifact_read_started(id: String, text: String)` / `artifact_read_completed()`

Prohibido para UI: refs directas a nodos de lógica, `get_node("/root/Player")`.

## 3. DidacticManager
- Pausa por software: estado `MEDITATING` al interactuar con altares (Xoloitzcuintles, Colibríes).
- Muestra poemas prehispánicos (Nezahualcóyotl) desde Resources de texto.
- Durante lectura: inmunidad temporal. Al completar: Serenidad → 100%.

## Patrones obligatorios
- FSM: cada estado = nodo hijo de `State` (`enter()`, `exit()`, `physics_update(delta: float)`). Sin booleanos de estado.
- Configuración estática = Resources (`class_name ... extends Resource`): daño de balines, velocidad de dash, textos de poemas.
- Inversión de dependencias en UI: HUD de Calaveras/Círculo de Sangre solo escucha EventBus.
