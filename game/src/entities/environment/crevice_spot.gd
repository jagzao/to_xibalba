extends Area2D
class_name CreviceSpot
## Hendidura oscura en la pared trasera. Marca al jugador en rango;
## HidingState hace el resto (interact para entrar/salir).

@export var size: Vector2 = Vector2(32, 48)


func _ready() -> void:
	var s := CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = size
	add_child(s)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase:
		body.nearby_crevice = self


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBase and body.nearby_crevice == self:
		body.nearby_crevice = null
