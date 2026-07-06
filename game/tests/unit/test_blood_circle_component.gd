extends GutTest


var comp: BloodCircleComponent
var bus: Node


func before_each() -> void:
	comp = BloodCircleComponent.new()
	comp.data = PlayerDataResource.new()
	add_child_autofree(comp)
	bus = get_node("/root/EventBus")
	watch_signals(bus)
	watch_signals(comp)


func test_damage_emits_blood_circle_changed() -> void:
	comp.take_damage(30.0)
	assert_signal_emitted_with_parameters(bus, "blood_circle_changed", [70.0, 100.0])
	assert_signal_not_emitted(comp, "emptied")


func test_emptied_emitted_once_when_drained() -> void:
	comp.take_damage(100.0)
	assert_signal_emitted(comp, "emptied")
	comp.take_damage(10.0)
	assert_signal_emit_count(comp, "emptied", 1, "sin re-emision estando en 0")


func test_panic_multiplies_damage() -> void:
	comp.data.change_serenity(-100.0)
	comp.take_damage(40.0)
	assert_eq(comp.data.current_blood_circle, 40.0)


func test_restore_clamped_to_max() -> void:
	comp.take_damage(50.0)
	comp.restore(80.0)
	assert_eq(comp.data.current_blood_circle, 100.0)
	assert_signal_emitted_with_parameters(bus, "blood_circle_changed", [100.0, 100.0])
