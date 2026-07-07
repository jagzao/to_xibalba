extends "res://addons/gut/test.gd"

var data: PlayerDataResource
var door: HouseDoor
var character: CharacterBase


func before_each() -> void:
	data = PlayerDataResource.new()
	data.max_serenity = 100.0
	data.current_serenity = 100.0
	data.max_blood_circle = 100.0
	data.current_blood_circle = 100.0
	data.skulls = 3

	door = HouseDoor.new()
	door.data = data
	add_child_autofree(door)

	character = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	character.set_physics_process(false)
	add_child_autofree(character)


func after_each() -> void:
	data = null


func test_door_saves_respawn_position() -> void:
	character.global_position = Vector2(123, 456)
	door._on_body_entered(character)
	assert_eq(data.respawn_position, Vector2(123, 456))
	assert_false(data.has_codex_fragment)


func test_door_blocks_exit_without_fragment() -> void:
	assert_false(door.can_exit())


func test_door_allows_exit_with_fragment() -> void:
	data.has_codex_fragment = true
	assert_true(door.can_exit())


func test_dark_house_torch_drains_serenity() -> void:
	var dark := DarkHouse.new()
	add_child_autofree(dark)
	dark.torch_drain_per_second = 10.0
	dark.activate(data)
	dark.set_torch_lit(true)
	dark._physics_process(1.0)
	assert_eq(data.current_serenity, 90.0)


func test_dark_house_death_at_zero_serenity() -> void:
	var dark := DarkHouse.new()
	add_child_autofree(dark)
	dark.torch_drain_per_second = 100.0
	dark.activate(data)
	dark.set_torch_lit(true)
	dark._physics_process(1.0)
	assert_eq(data.current_skulls, 0)


func test_cold_house_drains_blood_after_delay() -> void:
	var cold := ColdHouse.new()
	add_child_autofree(cold)
	cold.freeze_delay = 2.0
	cold.blood_drain_per_second = 20.0
	cold.activate(data)
	cold._physics_process(2.0)
	assert_eq(data.current_blood_circle, 100.0)
	cold._physics_process(1.0)
	assert_eq(data.current_blood_circle, 80.0)


func test_cold_house_fire_stone_resets_timer() -> void:
	var cold := ColdHouse.new()
	add_child_autofree(cold)
	cold.freeze_delay = 2.0
	cold.activate(data)
	cold._physics_process(1.5)
	cold.touch_fire_stone()
	cold._physics_process(1.5)
	assert_eq(data.current_blood_circle, 100.0)


func test_jaguar_house_contact_loses_skull() -> void:
	var jaguar := JaguarHouse.new()
	add_child_autofree(jaguar)
	jaguar.activate(data)
	jaguar._on_body_entered(character)
	assert_eq(data.current_skulls, 2)


func test_bat_house_above_camera_loses_skull() -> void:
	var bat := BatHouse.new()
	add_child_autofree(bat)
	bat.damage_delay = 0.5
	bat.camera_top_margin = 32.0
	character.add_to_group("player")
	bat.activate(data)
	bat._physics_process(0.6)
	assert_eq(data.current_skulls, 2)


func test_knife_house_drains_blood_and_stuns() -> void:
	var knife := KnifeHouse.new()
	add_child_autofree(knife)
	knife.activate(data)
	knife._on_body_entered(character)
	assert_eq(data.current_blood_circle, 0.0)
	assert_eq(character.fsm.current_state.name, &"Stunned")


func test_knife_house_dash_avoids_damage() -> void:
	var knife := KnifeHouse.new()
	add_child_autofree(knife)
	knife.activate(data)
	character.fsm.change_state("Dash")
	knife._on_body_entered(character)
	assert_eq(data.current_blood_circle, 100.0)


func test_heat_house_smoke_drains_serenity() -> void:
	var heat := HeatHouse.new()
	add_child_autofree(heat)
	heat.smoke_drain_per_second = 6.0
	heat.activate(data)
	heat._physics_process(1.0)
	assert_eq(data.current_serenity, 94.0)


func test_porous_platform_collapses() -> void:
	var platform: PorousPlatform = load("res://src/entities/environment/porous_platform.gd").new()
	add_child_autofree(platform)
	platform.collapse_time = 0.3
	platform.start_collapse()
	platform._physics_process(0.3)
	assert_true(platform.is_queued_for_deletion())


func test_porous_platform_cancel_resets() -> void:
	var platform: PorousPlatform = load("res://src/entities/environment/porous_platform.gd").new()
	add_child_autofree(platform)
	platform.collapse_time = 0.3
	platform.start_collapse()
	platform._physics_process(0.1)
	platform.cancel_collapse()
	assert_false(platform.is_queued_for_deletion())


func test_codex_fragment_grants_flag() -> void:
	var fragment := CodexFragment.new()
	add_child_autofree(fragment)
	fragment.data = data
	fragment._on_body_entered(character)
	assert_true(data.has_codex_fragment)
	assert_true(fragment.is_queued_for_deletion())
