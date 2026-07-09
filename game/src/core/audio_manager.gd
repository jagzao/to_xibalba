extends Node
## Autoload de audio: música por capas y SFX posicionales. Placeholders por ahora.

enum MusicLayer { AMBIENT, TENSION, BOSS }

@export var master_bus: StringName = "Master"
@export var music_bus: StringName = "Music"
@export var sfx_bus: StringName = "SFX"

var _music_players: Dictionary[MusicLayer, AudioStreamPlayer] = {}
var _sfx_streams: Dictionary[StringName, AudioStream] = {}


func _ready() -> void:
	_bus_setup()
	_register_default_sfx()
	EventBus.panic_entered.connect(_on_panic_entered)
	EventBus.panic_exited.connect(_on_panic_exited)
	EventBus.player_died.connect(_on_player_died)
	EventBus.balance_changed.connect(_on_balance_changed)
	EventBus.artifact_read_started.connect(_on_artifact_read_started)
	EventBus.artifact_read_completed.connect(_on_artifact_read_completed)


func _register_default_sfx() -> void:
	register_sfx(&"slash", preload("res://assets/audio/sfx/slash.wav"))
	register_sfx(&"projectile", preload("res://assets/audio/sfx/projectile.wav"))
	register_sfx(&"ball_parry", preload("res://assets/audio/sfx/ball_parry.wav"))
	register_sfx(&"ball_bounce", preload("res://assets/audio/sfx/ball_bounce.wav"))
	register_sfx(&"dash", preload("res://assets/audio/sfx/dash.wav"))
	register_sfx(&"hit_blood", preload("res://assets/audio/sfx/hit_blood.wav"))
	register_sfx(&"hit_skull", preload("res://assets/audio/sfx/hit_skull.wav"))
	register_sfx(&"altar_read", preload("res://assets/audio/sfx/altar_read.wav"))


func _bus_setup() -> void:
	for bus_name: StringName in [music_bus, sfx_bus]:
		var idx := AudioServer.get_bus_index(bus_name)
		if idx == -1:
			AudioServer.add_bus(-1)
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func play_music(layer: MusicLayer, stream: AudioStream, volume_db: float = -6.0) -> void:
	var player := _music_players.get(layer) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = "Music_%d" % layer
		player.bus = music_bus
		add_child(player)
		_music_players[layer] = player
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func stop_music(layer: MusicLayer) -> void:
	var player := _music_players.get(layer) as AudioStreamPlayer
	if player != null:
		player.stop()


func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = -6.0) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = sfx_bus
	player.position = position
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func register_sfx(name: StringName, stream: AudioStream) -> void:
	_sfx_streams[name] = stream


func play_sfx_named(name: StringName, position: Vector2 = Vector2.ZERO, volume_db: float = -6.0) -> void:
	var stream := _sfx_streams.get(name) as AudioStream
	if stream != null:
		play_sfx(stream, position, volume_db)


func _on_panic_entered() -> void:
	stop_music(MusicLayer.AMBIENT)


func _on_panic_exited() -> void:
	pass


func _on_player_died(_origin: String) -> void:
	stop_music(MusicLayer.BOSS)


func _on_balance_changed(_value: float) -> void:
	pass


func _on_artifact_read_started(_id: String, _text: String) -> void:
	stop_music(MusicLayer.TENSION)


func _on_artifact_read_completed() -> void:
	pass
