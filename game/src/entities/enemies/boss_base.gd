extends CharacterBody2D
class_name BossBase
## Base común para jefes (Hun-Camé / Vucub-Camé). Sin lógica de movimiento compleja.

signal died

@export var stats: BossStatsResource
@export var blackboard: SharedBlackboard

var health: float = 200.0
var _dead: bool = false
var _desperation: bool = false


func _ready() -> void:
	if stats != null:
		health = stats.health


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0 and not _dead:
		_dead = true
		died.emit()


func is_dead() -> bool:
	return _dead


func activate_desperation() -> void:
	_desperation = true
	scale *= stats.desperation_size_scale


func is_in_desperation() -> bool:
	return _desperation


func has_attack_token() -> bool:
	if blackboard == null:
		return false
	var my_name: String = _get_name()
	return blackboard.attack_token == my_name


func _get_name() -> String:
	return ""
