extends Area2D
class_name SerenityZone
## Zona que modifica el environment_multiplier del SerenityComponent del jugador.

@export var stats: SerenityZoneResource

var _active_bodies: Array[CharacterBase] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	_active_bodies.append(c)
	c.serenity.set_multiplier(stats.environment_multiplier)


func _on_body_exited(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	_active_bodies.erase(c)
	c.serenity.set_multiplier(1.0)
