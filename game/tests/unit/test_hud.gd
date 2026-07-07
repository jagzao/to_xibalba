extends GutTest
## Verifica HUD reactivo por EventBus sin referencias al jugador.

const HUD_SCENE: PackedScene = preload("res://src/ui/HUD.tscn")

var hud: CanvasLayer


func before_each() -> void:
	hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)


func test_hud_instantiates_and_codex_hidden() -> void:
	assert_not_null(hud)
	assert_false(hud.codex_panel.visible)


func test_serenity_changed_updates_bar() -> void:
	EventBus.serenity_changed.emit(50.0, 100.0)
	assert_eq(hud.serenity_bar.max_value, 100.0)
	assert_eq(hud.serenity_bar.value, 50.0)


func test_blood_circle_changed_updates_bar() -> void:
	EventBus.blood_circle_changed.emit(30.0, 100.0)
	assert_eq(hud.blood_bar.max_value, 100.0)
	assert_eq(hud.blood_bar.value, 30.0)


func test_skulls_changed_renders_filled_and_empty() -> void:
	EventBus.skulls_changed.emit(1, 3)
	var text: String = hud.skulls_container.text
	assert_eq(text.count("☠"), 1)
	assert_eq(text.count("○"), 2)


func test_panic_changes_serenity_modulate() -> void:
	var white := Color.WHITE
	assert_eq(hud.serenity_bar.modulate, white)
	EventBus.panic_entered.emit()
	assert_ne(hud.serenity_bar.modulate, white)
	EventBus.panic_exited.emit()
	assert_eq(hud.serenity_bar.modulate, white)


func test_codex_shows_on_artifact_started_and_hides_on_completed() -> void:
	EventBus.artifact_read_started.emit("XOLO_01", "Canto de la Huida")
	assert_true(hud.codex_panel.visible)
	assert_eq(hud.codex_title.text, "XOLO_01")
	assert_eq(hud.codex_content.text, "Canto de la Huida")
	EventBus.artifact_read_completed.emit()
	assert_false(hud.codex_panel.visible)


func test_second_reading_repoulate_codex() -> void:
	EventBus.artifact_read_started.emit("ONE", "first")
	EventBus.artifact_read_completed.emit()
	EventBus.artifact_read_started.emit("TWO", "second")
	assert_eq(hud.codex_title.text, "TWO")
	assert_eq(hud.codex_content.text, "second")


func test_hud_has_no_player_references() -> void:
	var source: String = load("res://src/ui/hud.gd").source_code
	assert_eq(source.find("get_node(\"/root/Player\")"), -1)
	assert_eq(source.find("CharacterBase"), -1)
	assert_eq(source.find("Player"), -1)
