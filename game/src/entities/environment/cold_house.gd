extends Node2D
class_name ColdHouse
## Xuxulim-ha: congelación progresiva y fricción baja del suelo.

@export var data: PlayerDataResource
@export var freeze_delay: float = 4.0
@export var blood_drain_per_second: float = 10.0
@export var floor_friction: float = 0.02

var active: bool = false
var has_fire_stone: bool = false
var _timer: float = 0.0
var _floor: StaticBody2D = null


func activate(player_data: PlayerDataResource) -> void:
	data = player_data
	active = true
	set_physics_process(true)


func touch_fire_stone() -> void:
	has_fire_stone = true
	_timer = 0.0


func _find_floor() -> StaticBody2D:
	for c in get_children():
		if c is StaticBody2D:
			return c
	return null


func _physics_process(delta: float) -> void:
	if not active or data == null:
		return
	if has_fire_stone:
		return
	_timer += delta
	if _timer > freeze_delay:
		data.current_blood_circle -= blood_drain_per_second * delta
		_timer = freeze_delay + 0.0001
