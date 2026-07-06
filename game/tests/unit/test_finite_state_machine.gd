extends GutTest


class DummyState:
	extends State
	var entered: int = 0
	var exited: int = 0
	var last_previous: String = ""
	var last_delta: float = -1.0

	func enter(previous_state: String) -> void:
		entered += 1
		last_previous = previous_state

	func exit() -> void:
		exited += 1

	func physics_update(delta: float) -> void:
		last_delta = delta


var fsm: FiniteStateMachine
var idle: DummyState
var move: DummyState


func before_each() -> void:
	fsm = FiniteStateMachine.new()
	idle = DummyState.new()
	idle.name = "Idle"
	move = DummyState.new()
	move.name = "Move"
	fsm.add_child(idle)
	fsm.add_child(move)
	add_child_autofree(fsm)
	fsm.set_physics_process(false)


func test_initial_state_defaults_to_first_child_and_enters() -> void:
	assert_eq(fsm.current_state, idle)
	assert_eq(idle.entered, 1)
	assert_eq(idle.last_previous, "")


func test_change_state_exits_previous_and_enters_next() -> void:
	fsm.change_state("Move")
	assert_eq(fsm.current_state, move)
	assert_eq(idle.exited, 1)
	assert_eq(move.entered, 1)
	assert_eq(move.last_previous, "Idle")


func test_change_to_unknown_or_same_state_is_noop() -> void:
	fsm.change_state("NoExiste")
	assert_eq(fsm.current_state, idle)
	fsm.change_state("Idle")
	assert_eq(idle.entered, 1, "re-entrar al mismo estado prohibido")
	assert_eq(idle.exited, 0)


func test_finished_signal_triggers_transition() -> void:
	idle.finished.emit("Move")
	assert_eq(fsm.current_state, move)


func test_physics_delegates_only_to_current_state() -> void:
	fsm._physics_process(0.25)
	assert_eq(idle.last_delta, 0.25)
	assert_eq(move.last_delta, -1.0)
