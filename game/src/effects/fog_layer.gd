extends Node2D
class_name FogLayer
## Niebla viva por delante del gameplay: deriva lenta que REACCIONA al
## movimiento del jugador (correr hacia la derecha la empuja a la izquierda).

@export var base_drift: Vector2 = Vector2(-8.0, 0.0)
@export var player_reaction: float = 0.25
@export var extents: Vector2 = Vector2(200.0, 300.0)
@export var density: int = 24
@export var fog_color: Color = Color(0.55, 0.62, 0.7, 0.10)

var drift: Vector2 = Vector2.ZERO
var _player: CharacterBase = null
var _particles: CPUParticles2D


func _ready() -> void:
	drift = base_drift
	_particles = CPUParticles2D.new()
	_particles.amount = density
	_particles.lifetime = 6.0
	_particles.preprocess = 6.0
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = extents
	_particles.gravity = drift
	_particles.scale_amount_min = 6.0
	_particles.scale_amount_max = 14.0
	_particles.color = fog_color
	var grad := GradientTexture2D.new()
	grad.gradient = Gradient.new()
	grad.gradient.set_color(0, Color(1, 1, 1, 0.8))
	grad.gradient.set_color(1, Color(1, 1, 1, 0))
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(1.0, 0.5)
	grad.width = 32
	grad.height = 32
	_particles.texture = grad
	add_child(_particles)


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
	update_drift(delta)
	_particles.gravity = drift


## La niebla huye del movimiento del jugador y vuelve sola a su deriva base.
func update_drift(delta: float) -> void:
	var target: Vector2 = base_drift
	if _player != null and is_instance_valid(_player):
		target -= _player.velocity * player_reaction
	drift = drift.lerp(target, 2.0 * delta)


func _find_player() -> CharacterBase:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBase:
			return node
	return null
