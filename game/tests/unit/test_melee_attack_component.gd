extends GutTest


class DummyTarget:
	extends Area2D
	var received: float = 0.0

	func take_hit(damage: float) -> void:
		received = damage


const SCENE: PackedScene = preload("res://src/entities/Ixbalanque.tscn")

var c: Ixbalanque
var melee: MeleeAttackComponent


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	melee = c.melee
	melee.set_physics_process(false)


func test_attack_activates_hitbox() -> void:
	assert_false(c.hitbox.monitoring, "hitbox apagada por default")
	assert_true(melee.try_attack())
	assert_true(c.hitbox.monitoring)


func test_cooldown_blocks_second_attack() -> void:
	melee.try_attack()
	assert_false(melee.try_attack(), "en cooldown")
	melee.tick(melee.stats.cooldown + 0.01)
	assert_true(melee.try_attack(), "cooldown terminado")


func test_hitbox_deactivates_after_active_time() -> void:
	melee.try_attack()
	melee.tick(melee.stats.active_time + 0.01)
	assert_false(c.hitbox.monitoring)


func test_hit_forwards_damage_to_target() -> void:
	var target := DummyTarget.new()
	add_child_autofree(target)
	melee._on_area_entered(target)
	assert_eq(target.received, melee.stats.damage)


func test_hit_inside_absorption_window_restores_serenity() -> void:
	c.serenity.change(-10.0)
	c.time_since_dash = 1.0
	var target := DummyTarget.new()
	add_child_autofree(target)
	melee._on_area_entered(target)
	assert_eq(c.data.current_serenity, 92.0, "+2.0 por golpe post-dash")


func test_hit_outside_window_does_not_restore() -> void:
	c.serenity.change(-10.0)
	c.time_since_dash = 3.0
	var target := DummyTarget.new()
	add_child_autofree(target)
	melee._on_area_entered(target)
	assert_eq(c.data.current_serenity, 90.0)


func test_hit_confirmed_signal_emitted() -> void:
	watch_signals(melee)
	var target := DummyTarget.new()
	add_child_autofree(target)
	melee._on_area_entered(target)
	assert_signal_emitted(melee, "hit_confirmed")
