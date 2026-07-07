extends GutTest
## Verifica separación de gemelos: Hunahpú = ranged, Ixbalanqué = melee.

const HUNAHPU: PackedScene = preload("res://src/entities/Hunahpu.tscn")
const IXBALANQUE: PackedScene = preload("res://src/entities/Ixbalanque.tscn")
const BASE: PackedScene = preload("res://src/entities/CharacterBase.tscn")


func test_hunahpu_instantiates_with_ranged_not_melee() -> void:
	var h: Hunahpu = HUNAHPU.instantiate()
	add_child_autofree(h)
	assert_not_null(h.ranged)
	assert_null(h.melee)
	assert_true(h.ability is HunahpuAbility)


func test_ixbalanque_instantiates_with_melee_not_ranged() -> void:
	var i: Ixbalanque = IXBALANQUE.instantiate()
	add_child_autofree(i)
	assert_not_null(i.melee)
	assert_null(i.ranged)
	assert_true(i.ability is IxbalanqueAbility)


func test_character_base_has_no_attack_components() -> void:
	var c: CharacterBase = BASE.instantiate()
	add_child_autofree(c)
	assert_null(c.melee)
	assert_null(c.ranged)
	assert_null(c.ability)


func test_hunahpu_ability_enters_aim_with_serenity() -> void:
	var h: Hunahpu = HUNAHPU.instantiate()
	add_child_autofree(h)
	h.set_physics_process(false)
	h.serenity.set_physics_process(false)
	assert_eq(h.fsm.current_state.name, &"Idle")
	h.grounded = true
	h.ability_pressed = true
	h.ability.execute_ability()
	assert_eq(h.fsm.current_state.name, &"Aim")


func test_hunahpu_ability_blocked_without_serenity() -> void:
	var h: Hunahpu = HUNAHPU.instantiate()
	add_child_autofree(h)
	h.set_physics_process(false)
	h.serenity.set_physics_process(false)
	h.data.current_serenity = 0.0
	h.ability_pressed = true
	h.ability.execute_ability()
	assert_eq(h.fsm.current_state.name, &"Idle")


func test_ixbalanque_ability_enters_dash() -> void:
	var i: Ixbalanque = IXBALANQUE.instantiate()
	add_child_autofree(i)
	i.set_physics_process(false)
	i.serenity.set_physics_process(false)
	assert_eq(i.fsm.current_state.name, &"Idle")
	i.ability_pressed = true
	i.ability.execute_ability()
	assert_eq(i.fsm.current_state.name, &"Dash")


func test_ixbalanque_dash_has_iframes() -> void:
	var i: Ixbalanque = IXBALANQUE.instantiate()
	add_child_autofree(i)
	i.set_physics_process(false)
	i.serenity.set_physics_process(false)
	i.fsm.change_state("Dash")
	assert_false(i.hurtbox.monitoring)


func test_ixbalanque_absorption_post_dash() -> void:
	var i: Ixbalanque = IXBALANQUE.instantiate()
	add_child_autofree(i)
	i.set_physics_process(false)
	i.serenity.set_physics_process(false)
	i.data.current_serenity = 50.0
	i.time_since_dash = 0.5
	var target: Area2D = Area2D.new()
	target.set_script(load("res://tests/unit/test_melee_attack_component.gd").get_script())
	# Melee check solo requiere que el target tenga take_hit; usamos body real más adelante.
	assert_true(i.melee.try_attack())
	i.melee._on_area_entered(target)
	assert_eq(i.data.current_serenity, 52.0)
	target.queue_free()


func test_twins_share_base_components() -> void:
	var h: Hunahpu = HUNAHPU.instantiate()
	var i: Ixbalanque = IXBALANQUE.instantiate()
	add_child_autofree(h)
	add_child_autofree(i)
	assert_not_null(h.data)
	assert_not_null(i.data)
	assert_not_null(h.serenity)
	assert_not_null(i.serenity)
	assert_not_null(h.blood_circle)
	assert_not_null(i.blood_circle)
	assert_not_null(h.skulls)
	assert_not_null(i.skulls)
