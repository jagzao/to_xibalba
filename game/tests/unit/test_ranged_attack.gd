extends GutTest


class DummyTarget:
	extends Area2D
	var received: float = 0.0

	func take_hit(damage: float) -> void:
		received = damage


const SCENE: PackedScene = preload("res://src/entities/Hunahpu.tscn")

var c: Hunahpu


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	c.grounded = true
	c.time_since_grounded = 0.0


func test_shoot_spends_fixed_serenity_block() -> void:
	var p: ProjectileLight = c.ranged.shoot(Vector2.RIGHT)
	autofree(p)
	assert_not_null(p)
	assert_eq(c.data.current_serenity, 85.0, "-15.0 por disparo")


func test_shoot_fails_without_serenity() -> void:
	c.data.current_serenity = 10.0
	var p: ProjectileLight = c.ranged.shoot(Vector2.RIGHT)
	assert_null(p, "sin serenidad no hay balin")
	assert_eq(c.data.current_serenity, 10.0, "no gasta si falla")


func test_projectile_travels_straight_normalized() -> void:
	var p: ProjectileLight = c.ranged.shoot(Vector2(0.0, 10.0))
	autofree(p)
	p.set_physics_process(false)
	var start: Vector2 = p.position
	p._physics_process(1.0)
	assert_eq(p.position, start + Vector2(0.0, p.speed), "direccion normalizada")


func test_projectile_damages_target_and_dies() -> void:
	var p: ProjectileLight = c.ranged.shoot(Vector2.RIGHT)
	autofree(p)
	var target := DummyTarget.new()
	add_child_autofree(target)
	p._on_area_entered(target)
	assert_eq(target.received, p.damage)
	assert_true(p.is_queued_for_deletion())


func test_projectile_expires_by_lifetime() -> void:
	var p: ProjectileLight = c.ranged.shoot(Vector2.RIGHT)
	autofree(p)
	p.set_physics_process(false)
	p._physics_process(p.lifetime + 0.01)
	assert_true(p.is_queued_for_deletion())


func test_aim_state_plants_and_fires_on_release() -> void:
	c.ability_pressed = true
	c.fsm.current_state.physics_update(0.016)
	assert_eq(c.fsm.current_state.name, &"Aim")
	c.velocity.x = 99.0
	c.aim_held = true
	c.fsm.current_state.physics_update(0.016)
	assert_eq(c.velocity.x, 0.0, "plantado mientras apunta")
	assert_eq(c.fsm.current_state.name, &"Aim")
	c.aim_held = false
	c.aim_direction = Vector2.UP
	c.fsm.current_state.physics_update(0.016)
	assert_eq(c.fsm.current_state.name, &"Idle")
	assert_eq(c.data.current_serenity, 85.0, "disparo al soltar")
