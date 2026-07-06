extends GutTest


var comp: SerenityComponent
var bus: Node


func before_each() -> void:
	comp = SerenityComponent.new()
	comp.data = PlayerDataResource.new()
	add_child_autofree(comp)
	comp.set_physics_process(false)
	bus = get_node("/root/EventBus")
	watch_signals(bus)


func test_passive_decay_one_point_per_second() -> void:
	comp._physics_process(1.0)
	assert_eq(comp.data.current_serenity, 99.0)


func test_environment_multiplier_doubles_decay() -> void:
	comp.environment_multiplier = 2.0
	comp._physics_process(1.0)
	assert_eq(comp.data.current_serenity, 98.0)


func test_change_emits_serenity_changed_with_values() -> void:
	comp.change(-30.0)
	assert_signal_emitted_with_parameters(bus, "serenity_changed", [70.0, 100.0])


func test_panic_entered_emitted_when_drained() -> void:
	comp.change(-100.0)
	assert_signal_emitted(bus, "panic_entered")
	assert_true(comp.data.is_in_panic)


func test_panic_exited_emitted_on_restore() -> void:
	comp.change(-100.0)
	comp.restore_full()
	assert_signal_emitted(bus, "panic_exited")
	assert_false(comp.data.is_in_panic)
	assert_eq(comp.data.current_serenity, 100.0)


func test_no_panic_signal_without_transition() -> void:
	comp.change(-10.0)
	assert_signal_not_emitted(bus, "panic_entered")
	assert_signal_not_emitted(bus, "panic_exited")


func test_change_without_data_is_safe() -> void:
	comp.data = null
	comp.change(-10.0)
	assert_signal_not_emitted(bus, "serenity_changed")
