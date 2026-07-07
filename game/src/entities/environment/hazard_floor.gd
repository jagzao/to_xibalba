extends Area2D
class_name HazardFloor
## Suelo peligroso: quita calaveras directas y devuelve al último checkpoint.

@export var data: PlayerDataResource
@export var stats: HazardResource


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if data == null or stats == null:
		return
	var character := body as CharacterBase
	if character == null:
		return
	for i: int in range(stats.skulls_lost):
		character.skulls.lose_skull()
	character.global_position = data.respawn_position
