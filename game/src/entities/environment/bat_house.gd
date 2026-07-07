extends Node2D
class_name BatHouse
## Zotzi-ha: Camazotz invulnerable; estar demasiado arriba de la cámara quita calaveras.

@export var data: PlayerDataResource
@export var damage_delay: float = 0.5
@export var camera_top_margin: float = -64.0

var active: bool = false
var _timer: float = 0.0


func activate(player_data: PlayerDataResource) -> void:
	data = player_data
	active = true
	set_physics_process(true)


func deactivate() -> void:
	active = false
	set_physics_process(false)
	_timer = 0.0


func _physics_process(delta: float) -> void:
	if not active or data == null:
		return
	var player := _find_player()
	if player == null:
		return
	var cam := get_viewport().get_camera_2d()
	# sin cámara (tests headless / escena suelta) el margen ES el umbral
	var top := camera_top_margin
	if cam != null:
		top = cam.global_position.y + camera_top_margin
	if player.global_position.y < top:
		_timer += delta
	else:
		_timer = 0.0
	if _timer >= damage_delay:
		if data.current_skulls > 0:
			data.current_skulls -= 1
		_timer = 0.0


func _find_player() -> CharacterBase:
	for c in get_tree().get_nodes_in_group("player"):
		if c is CharacterBase:
			return c
	return null
