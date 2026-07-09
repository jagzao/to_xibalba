extends Control
class_name MainMenu
## Menú principal: selección de gemelo e inicio de partida.

const WORLD_SCENE := "res://src/scenes/World.tscn"

@onready var hunahpu_button: Button = %HunahpuButton
@onready var ixbalanque_button: Button = %IxbalanqueButton


func _ready() -> void:
	hunahpu_button.pressed.connect(_on_hunahpu_pressed)
	ixbalanque_button.pressed.connect(_on_ixbalanque_pressed)


func _on_hunahpu_pressed() -> void:
	_start_game("hunahpu")


func _on_ixbalanque_pressed() -> void:
	_start_game("ixbalanque")


func _start_game(twin: String) -> void:
	GameSession.selected_twin = twin
	get_tree().change_scene_to_file(WORLD_SCENE)
