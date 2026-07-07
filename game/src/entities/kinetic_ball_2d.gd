extends RigidBody2D
class_name KineticBall2D
## Pelota del Juego de Pelota final. Rebote elástico perfecto.

@export var stats: BallStateResource

var last_hitter: String = ""
var state: int = BallStateResource.State.LIGHT

var _hitbox: Area2D = null


func _ready() -> void:
	if stats == null:
		stats = BallStateResource.new()
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 1.0
	physics_material_override.friction = 0.0
	_find_hitbox()
	if _hitbox != null:
		_hitbox.body_entered.connect(_on_body_entered)


func _find_hitbox() -> void:
	for child: Node in get_children():
		if child is Area2D:
			_hitbox = child
			break


func set_state_light() -> void:
	state = BallStateResource.State.LIGHT
	last_hitter = "twin"


func set_state_darkness() -> void:
	state = BallStateResource.State.DARKNESS
	last_hitter = "lords"


func apply_deflection(direction: Vector2, multiplier: float) -> void:
	var speed: float = stats.base_speed
	if state == BallStateResource.State.LIGHT:
		speed *= stats.light_multiplier
	elif state == BallStateResource.State.DARKNESS:
		speed *= stats.darkness_multiplier
	speed *= multiplier
	linear_velocity = direction.normalized() * speed


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	if state == BallStateResource.State.DARKNESS:
		c.blood_circle.take_damage(stats.graze_damage)
