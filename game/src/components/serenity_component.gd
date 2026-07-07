extends Node
class_name SerenityComponent
## Envuelve PlayerDataResource: decay pasivo de Serenidad y emisión al EventBus.

@export var data: PlayerDataResource
@export var decay_rate: float = 1.0

## Modificador de zona: Ríos de Sangre = 2.0, humo Casa del Calor = 3.0, etc.
var environment_multiplier: float = 1.0

@onready var _bus: Node = get_node("/root/EventBus")


func _physics_process(delta: float) -> void:
	change(-decay_rate * environment_multiplier * delta)


func change(amount: float) -> void:
	if data == null:
		return
	var panic_transition: bool = data.change_serenity(amount)
	_bus.serenity_changed.emit(data.current_serenity, data.max_serenity)
	if panic_transition:
		if data.is_in_panic:
			_bus.panic_entered.emit()
		else:
			_bus.panic_exited.emit()


func restore_full() -> void:
	if data != null:
		change(data.max_serenity)


func set_multiplier(multiplier: float) -> void:
	environment_multiplier = multiplier

