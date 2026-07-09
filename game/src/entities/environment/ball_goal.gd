extends Area2D
class_name BallGoal
## Portería del juego de pelota: fondo de dioses o del jugador.

const SIDE_GODS: int = 0
const SIDE_TWINS: int = 1

@export var side: int = SIDE_GODS
@export var balance_shift: float = 10.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var ball := body as KineticBall2D
	if ball == null:
		return
	var shift: float = -balance_shift if side == SIDE_GODS else balance_shift
	EventBus.balance_changed.emit(shift)
	ball.queue_free()
