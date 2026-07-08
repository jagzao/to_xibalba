extends Node
class_name DeathManager
## Gestiona muerte, gore, respawn y Game Over.

@export var data: PlayerDataResource
@export var player: CharacterBase
@export var gore: GoreEffect
@export var death_screen: DeathScreen

var _busy: bool = false


func _ready() -> void:
	if Engine.has_singleton("EventBus"):
		var bus := Engine.get_singleton("EventBus") as EventBus
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
	if Engine.has_singleton("EventBus"):
		var bus := Engine.get_singleton("EventBus") as EventBus
		bus.respawn_started.emit()
	_busy = false


func _show_game_over() -> void:
	if death_screen != null:
		death_screen.show_game_over()
	if Engine.has_singleton("EventBus"):
		var bus := Engine.get_singleton("EventBus") as EventBus
		bus.game_over.emit()
	_busy = false
