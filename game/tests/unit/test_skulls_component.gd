extends GutTest


var comp: SkullsComponent
var bus: Node


func before_each() -> void:
	comp = SkullsComponent.new()
	comp.data = PlayerDataResource.new()
	add_child_autofree(comp)
	bus = get_node("/root/EventBus")
	watch_signals(bus)
	watch_signals(comp)


func test_lose_skull_emits_skulls_changed() -> void:
	comp.lose_skull()
	assert_signal_emitted_with_parameters(bus, "skulls_changed", [2, 3])
	assert_signal_not_emitted(comp, "died")


func test_died_emitted_at_zero_skulls_once() -> void:
	comp.lose_skull()
	comp.lose_skull()
	comp.lose_skull()
	assert_signal_emitted(comp, "died")
	comp.lose_skull()
	assert_signal_emit_count(comp, "died", 1, "muerto no vuelve a morir")
	assert_signal_emit_count(bus, "skulls_changed", 3)
