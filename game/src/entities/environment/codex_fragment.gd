extends Area2D
class_name CodexFragment
## Ítem que permite salir de una Casa del Tormento.

@export var data: PlayerDataResource


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null or data == null:
		return
	data.has_codex_fragment = true
	queue_free()
