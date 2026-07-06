extends CharacterBody2D
class_name CharacterBase
## Base común de los gemelos. Inyecta el PlayerDataResource compartido a los
## componentes y traduce Serenidad → radio de PointLight2D.

@export var data: PlayerDataResource
@export var max_light_radius: float = 1.0

@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var serenity: SerenityComponent = $SerenityComponent
@onready var blood_circle: BloodCircleComponent = $BloodCircleComponent
@onready var skulls: SkullsComponent = $SkullsComponent
@onready var light: PointLight2D = $CharacterVisuals/PointLight2D


func _ready() -> void:
	if data == null:
		data = PlayerDataResource.new()
	serenity.data = data
	blood_circle.data = data
	skulls.data = data
	blood_circle.emptied.connect(_on_blood_circle_emptied)


func _physics_process(_delta: float) -> void:
	light.texture_scale = data.get_light_radius(max_light_radius)


func _on_blood_circle_emptied() -> void:
	fsm.change_state("Stunned")
