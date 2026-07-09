extends CharacterBody2D
class_name BlindStalker
## Amenaza imbatible de Sala 2: ciego, oído hiperdesarrollado. Patrulla el
## pasillo; si oye movimiento fuera de una grieta, embiste y quita 1 calavera.

@export var patrol_left: float = -200.0
@export var patrol_right: float = 200.0
@export var patrol_speed: float = 80.0
@export var lunge_speed: float = 320.0
@export var hearing_radius: float = 140.0
## Velocidad mínima del jugador que produce ruido audible.
@export var noise_threshold: float = 10.0

var _direction: float = 1.0
var _prey: CharacterBase = null


func _ready() -> void:
	var hearing := Area2D.new()
	hearing.name = "Hearing"
	var s := CollisionShape2D.new()
	s.shape = CircleShape2D.new()
	s.shape.radius = hearing_radius
	hearing.add_child(s)
	add_child(hearing)
	hearing.body_entered.connect(_on_hearing_entered)
	hearing.body_exited.connect(_on_hearing_exited)
	var body_shape := CollisionShape2D.new()
	body_shape.shape = RectangleShape2D.new()
	body_shape.shape.size = Vector2(24, 40)
	add_child(body_shape)


func _physics_process(delta: float) -> void:
	if _prey != null and can_hear(_prey):
		velocity.x = signf(_prey.global_position.x - global_position.x) * lunge_speed
		if absf(_prey.global_position.x - global_position.x) < 20.0:
			_prey.skulls.lose_skull()
			_prey = null
	else:
		velocity.x = _direction * patrol_speed
		if global_position.x > patrol_right:
			_direction = -1.0
		elif global_position.x < patrol_left:
			_direction = 1.0
	move_and_slide()


## Ciego: solo oye. Oculto en grieta o inmóvil = inaudible.
func can_hear(target: CharacterBase) -> bool:
	if target.fsm.current_state != null and target.fsm.current_state.name == &"Hiding":
		return false
	return target.velocity.length() > noise_threshold


func _on_hearing_entered(body: Node2D) -> void:
	if body is CharacterBase:
		_prey = body


func _on_hearing_exited(body: Node2D) -> void:
	if body == _prey:
		_prey = null
