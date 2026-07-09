extends Node2D
class_name GoreEffect
## Efecto visual de muerte/daño según el tipo de daño recibido.

enum Type { BLOOD, SKULL, FALL, FIRE, DARKNESS }

@export var blood_color: Color = Color(0.6, 0.0, 0.0)
@export var bone_color: Color = Color(0.9, 0.9, 0.85)
@export var max_particles: int = 32
@export var gore_duration: float = 1.0

var _active: bool = false
var _timer: float = 0.0
var _camera_shake: float = 0.0
var _camera: Camera2D = null


func _ready() -> void:
	_camera = _find_camera()


func play(type: Type, intensity: float = 1.0) -> void:
	match type:
		Type.BLOOD:
			_spawn_particles(blood_color, intensity)
			_camera_shake = 4.0 * intensity
		Type.SKULL:
			_spawn_particles(bone_color, intensity)
			_camera_shake = 2.0 * intensity
		Type.FALL:
			_camera_shake = 6.0 * intensity
		Type.FIRE:
			_spawn_particles(Color(1.0, 0.4, 0.0), intensity)
		Type.DARKNESS:
			_spawn_particles(Color(0.1, 0.0, 0.2), intensity)
	_active = true
	_timer = 0.0
	set_physics_process(true)


func _spawn_particles(color: Color, intensity: float) -> void:
	var p := CPUParticles2D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = int(max_particles * clampf(intensity, 0.1, 2.0))
	p.color = color
	p.gravity = Vector2(0, 200)
	p.initial_velocity_min = 50.0
	p.initial_velocity_max = 150.0
	p.lifetime = 0.6
	add_child(p)
	p.finished.connect(p.queue_free)


func _physics_process(delta: float) -> void:
	if not _active:
		return
	_timer += delta
	_camera_shake = move_toward(_camera_shake, 0.0, delta * 10.0)
	_apply_camera_shake()
	if _timer >= gore_duration:
		_active = false
		set_physics_process(false)
		if _camera != null:
			_camera.offset = Vector2.ZERO


func _apply_camera_shake() -> void:
	if _camera == null or _camera_shake <= 0.0:
		return
	var angle := randf() * TAU
	var offset := Vector2(cos(angle), sin(angle)) * _camera_shake
	_camera.offset = offset


func _find_camera() -> Camera2D:
	var vp := get_viewport()
	if vp != null:
		return vp.get_camera_2d()
	return null
