extends Node2D
class_name CouncilPuzzleRoom
## Gestiona el puzzle de los 12 Señores.

signal puzzle_completed()
signal puzzle_failed()

@export var data: PlayerDataResource

var _lords: Array[DeceptiveLord] = []
var _completed: bool = false
var _real_leaders_found: int = 0


func register_lord(lord: DeceptiveLord) -> void:
	_lords.append(lord)


func interact_with(lord: DeceptiveLord) -> bool:
	if _completed:
		return true
	if lord.is_real() and lord.is_leader:
		_real_leaders_found += 1
		if _real_leaders_found >= 2:
			_completed = true
			puzzle_completed.emit()
		return true
	_fail_puzzle()
	return false


func _fail_puzzle() -> void:
	if data == null:
		return
	var loss: float = data.max_serenity * 0.5
	data.current_serenity = maxf(data.current_serenity - loss, 0.0)
	EventBus.serenity_changed.emit(data.current_serenity, data.max_serenity)
	puzzle_failed.emit()


func is_completed() -> bool:
	return _completed


func reveal_all() -> void:
	for lord: DeceptiveLord in _lords:
		lord.revealed = true
