extends State
class_name StunnedState
## Círculo de Sangre vacío: inputs inhabilitados exactamente `duration` segundos.
## La base State ignora handle_input, así que estar aquí = sin control.

@export var duration: float = 1.5
@export var next_state: String = "Idle"

var _time_left: float = 0.0


func enter(_previous_state: String) -> void:
	_time_left = duration


func physics_update(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		finished.emit(next_state)
