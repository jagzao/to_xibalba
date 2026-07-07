extends Node2D
class_name DeceptiveLord
## Señor de la Corte: real o maniquí de madera.

enum Type { REAL, MANNEQUIN }

@export var lord_type: Type = Type.MANNEQUIN
@export var is_leader: bool = false
@export var reveal_threshold: float = 0.75

var revealed: bool = false
var _blink_timer: float = 0.0


func update_reveal(serenity_ratio: float, delta: float) -> void:
	if serenity_ratio >= reveal_threshold:
		revealed = true
	else:
		revealed = false
		_blink_timer += delta


func is_real() -> bool:
	return lord_type == Type.REAL


func just_blinked() -> bool:
	# Simula parpadeo cada 10 s: devuelve true en el frame del parpadeo.
	var blinked: bool = _blink_timer >= 10.0
	if blinked:
		_blink_timer = 0.0
	return blinked
