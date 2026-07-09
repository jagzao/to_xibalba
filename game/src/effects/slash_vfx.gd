extends AnimatedSprite2D
class_name SlashVFX
## VFX de corte de obsidiana. Construye frames desde carpeta y se autodestruye.

@export var lifetime: float = 0.4
@export var frames_root: String = "res://assets/sprites/vfx/slash/frames/slash"
@export var fps: float = 12.0

var _timer: float = 0.0


func _ready() -> void:
	sprite_frames = _build_frames()
	if sprite_frames != null and sprite_frames.has_animation("slash"):
		play("slash")
	else:
		push_warning("SlashVFX sin animación 'slash'.")


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= lifetime:
		queue_free()


func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	var root := DirAccess.open(frames_root)
	if root == null:
		push_warning("SlashVFX: no existe " + frames_root)
		return sf
	sf.add_animation("slash")
	sf.set_animation_speed("slash", fps)
	sf.set_animation_loop("slash", false)
	var files: PackedStringArray = root.get_files()
	files.sort()
	for f: String in files:
		if f.ends_with(".png"):
			sf.add_frame("slash", load(frames_root + "/" + f))
	return sf
