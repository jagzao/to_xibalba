extends State
class_name DashState
## Paso del Jaguar: dash direccional (terrestre o aéreo) con i-frames.
## Durante los primeros dash_iframes cuadros: hurtbox.monitoring = false.

var _time_left: float = 0.0
var _direction: float = 1.0


func enter(_previous_state: String) -> void:
	var c := actor as CharacterBase
	_direction = signf(c.input_axis) if c.input_axis != 0.0 else c.facing
	_time_left = c.stats.dash_iframes / c.stats.frames_per_second
	c.hurtbox.monitoring = false
	c.velocity.y = 0.0


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = _direction * c.stats.dash_speed
	c.velocity.y = 0.0
	_time_left -= delta
	if _time_left <= 0.0001:
		finished.emit("Idle" if c.grounded else "Fall")


func exit() -> void:
	var c := actor as CharacterBase
	c.hurtbox.monitoring = true
	c.time_since_dash = 0.0
