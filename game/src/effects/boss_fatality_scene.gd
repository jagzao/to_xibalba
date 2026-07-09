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
			_spawn_burst(Color(0.6, 0.0, 0.0), 48)
		BossType.AHALGANA:
			_spawn_burst(Color(0.0, 0.5, 0.6), 32)
		BossType.CAMAZOTZ:
			_spawn_burst(Color(0.1, 0.0, 0.2), 64)


func _spawn_burst(color: Color, amount: int) -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = amount
	p.color = color
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 120.0
	p.lifetime = duration
	p.explosiveness = 1.0
	add_child(p)
	p.finished.connect(p.queue_free)


func _physics_process(delta: float) -> void:
	_timer += delta
	modulate.a = 1.0 - (_timer / duration)
	if _timer >= duration:
		set_physics_process(false)
		queue_free()
