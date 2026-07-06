extends GutTest


const SCENE: PackedScene = preload("res://src/entities/CharacterBase.tscn")

var character: CharacterBase


func before_each() -> void:
	character = SCENE.instantiate()
	add_child_autofree(character)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)


func test_shared_data_injected_to_all_components() -> void:
	assert_not_null(character.data)
	assert_eq(character.serenity.data, character.data)
	assert_eq(character.blood_circle.data, character.data)
	assert_eq(character.skulls.data, character.data)


func test_starts_in_idle() -> void:
	assert_eq(character.fsm.current_state.name, &"Idle")


func test_light_radius_follows_serenity() -> void:
	character.max_light_radius = 2.0
	character.data.current_serenity = 50.0
	character._update_light()
	assert_eq(character.light.texture_scale, 1.0)


func test_light_radius_critical_in_panic() -> void:
	character.max_light_radius = 2.0
	character.serenity.change(-100.0)
	character._update_light()
	assert_almost_eq(character.light.texture_scale, 0.1, 0.0001)


func test_empty_blood_circle_forces_stunned_state() -> void:
	character.blood_circle.take_damage(100.0)
	assert_eq(character.fsm.current_state.name, &"Stunned")
