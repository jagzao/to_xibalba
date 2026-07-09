extends Area2D
class_name CameraLimits
## Fija los límites de la cámara del jugador al entrar en la sala.

@export var limit_left: float = -10000000.0
@export var limit_top: float = -10000000.0
@export var limit_right: float = 10000000.0
@export var limit_bottom: float = 10000000.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	var camera := c.get_node_or_null("PlayerCamera") as Camera2D
	if camera == null:
		return
	camera.limit_left = int(limit_left)
	camera.limit_top = int(limit_top)
	camera.limit_right = int(limit_right)
	camera.limit_bottom = int(limit_bottom)
