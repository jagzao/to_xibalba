extends Area2D
class_name LevelExit
## Marca el final de un escenario. Simplemente emite evento al EventBus.

@export var next_scene_path: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	EventBus.respawn_started.emit()
