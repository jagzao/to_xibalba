extends Node2D
class_name BossFatalityScene
## Escena base para ejecuciones de jefes.

enum BossType { HUN_CAME, AHALGANA, CAMAZOTZ }

@export var boss_type: BossType = BossType.HUN_CAME
@export var duration: float = 3.0

var _timer: float = 0.0


func play() -> void:
	set_physics_process(true)
	_match_fatality()


func _match_fatality() -> void:
	match boss_type:
		BossType.HUN_CAME:
			pass
		BossType.AHALGANA:
			pass
		BossType.CAMAZOTZ:
			pass


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= duration:
		set_physics_process(false)
		queue_free()
