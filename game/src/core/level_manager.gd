extends Node2D
class_name LevelManager
## Orquesta una instancia jugable: jugador, HUD, muerte y cámara.

const HUNAHPU_SCENE := "res://src/entities/Hunahpu.tscn"
const IXBALANQUE_SCENE := "res://src/entities/Ixbalanque.tscn"
const HUD_SCENE := "res://src/ui/HUD.tscn"

@export var selected_twin: String = "hunahpu"
@export var spawn_position: Vector2 = Vector2(0, 0)

var player: CharacterBase = null
var data: PlayerDataResource = null


func _ready() -> void:
	selected_twin = GameSession.selected_twin
	data = PlayerDataResource.new()
	data.respawn_position = spawn_position
	_spawn_player()
	_spawn_hud()
	_spawn_death_manager()
	player.global_position = spawn_position


func _spawn_player() -> void:
	var path := HUNAHPU_SCENE if selected_twin == "hunahpu" else IXBALANQUE_SCENE
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("LevelManager: no pudo cargar escena de gemelo %s" % path)
		return
	player = scene.instantiate() as CharacterBase
	if player == null:
		push_error("LevelManager: escena instanciada no es CharacterBase")
		return
	player.data = data
	add_child(player)
	# ponytail: la cámara sigue al jugador; límites por sala los maneja CameraLimits
	var camera := Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)


func _spawn_hud() -> void:
	var scene := load(HUD_SCENE) as PackedScene
	if scene == null:
		return
	var hud := scene.instantiate() as CanvasLayer
	if hud != null:
		add_child(hud)


func _spawn_death_manager() -> void:
	var dm := DeathManager.new()
	dm.name = "DeathManager"
	dm.data = data
	dm.player = player
	var gore := GoreEffect.new()
	gore.name = "GoreEffect"
	add_child(gore)
	dm.gore = gore
	add_child(dm)
