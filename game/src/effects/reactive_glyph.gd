extends PointLight2D
class_name ReactiveGlyph
## Glifo maya que despierta cuando el jugador se acerca: brilla más fuerte
## cuanto más cerca está Y cuanta más luz (Serenidad) trae el jugador.
## La roca "reacciona" a tu presencia — atmósfera viva de Xibalbá.

@export var wake_radius: float = 160.0
@export var max_energy: float = 1.4
@export var glyph_color: Color = Color(1.0, 0.15, 0.1)
@export var reaction_speed: float = 4.0

var _player: CharacterBase = null


func _ready() -> void:
	color = glyph_color
	energy = 0.0
	if texture == null:
		var grad := GradientTexture2D.new()
		grad.gradient = Gradient.new()
		grad.gradient.set_color(0, Color.WHITE)
		grad.gradient.set_color(1, Color(1, 1, 1, 0))
		grad.fill = GradientTexture2D.FILL_RADIAL
		grad.fill_from = Vector2(0.5, 0.5)
		grad.fill_to = Vector2(1.0, 0.5)
		grad.width = 64
		grad.height = 64
		texture = grad


func _physics_process(delta: float) -> void:
	energy = lerpf(energy, target_energy(), reaction_speed * delta)


## Cercanía × luz del jugador. Sin jugador (o lejos) el glifo duerme.
func target_energy() -> float:
	if _player == null or not is_instance_valid(_player):
		_player = _find_player()
		if _player == null:
			return 0.0
	var d: float = global_position.distance_to(_player.global_position)
	var proximity: float = clampf(1.0 - d / wake_radius, 0.0, 1.0)
	var player_light: float = _player.data.current_serenity / _player.data.max_serenity
	return proximity * maxf(player_light, 0.15) * max_energy


func _find_player() -> CharacterBase:
	for node: Node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBase:
			return node
	return null
