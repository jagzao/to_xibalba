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


func test_dash_pressed_enters_dash_from_move() -> void:
	c.fsm.change_state("Move")
	c.dash_pressed = true
	_tick()
	assert_eq(c.fsm.current_state.name, &"Dash")


func test_dash_disables_hurtbox_iframes() -> void:
	c.fsm.change_state("Dash")
	assert_false(c.hurtbox.monitoring, "i-frames: hurtbox apagada")


func test_dash_speed_uses_facing_without_input() -> void:
	c.facing = -1.0
	c.input_axis = 0.0
	c.fsm.change_state("Dash")
	_tick()
	assert_eq(c.velocity.x, -c.stats.dash_speed)
	assert_eq(c.velocity.y, 0.0, "sin gravedad durante dash")


func test_dash_lasts_exactly_12_frames_then_restores() -> void:
	c.fsm.change_state("Dash")
	var frame: float = 1.0 / c.stats.frames_per_second
	for i: int in 11:
		_tick(frame)
	assert_eq(c.fsm.current_state.name, &"Dash", "sigue en dash al frame 11")
	_tick(frame)
	assert_eq(c.fsm.current_state.name, &"Idle", "termina al frame 12")
	assert_true(c.hurtbox.monitoring, "hurtbox restaurada al salir")


func test_dash_exit_opens_absorption_window() -> void:
	c.fsm.change_state("Dash")
	c.fsm.change_state("Idle")
	assert_eq(c.time_since_dash, 0.0, "ventana de absorcion abierta")


func test_air_dash_exits_to_fall() -> void:
	c.grounded = false
	c.time_since_grounded = 1.0
	c.fsm.change_state("Dash")
	_tick(1.0)
	assert_eq(c.fsm.current_state.name, &"Fall")
