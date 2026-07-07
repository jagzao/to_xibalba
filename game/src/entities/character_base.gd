extends CharacterBody2D
class_name CharacterBase
## Base común de los gemelos. Inyecta el PlayerDataResource compartido a los
## componentes, centraliza input/coyote/buffer y traduce Serenidad → radio de luz.

@export var data: PlayerDataResource
@export var stats: MovementStatsResource
@export var max_light_radius: float = 1.0

var input_axis: float = 0.0
var facing: float = 1.0
var dash_pressed: bool = false
var attack_pressed: bool = false
var aim_pressed: bool = false
var aim_held: bool = false
var aim_direction: Vector2 = Vector2.RIGHT
var grounded: bool = false
var time_since_grounded: float = 9999.0
var time_since_jump_pressed: float = 9999.0
## Ventana de absorción post-dash (Ixbalanqué: golpe en <2 s = +2.0 Serenidad).
var time_since_dash: float = 9999.0

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var serenity: SerenityComponent = $SerenityComponent
@onready var blood_circle: BloodCircleComponent = $BloodCircleComponent
@onready var skulls: SkullsComponent = $SkullsComponent
@onready var light: PointLight2D = $CharacterVisuals/PointLight2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var melee: MeleeAttackComponent = $MeleeAttackComponent
@onready var ranged: RangedAttackComponent = $RangedAttackComponent


func _ready() -> void:
	if data == null:
		data = PlayerDataResource.new()
	if stats == null:
		stats = MovementStatsResource.new()
	serenity.data = data
	blood_circle.data = data
	skulls.data = data
	blood_circle.emptied.connect(_on_blood_circle_emptied)
	melee.setup(self, serenity, hitbox)
	ranged.setup(self, serenity)
	# La base controla el orden: input → estado → move_and_slide.
	fsm.set_physics_process(false)


func _physics_process(delta: float) -> void:
	_poll_input(delta)
	fsm._physics_process(delta)
	move_and_slide()
	grounded = is_on_floor()
	time_since_grounded = 0.0 if grounded else time_since_grounded + delta
	time_since_dash += delta
	_update_light()


func can_coyote_jump() -> bool:
	return grounded or time_since_grounded <= stats.coyote_time


func has_buffered_jump() -> bool:
	return time_since_jump_pressed <= stats.jump_buffer_time


func consume_jump() -> void:
	time_since_jump_pressed = 9999.0


func apply_gravity(delta: float) -> void:
	velocity.y += stats.gravity * delta


func _poll_input(delta: float) -> void:
	input_axis = Input.get_axis("move_left", "move_right")
	if input_axis != 0.0:
		facing = signf(input_axis)
	dash_pressed = Input.is_action_just_pressed("dash")
	attack_pressed = Input.is_action_just_pressed("attack")
	aim_pressed = Input.is_action_just_pressed("aim")
	aim_held = Input.is_action_pressed("aim")
	var to_mouse: Vector2 = get_global_mouse_position() - global_position
	if to_mouse.length_squared() > 0.0:
		aim_direction = to_mouse.normalized()
	if Input.is_action_just_pressed("jump"):
		time_since_jump_pressed = 0.0
	else:
		time_since_jump_pressed += delta


func _update_light() -> void:
	light.texture_scale = data.get_light_radius(max_light_radius)


func _on_blood_circle_emptied() -> void:
	fsm.change_state("Stunned")
