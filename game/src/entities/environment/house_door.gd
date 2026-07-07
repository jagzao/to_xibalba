extends Area2D
class_name HouseDoor
## Puerta de casa del tormento: autosave y bloqueo hasta fragmento de códice.

@export var data: PlayerDataResource


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null or data == null:
		return
	data.respawn_position = c.global_position
	# Al entrar, reseteamos flag de fragmento (debe conseguirse dentro).
	data.has_codex_fragment = false


func can_exit() -> bool:
	if data == null:
		return true
	return data.has_codex_fragment
