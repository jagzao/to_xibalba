extends Node
class_name BloodCircleComponent
## Postura/armadura de impacto. Al vaciarse emite `emptied` (la FSM fuerza StunnedState).

signal emptied

@export var data: PlayerDataResource

@onready var _bus: Node = get_node("/root/EventBus")


func take_damage(amount: float) -> void:
	if data == null:
		return
	var was_empty: bool = data.current_blood_circle <= 0.0
	var is_empty: bool = data.take_blood_damage(amount)
	_bus.blood_circle_changed.emit(data.current_blood_circle, data.max_blood_circle)
	if is_empty and not was_empty:
		emptied.emit()


func restore(amount: float) -> void:
	if data == null:
		return
	data.current_blood_circle = clampf(
		data.current_blood_circle + amount, 0.0, data.max_blood_circle
	)
	_bus.blood_circle_changed.emit(data.current_blood_circle, data.max_blood_circle)
