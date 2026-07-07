extends Area2D
class_name ProjectileLight
## Balín de barro cargado de luz. Línea recta, muere al impactar o expirar.

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0
var damage: float = 12.0
var lifetime: float = 1.5


func _ready() -> void:
	# ponytail: forma y luz por código, sin tscn; escena visual cuando haya arte
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 4.0
	add_child(shape)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_entered(target: Area2D) -> void:
	if target.has_method("take_hit"):
		target.take_hit(damage)
	queue_free()
