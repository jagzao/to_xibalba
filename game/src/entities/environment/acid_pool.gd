extends Area2D
class_name AcidPool
## Cenote de pus y sangre: entrar destruye la Serenidad al instante y
## drena el Círculo de Sangre por segundo. Salir YA o morir.

@export var blood_drain_per_second: float = 25.0
@export var size: Vector2 = Vector2(128, 64)

var _victims: Array[CharacterBase] = []


func _ready() -> void:
	var s := CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = size
	add_child(s)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	for c: CharacterBase in _victims:
		c.blood_circle.take_damage(blood_drain_per_second * delta)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	c.serenity.change(-c.data.max_serenity)
	_victims.append(c)


func _on_body_exited(body: Node2D) -> void:
	var c := body as CharacterBase
	if c != null:
		_victims.erase(c)
