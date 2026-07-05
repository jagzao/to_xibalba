extends GutTest


var data: PlayerDataResource


func before_each() -> void:
	data = PlayerDataResource.new()


func test_defaults() -> void:
	assert_eq(data.max_serenity, 100.0)
	assert_eq(data.current_serenity, 100.0)
	assert_eq(data.max_blood_circle, 100.0)
	assert_eq(data.current_blood_circle, 100.0)
	assert_eq(data.max_skulls, 3)
	assert_eq(data.current_skulls, 3)
	assert_false(data.is_in_panic)


func test_light_radius_formula() -> void:
	data.current_serenity = 50.0
	assert_eq(data.get_light_radius(200.0), 100.0)
	data.current_serenity = 100.0
	assert_eq(data.get_light_radius(200.0), 200.0)


func test_light_radius_in_panic_is_critical_minimum() -> void:
	data.change_serenity(-100.0)
	assert_true(data.is_in_panic)
	assert_eq(data.get_light_radius(200.0), 0.1)


func test_serenity_clamped_and_panic_transition() -> void:
	var changed: bool = data.change_serenity(-150.0)
	assert_true(changed, "entrar en panico reporta transicion")
	assert_eq(data.current_serenity, 0.0)
	assert_true(data.is_in_panic)
	changed = data.change_serenity(-10.0)
	assert_false(changed, "seguir en panico no es transicion")
	changed = data.change_serenity(100.0)
	assert_true(changed, "salir de panico reporta transicion")
	assert_false(data.is_in_panic)


func test_serenity_does_not_exceed_max() -> void:
	data.change_serenity(50.0)
	assert_eq(data.current_serenity, 100.0)


func test_blood_damage_normal() -> void:
	var stunned: bool = data.take_blood_damage(40.0)
	assert_eq(data.current_blood_circle, 60.0)
	assert_false(stunned)


func test_blood_damage_in_panic_multiplied_by_1_5() -> void:
	data.change_serenity(-100.0)
	data.take_blood_damage(40.0)
	assert_eq(data.current_blood_circle, 40.0)


func test_blood_empty_triggers_stun() -> void:
	var stunned: bool = data.take_blood_damage(100.0)
	assert_true(stunned)
	assert_eq(data.current_blood_circle, 0.0)


func test_lose_skull_and_death() -> void:
	assert_false(data.lose_skull())
	assert_false(data.lose_skull())
	assert_true(data.lose_skull(), "tercera calavera = muerte")
	assert_eq(data.current_skulls, 0)
	assert_false(data.current_skulls < 0)
