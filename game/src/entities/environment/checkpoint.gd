extends Area2D
class_name Checkpoint
## Guarda posición de respawn en PlayerDataResource.

@export var data: PlayerDataResource


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if data == null:
		return
	if body is CharacterBase:
		data.respawn_position = body.global_position
