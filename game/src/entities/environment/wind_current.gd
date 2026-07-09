extends Area2D
class_name WindCurrent
## Corriente de viento subterráneo. force en px/s²: horizontal empuja hacia
## túneles; vertical positiva succiona hacia abajo (acelera la caída).

@export var force: Vector2 = Vector2(300.0, 0.0)
@export var size: Vector2 = Vector2(96, 192)


func _ready() -> void:
	var s := CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = size
	add_child(s)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase:
		body.external_force += force


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBase:
		body.external_force -= force
