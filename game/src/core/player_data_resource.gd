extends Resource
class_name PlayerDataResource
## Contenedor de datos del jugador. Sin refs a nodos; solo estado + fórmulas puras.

const PANIC_LIGHT_RADIUS: float = 0.1
const PANIC_DAMAGE_MULTIPLIER: float = 1.5

@export var max_serenity: float = 100.0
@export var current_serenity: float = 100.0
@export var max_blood_circle: float = 100.0
@export var current_blood_circle: float = 100.0
@export var max_skulls: int = 3
@export var current_skulls: int = 3
@export var is_in_panic: bool = false
@export var respawn_position: Vector2 = Vector2.ZERO
@export var has_codex_fragment: bool = false


## Alias de lectura legacy (algunos scripts usan `data.skulls`).
var skulls: int:
	get: return current_skulls
	set(value): current_skulls = value


## Radio_Luz = Radio_Maximo * (Serenidad_Actual / Serenidad_Maxima)
func get_light_radius(max_radius: float) -> float:
	if is_in_panic:
		return PANIC_LIGHT_RADIUS
	return max_radius * (current_serenity / max_serenity)


## Devuelve true si el estado de pánico cambió.
func change_serenity(amount: float) -> bool:
	current_serenity = clampf(current_serenity + amount, 0.0, max_serenity)
	var was_panic: bool = is_in_panic
	is_in_panic = current_serenity <= 0.0
	return was_panic != is_in_panic


## Aplica daño al Círculo de Sangre (x1.5 en pánico). Devuelve true si llegó a 0 (stun).
func take_blood_damage(amount: float) -> bool:
	var final: float = amount * (PANIC_DAMAGE_MULTIPLIER if is_in_panic else 1.0)
	current_blood_circle = clampf(current_blood_circle - final, 0.0, max_blood_circle)
	return current_blood_circle <= 0.0


## Daño directo a calaveras (ignora Círculo de Sangre). Devuelve true si murió.
func lose_skull() -> bool:
	current_skulls = maxi(current_skulls - 1, 0)
	return current_skulls <= 0
