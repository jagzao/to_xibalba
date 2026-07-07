extends Area2D
class_name HeatHouse
## Chonay-ha: humo quita serenidad; plataformas porosas colapsan al contacto 1 s.

@export var data: PlayerDataResource
@export var smoke_drain_per_second: float = 3.0

var active: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func activate(player_data: PlayerDataResource) -> void:
	data = player_data
	active = true
	set_physics_process(true)
	monitoring = true


func deactivate() -> void:
	active = false
	monitoring = false
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not active or data == null:
		return
	data.current_serenity -= smoke_drain_per_second * delta


func _on_body_entered(body: Node2D) -> void:
	var platform := body.get_parent() as PorousPlatform
	if platform != null:
		platform.start_collapse()


func _on_body_exited(body: Node2D) -> void:
	var platform := body.get_parent() as PorousPlatform
	if platform != null:
		platform.cancel_collapse()
