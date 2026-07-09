extends "res://addons/gut/test.gd"


func test_boss_base_takes_damage() -> void:
	var boss: BossBase = load("res://src/entities/enemies/BossBase.tscn").instantiate()
	add_child_autofree(boss)
	boss.take_damage(50.0)
	assert_eq(boss.health, 150.0)
	assert_false(boss.is_dead())


func test_boss_base_dies_at_zero() -> void:
	var boss: BossBase = load("res://src/entities/enemies/BossBase.tscn").instantiate()
	add_child_autofree(boss)
	watch_signals(boss)
	boss.take_damage(200.0)
	assert_true(boss.is_dead())
	assert_signal_emitted(boss, "died")


func test_boss_base_hurtbox_exists() -> void:
	var boss: BossBase = load("res://src/entities/enemies/BossBase.tscn").instantiate()
	add_child_autofree(boss)
	var hurtbox := boss.get_node("Hurtbox") as Area2D
	assert_not_null(hurtbox)
	assert_true(hurtbox.get_child_count() > 0)
