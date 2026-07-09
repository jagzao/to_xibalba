extends AnimatedSprite2D
class_name SpriteAnimator
## Construye SpriteFrames desde carpetas de frames sueltos
## (frames_root/{anim}/NN.png) y sigue la FSM del actor. Flip por facing.

const STATE_TO_ANIM: Dictionary[String, String] = {
	"idle": "idle",
	"move": "run",
	"dash": "dash",
	"jump": "jump_fall",
	"fall": "jump_fall",
	"panic": "panic",
	"stunned": "hit",
	"aim": "aim",
	"meditating": "meditate",
}

@export var frames_root: String = ""
@export var loop_anims: PackedStringArray = ["idle", "run", "panic"]
@export var fps: float = 8.0

var _character: CharacterBase


func _ready() -> void:
	_character = get_node("../..") as CharacterBase
	sprite_frames = _build_frames()
	if _character == null:
		return
	# no usar _character.fsm: los @onready del padre aún no corren
	var fsm := _character.get_node("FiniteStateMachine") as FiniteStateMachine
	if fsm == null:
		return
	fsm.state_changed.connect(_on_state_changed)
	if fsm.current_state != null:
		_on_state_changed("", fsm.current_state.name)


func _process(_delta: float) -> void:
	if _character != null and _character.facing != 0.0:
		flip_h = _character.facing < 0.0


func _on_state_changed(_previous_name: String, next_name: String) -> void:
	if sprite_frames == null:
		return
	var anim: String = STATE_TO_ANIM.get(next_name.to_lower(), "idle")
	if not sprite_frames.has_animation(anim):
		# gemelo sin esa animación: stun degrada a panic, el resto a idle
		anim = "panic" if anim == "hit" else "idle"
	if sprite_frames.has_animation(anim):
		play(anim)


func _build_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	var root := DirAccess.open(frames_root)
	if root == null:
		push_warning("SpriteAnimator: no existe " + frames_root)
		return sf
	for anim: String in root.get_directories():
		if not sf.has_animation(anim):
			sf.add_animation(anim)
		sf.set_animation_speed(anim, fps)
		sf.set_animation_loop(anim, anim in loop_anims)
		var anim_dir := DirAccess.open(frames_root + "/" + anim)
		if anim_dir == null:
			continue
		var files: PackedStringArray = anim_dir.get_files()
		files.sort()
		for f: String in files:
			if f.ends_with(".png"):
				sf.add_frame(anim, load(frames_root + "/" + anim + "/" + f))
	return sf
