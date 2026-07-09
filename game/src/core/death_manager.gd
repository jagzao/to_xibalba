extends Node
class_name DeathManager
## Gestiona muerte, gore, respawn y Game Over.

@export var data: PlayerDataResource
@export var player: CharacterBase
@export var gore: GoreEffect
@export var death_screen: DeathScreen

var _busy: bool = false


func _ready() -> void:
	var bus := _get_event_bus()
	if bus != null:
		bus.player_died.connect(_on_player_died)


func _on_player_died(origin: String) -> void:
	if _busy:
		return
	_busy = true
	if gore != null:
		gore.play(_origin_to_type(origin))
	if data == null:
		_busy = false
		return
	if data.current_skulls > 0:
		_respawn()
	else:
		_show_game_over()


func _origin_to_type(origin: String) -> GoreEffect.Type:
	match origin.to_lower():
		"blood", "":
			return GoreEffect.Type.BLOOD
		"skull", "jaguar", "bat":
			return GoreEffect.Type.SKULL
		"fall", "void":
			return GoreEffect.Type.FALL
		"fire", "heat":
			return GoreEffect.Type.FIRE
		"dark", "darkness":
			return GoreEffect.Type.DARKNESS
	return GoreEffect.Type.BLOOD


func _respawn() -> void:
	if data != null:
		data.current_skulls -= 1
	if player != null and data != null:
		player.global_position = data.respawn_position
	var bus := _get_event_bus()
	if bus != null:
		bus.respawn_started.emit()
	_busy = false


func _show_game_over() -> void:
	if death_screen != null:
		death_screen.show_game_over()
	var bus := _get_event_bus()
	if bus != null:
		bus.game_over.emit()
	_busy = false


func _get_event_bus() -> EventBus:
	var root := get_tree()
	if root == null:
		return null
	var bus := root.root.get_node_or_null("EventBus") as EventBus
	return bus
