extends Node
class_name SkullsComponent
## Calaveras de Vida. Daño directo que ignora el Círculo de Sangre.

signal died

@export var data: PlayerDataResource

@onready var _bus: Node = get_node("/root/EventBus")


func lose_skull() -> void:
	if data == null or data.current_skulls <= 0:
		return
	var dead: bool = data.lose_skull()
	_bus.skulls_changed.emit(data.current_skulls, data.max_skulls)
	if dead:
		if _bus.has_signal("player_died"):
			_bus.player_died.emit("skull")
		died.emit()
