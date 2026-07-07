extends Node2D
class_name DarkHouse
## Quequma-ha: antorcha temporal; serenidad 0 = muerte instantánea.

@export var data: PlayerDataResource
@export var torch_drain_per_second: float = 5.0

var active: bool = false
var torch_lit: bool = false
var _timer: float = 0.0


func _ready() -> void:
	set_physics_process(false)


func activate(player_data: PlayerDataResource) -> void:
	data = player_data
	active = true
	set_physics_process(true)


func deactivate() -> void:
	active = false
	set_physics_process(false)


func set_torch_lit(lit: bool) -> void:
	torch_lit = lit


func _physics_process(delta: float) -> void:
	if not active or data == null:
		return
	if torch_lit:
		data.current_serenity -= torch_drain_per_second * delta
	if data.current_serenity <= 0.0:
		data.current_skulls = 0
		set_physics_process(false)
