extends GutTest


const SCENE: PackedScene = preload("res://src/entities/CharacterBase.tscn")

var c: CharacterBase


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	c.grounded = true
	c.time_since_grounded = 0.0


func _tick(delta: float = 0.016) -> void:
	c.fsm.current_state.physics_update(delta)


func test_zero_serenity_forces_panic_from_any_movement_state() -> void:
	for start: String in ["Idle", "Move", "Jump", "Fall"]:
		c.fsm.change_state(start)
		c.serenity.change(-200.0)
		_tick()
		assert_eq(c.fsm.current_state.name, &"Panic", "desde " + start)
		c.serenity.change(200.0)
		_tick()


func test_panic_blocks_dash_aim_but_allows_walk() -> void:
	c.serenity.change(-200.0)
	_tick()
	c.dash_pressed = true
	c.aim_pressed = true
	c.input_axis = 1.0
	_tick()
	assert_eq(c.fsm.current_state.name, &"Panic", "dash/aim ignorados")
	assert_eq(c.velocity.x, c.stats.speed, "caminar permitido")
	assert_true(c.hurtbox.monitoring, "sin i-frames en panico")


func test_panic_allows_jump() -> void:
	c.serenity.change(-200.0)
	_tick()
	c.time_since_jump_pressed = 0.0
	_tick()
	assert_eq(c.velocity.y, c.stats.jump_velocity)
	assert_eq(c.fsm.current_state.name, &"Panic", "salta sin salir de panico")


func test_recovering_serenity_exits_panic() -> void:
	c.serenity.change(-200.0)
	_tick()
	c.serenity.change(50.0)
	_tick()
	assert_eq(c.fsm.current_state.name, &"Idle")


func test_stun_takes_priority_over_panic() -> void:
	c.serenity.change(-200.0)
	_tick()
	c.blood_circle.take_damage(100.0)
	assert_eq(c.fsm.current_state.name, &"Stunned", "sangre vacia manda")
