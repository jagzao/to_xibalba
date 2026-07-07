extends StaticBody2D
class_name PorousPlatform
## Plataforma porosa de Chonay-ha: colapsa tras un tiempo de contacto.

@export var collapse_time: float = 1.0

var _timer: float = 0.0
var _collapsing: bool = false


func _physics_process(delta: float) -> void:
	if not _collapsing:
		return
	_timer += delta
	if _timer >= collapse_time:
		queue_free()


func start_collapse() -> void:
	_collapsing = true


func cancel_collapse() -> void:
	_collapsing = false
	_timer = 0.0
