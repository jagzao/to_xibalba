extends StaticBody2D
class_name CrumblingPlatform
## Roca volcánica traicionera: al pisarla tiembla y se destruye en
## crumble_delay; reaparece tras respawn_delay para permitir reintentos.

@export var crumble_delay: float = 0.4
@export var respawn_delay: float = 3.0
@export var size: Vector2 = Vector2(96, 24)

var crumbled: bool = false
var _touch_timer: float = -1.0
var _respawn_timer: float = 0.0
var _shape: CollisionShape2D
var _sensor: Area2D


func _ready() -> void:
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	_shape.shape.size = size
	add_child(_shape)
	# sensor apenas arriba de la superficie: detecta la pisada
	_sensor = Area2D.new()
	var s := CollisionShape2D.new()
	s.shape = RectangleShape2D.new()
	s.shape.size = Vector2(size.x, 8.0)
	s.position.y = -size.y * 0.5 - 4.0
	_sensor.add_child(s)
	add_child(_sensor)
	_sensor.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if crumbled:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_restore()
		return
	if _touch_timer >= 0.0:
		_touch_timer -= delta
		# temblor mientras agoniza
		position.x += sin(Time.get_ticks_msec() * 0.1) * 0.5
		if _touch_timer <= 0.0:
			_crumble()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBase and _touch_timer < 0.0 and not crumbled:
		_touch_timer = crumble_delay


func _crumble() -> void:
	crumbled = true
	_respawn_timer = respawn_delay
	_shape.set_deferred("disabled", true)
	_sensor.set_deferred("monitoring", false)
	visible = false


func _restore() -> void:
	crumbled = false
	_touch_timer = -1.0
	_shape.set_deferred("disabled", false)
	_sensor.set_deferred("monitoring", true)
	visible = true
