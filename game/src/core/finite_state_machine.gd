extends Node
class_name FiniteStateMachine
## Gestor de estados. Hijos = nodos State. Un solo estado activo a la vez.

@export var initial_state: State

var current_state: State
var _states: Dictionary[String, State] = {}


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			_states[child.name.to_lower()] = child
			child.actor = get_parent()
			child.finished.connect(change_state)
	if initial_state == null and not _states.is_empty():
		initial_state = get_child(0) as State
	if initial_state != null:
		current_state = initial_state
		current_state.enter("")


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.handle_input(event)


func change_state(state_name: String) -> void:
	var next: State = _states.get(state_name.to_lower())
	if next == null or next == current_state:
		return
	var previous: String = current_state.name if current_state != null else ""
	if current_state != null:
		current_state.exit()
	current_state = next
	current_state.enter(previous)
