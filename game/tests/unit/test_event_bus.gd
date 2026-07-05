extends GutTest
## Verifica el contrato de señales del EventBus (autoload).


func _bus() -> Node:
	return get_node("/root/EventBus")


func test_autoload_exists() -> void:
	assert_not_null(_bus())


func test_signal_contract() -> void:
	var required: Array[String] = [
		"serenity_changed",
		"blood_circle_changed",
		"skulls_changed",
		"panic_entered",
		"panic_exited",
		"artifact_read_started",
		"artifact_read_completed",
		"balance_changed",
	]
	for sig: String in required:
		assert_true(_bus().has_signal(sig), "falta señal: " + sig)


func test_signals_emit_payload() -> void:
	var bus: Node = _bus()
	watch_signals(bus)
	bus.serenity_changed.emit(50.0, 100.0)
	assert_signal_emitted_with_parameters(bus, "serenity_changed", [50.0, 100.0])
	bus.skulls_changed.emit(2, 3)
	assert_signal_emitted_with_parameters(bus, "skulls_changed", [2, 3])
	bus.panic_entered.emit()
	assert_signal_emitted(bus, "panic_entered")
