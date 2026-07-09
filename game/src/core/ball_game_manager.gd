extends Node
class_name BallGameManager
## Coordina el Juego de Pelota final: balance, pelota, fases.

const MAX_BALANCE: float = 100.0
const MIN_BALANCE: float = -100.0

@export var ball_scene: PackedScene
@export var player: CharacterBase = null

var balance: float = 0.0
var active_ball: KineticBall2D = null
var current_phase: int = 1

const PHASE_2_BALANCE: float = 40.0
const PHASE_3_BALANCE: float = 80.0


func start_game(spawn_position: Vector2) -> void:
	_spawn_ball(spawn_position)
	EventBus.balance_changed.emit(balance)


func _ready() -> void:
	EventBus.balance_changed.connect(_on_balance_changed_internal)


func _on_balance_changed_internal(value: float) -> void:
	var new_phase := 1
	if absf(value) >= PHASE_3_BALANCE:
		new_phase = 3
	elif absf(value) >= PHASE_2_BALANCE:
		new_phase = 2
	if new_phase != current_phase:
		current_phase = new_phase
		_on_phase_changed(current_phase)


func _on_phase_changed(phase: int) -> void:
	# ponytail: placeholders para fases; expandir con ilusiones/proyectiles falsos
	pass


func _spawn_ball(position: Vector2) -> void:
	if active_ball != null and not active_ball.is_queued_for_deletion():
		active_ball.queue_free()
	if ball_scene == null:
		return
	active_ball = ball_scene.instantiate() as KineticBall2D
	if active_ball == null:
		return
	active_ball.global_position = position
	active_ball.set_state_light()
	var parent := get_parent()
	if parent != null:
		parent.add_child(active_ball)


func shift_balance(amount: float) -> void:
	balance = clampf(balance + amount, MIN_BALANCE, MAX_BALANCE)
	EventBus.balance_changed.emit(balance)
	if balance >= MAX_BALANCE:
		_on_extreme_darkness()


func _on_extreme_darkness() -> void:
	balance = 0.0
	if player != null:
		player.skulls.lose_skull()


func reset_ball(spawn_position: Vector2) -> void:
	_spawn_ball(spawn_position)
