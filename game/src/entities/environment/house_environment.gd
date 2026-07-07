extends Node2D
class_name HouseEnvironment
## Base para modificadores ambientales de una Casa del Tormento.

@export var data: PlayerDataResource

var active: bool = false


func enter(player_data: PlayerDataResource) -> void:
	data = player_data
	active = true
	_apply()


func exit() -> void:
	active = false
	_reset()
	set_physics_process(false)


func _apply() -> void:
	push_warning("HouseEnvironment._apply() debe ser sobreescrito.")


func _reset() -> void:
	pass
