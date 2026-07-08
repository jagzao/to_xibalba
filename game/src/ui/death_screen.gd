extends Control
class_name DeathScreen
## Pantalla de muerte/Game Over con fade negro.

signal fade_finished

@export var game_over_scene: PackedScene

var _overlay: ColorRect


func _ready() -> void:
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 0.0
	add_child(_overlay)


func fade_out(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, duration)
	tween.tween_callback(func():
		fade_finished.emit()
	)


func fade_in(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(func():
		fade_finished.emit()
	)


func show_game_over() -> void:
	_overlay.modulate.a = 1.0
	if game_over_scene != null:
		get_tree().change_scene_to_packed(game_over_scene)
