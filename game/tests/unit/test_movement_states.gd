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


func _state() -> StringName:
	return c.fsm.current_state.name


func test_idle_to_move_with_input() -> void:
	c.input_axis = 1.0
	_tick()
	assert_eq(_state(), &"Move")


func test_move_applies_speed_from_stats() -> void:
	c.fsm.change_state("Move")
	c.input_axis = -1.0
	_tick()
	assert_eq(c.velocity.x, -c.stats.speed)


func test_move_to_idle_without_input() -> void:
	c.fsm.change_state("Move")
	c.input_axis = 0.0
	_tick()
	assert_eq(_state(), &"Idle")


func test_idle_to_fall_when_airborne() -> void:
	c.grounded = false
	c.time_since_grounded = 1.0
	_tick()
	assert_eq(_state(), &"Fall")


func test_buffered_jump_from_idle_sets_velocity_and_consumes() -> void:
	c.time_since_jump_pressed = 0.0
	_tick()
	assert_eq(_state(), &"Jump")
	assert_eq(c.velocity.y, c.stats.jump_velocity)
	assert_false(c.has_buffered_jump(), "buffer consumido al saltar")


func test_jump_buffer_expired_does_not_jump() -> void:
	c.time_since_jump_pressed = 0.2
	_tick()
	assert_eq(_state(), &"Idle")


func test_jump_to_fall_at_apex() -> void:
	c.fsm.change_state("Jump")
	c.velocity.y = 1.0
	_tick()
	assert_eq(_state(), &"Fall")


func test_fall_lands_to_idle_or_move() -> void:
	c.fsm.change_state("Fall")
	c.grounded = true
	c.input_axis = 0.0
	_tick()
	assert_eq(_state(), &"Idle")
	c.fsm.change_state("Fall")
	c.input_axis = 1.0
	_tick()
	assert_eq(_state(), &"Move")


func test_coyote_jump_within_window() -> void:
	c.fsm.change_state("Fall")
	c.grounded = false
	c.time_since_grounded = 0.05
	c.time_since_jump_pressed = 0.0
	_tick()
	assert_eq(_state(), &"Jump")


func test_coyote_expired_stays_falling() -> void:
	c.fsm.change_state("Fall")
	c.grounded = false
	c.time_since_grounded = 0.5
	c.time_since_jump_pressed = 0.0
	_tick()
	assert_eq(_state(), &"Fall")
