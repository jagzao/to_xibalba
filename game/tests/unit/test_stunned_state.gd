extends GutTest


var state: StunnedState


func before_each() -> void:
	state = StunnedState.new()
	add_child_autofree(state)
	watch_signals(state)
	state.enter("Idle")


func test_default_duration_is_exactly_1_5() -> void:
	assert_eq(state.duration, 1.5)


func test_not_finished_before_duration() -> void:
	state.physics_update(1.0)
	assert_signal_not_emitted(state, "finished")


func test_finished_after_duration_returns_to_idle() -> void:
	state.physics_update(1.0)
	state.physics_update(0.5)
	assert_signal_emitted_with_parameters(state, "finished", ["Idle"])


func test_reenter_resets_timer() -> void:
	state.physics_update(1.4)
	state.enter("Idle")
	state.physics_update(1.0)
	assert_signal_not_emitted(state, "finished")
