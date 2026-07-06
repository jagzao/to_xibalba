extends Node
class_name State
## Estado base de la FSM. Cada estado concreto es un nodo hijo de FiniteStateMachine.

signal finished(next_state_name: String)


func enter(_previous_state: String) -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
