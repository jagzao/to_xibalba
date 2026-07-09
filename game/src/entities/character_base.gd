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
var ability_pressed: bool = false
var interact_pressed: bool = false
var nearby_altar: Altar = null
var nearby_crevice: Area2D = null
var grounded: bool = false
## Dirección de la pared tocada (-1 izq, +1 der, 0 sin pared) para wall slide.
var wall_direction: float = 0.0
## Distancia de caída vertical acumulada (daño por impacto al aterrizar).
var fall_distance: float = 0.0
## Aceleración externa (corrientes de viento). La aplican WindCurrent al entrar/salir.
var external_force: Vector2 = Vector2.ZERO
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

## Cada gemelo inyecta su PlayerAbility, componentes de ataque y su hitbox.
var ability: PlayerAbility = null
var melee: MeleeAttackComponent = null
var ranged: RangedAttackComponent = null
var hitbox: Area2D = null


func _ready() -> void:
	if data == null:
		data = PlayerDataResource.new()
	if stats == null:
		stats = MovementStatsResource.new()
	serenity.data = data
	blood_circle.data = data
	skulls.data = data
	blood_circle.emptied.connect(_on_blood_circle_emptied)
	# La base controla el orden: input → estado → move_and_slide.
	fsm.set_physics_process(false)


func _physics_process(delta: float) -> void:
	_poll_input(delta)
	fsm._physics_process(delta)
	velocity += external_force * delta
	if not grounded and velocity.y > 0.0:
		fall_distance += velocity.y * delta
	move_and_slide()
	var was_grounded: bool = grounded
	grounded = is_on_floor()
	wall_direction = -signf(get_wall_normal().x) if is_on_wall_only() else 0.0
	if grounded and not was_grounded:
		_on_landed()
	time_since_grounded = 0.0 if grounded else time_since_grounded + delta
	time_since_dash += delta
	_update_light()
	_update_hitbox_facing()


func _on_landed() -> void:
	if fall_distance > stats.fall_damage_height:
		blood_circle.take_damage(stats.fall_impact_damage)
		fsm.change_state("Stunned")
	fall_distance = 0.0


func reset_fall_distance() -> void:
	fall_distance = 0.0


func _update_hitbox_facing() -> void:
	if hitbox == null:
		return
	var shape := hitbox.get_child(0) as CollisionShape2D
	if shape == null:
		return
	shape.position.x = 16.0 * signf(facing)


func can_meditate() -> bool:
	return nearby_altar != null and nearby_altar.poem != null


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
	aim_pressed = Input.is_action_just_pressed("ability")
	aim_held = Input.is_action_pressed("ability")
	ability_pressed = Input.is_action_just_pressed("ability")
	interact_pressed = Input.is_action_just_pressed("interact")
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
