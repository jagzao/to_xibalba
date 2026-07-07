extends GutTest
## Toda la suite corre SIN jugador en escena: prueba el desacoplamiento.


const SCENE: PackedScene = preload("res://src/ui/HUD.tscn")

var hud: HUD
var bus: Node


func before_each() -> void:
	hud = SCENE.instantiate()
	add_child_autofree(hud)
	bus = get_node("/root/EventBus")


func test_instances_clean_with_codex_hidden() -> void:
	assert_false(hud.codex_panel.visible)


func test_serenity_bar_follows_signal() -> void:
	bus.serenity_changed.emit(50.0, 100.0)
	assert_eq(hud.serenity_bar.value, 50.0)
	assert_eq(hud.serenity_bar.max_value, 100.0)


func test_blood_bar_follows_signal() -> void:
	bus.blood_circle_changed.emit(30.0, 100.0)
	assert_eq(hud.blood_bar.value, 30.0)


func test_skulls_render_data_driven() -> void:
	bus.skulls_changed.emit(1, 3)
	assert_eq(hud.skulls_box.get_child_count(), 3)
	assert_eq(hud.skulls_box.get_child(0).modulate.a, 1.0, "llena")
	assert_lt(hud.skulls_box.get_child(2).modulate.a, 1.0, "vacia")
	bus.skulls_changed.emit(2, 5)
	assert_eq(hud.skulls_box.get_child_count(), 5, "max no hardcodeado")


func test_panic_tints_serenity_bar_and_recovers() -> void:
	bus.panic_entered.emit()
	assert_ne(hud.serenity_bar.modulate, Color.WHITE)
	bus.panic_exited.emit()
	assert_eq(hud.serenity_bar.modulate, Color.WHITE)


func test_codex_shows_text_and_hides() -> void:
	bus.artifact_read_started.emit("XOLO_01", "No acabarán mis flores")
	assert_true(hud.codex_panel.visible)
	assert_eq(hud.codex_text.text, "No acabarán mis flores")
	bus.artifact_read_completed.emit()
	assert_false(hud.codex_panel.visible)


func test_second_read_repopulates_panel() -> void:
	bus.artifact_read_started.emit("A", "uno")
	bus.artifact_read_completed.emit()
	bus.artifact_read_started.emit("B", "dos")
	assert_true(hud.codex_panel.visible)
	assert_eq(hud.codex_text.text, "dos")


func test_all_signals_without_player_do_not_crash() -> void:
	bus.serenity_changed.emit(10.0, 100.0)
	bus.blood_circle_changed.emit(10.0, 100.0)
	bus.skulls_changed.emit(0, 3)
	bus.panic_entered.emit()
	bus.panic_exited.emit()
	bus.artifact_read_started.emit("X", "y")
	bus.artifact_read_completed.emit()
	assert_true(true, "HUD funciona sin CharacterBase en el arbol")
