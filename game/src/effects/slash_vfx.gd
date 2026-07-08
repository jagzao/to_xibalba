extends AnimatedSprite2D
class_name SlashVFX
## VFX de corte de obsidiana. Se autodestruye tras su animación.

@export var lifetime: float = 0.4

var _timer: float = 0.0


func _ready() -> void:
	if sprite_frames != null and sprite_frames.has_animation("slash"):
		play("slash")
	else:
		push_warning("SlashVFX sin animación 'slash'.")


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= lifetime:
		queue_free()
