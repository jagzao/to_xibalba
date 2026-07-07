extends StaticBody2D
class_name SinkingPlatform
## Plataforma que se hunde tras un delay de contacto.

@export var stats: SinkingPlatformResource

var _sinking: bool = false
var _timer: float = 0.0
var _original_position: Vector2 = Vector2.ZERO

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _detector: Area2D = $Detector


func _ready() -> void:
	_original_position = global_position
	_detector.body_entered.connect(_on_detector_body_entered)
	_detector.body_exited.connect(_on_detector_body_exited)


func _physics_process(delta: float) -> void:
	if not _sinking:
		return
	_timer += delta
	var t: float = clampf(_timer / stats.sink_duration, 0.0, 1.0)
	global_position = _original_position.lerp(
		_original_position + Vector2(0.0, stats.sink_distance), t
	)
	if t >= 1.0:
		_collision.disabled = true
		if _timer >= stats.sink_duration + stats.respawn_delay:
			_reset()


func _reset() -> void:
	_sinking = false
	_timer = 0.0
	global_position = _original_position
	_collision.disabled = false


func _on_detector_body_entered(_body: Node2D) -> void:
	if not _sinking:
		_sinking = true
		_timer = 0.0


func _on_detector_body_exited(_body: Node2D) -> void:
	if not _sinking:
		return
	var t: float = _timer / stats.sink_duration
	if t < 1.0:
		_reset()
