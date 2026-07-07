extends Area2D
class_name Altar
## Altar didáctico (Xoloitzcuintle/Jaguar/Colibrí). Solo marca al jugador
## en rango; la meditación la maneja la FSM del personaje.

@export var poem: PoemResource
@export var interaction_radius: float = 24.0


func _ready() -> void:
	# ponytail: forma por código, sin tscn; escena visual cuando haya arte
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = interaction_radius
	add_child(shape)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase:
		body.nearby_altar = self


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBase and body.nearby_altar == self:
		body.nearby_altar = null
