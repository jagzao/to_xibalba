extends GutTest


const SCENE: PackedScene = preload("res://src/entities/CharacterBase.tscn")

var c: CharacterBase
var altar: Altar
var bus: Node


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	c.grounded = true
	c.time_since_grounded = 0.0
	altar = Altar.new()
	altar.poem = PoemResource.new()
	altar.poem.artifact_id = "XOLO_01"
	altar.poem.content_text = "Canto de la Huida"
	add_child_autofree(altar)
	bus = get_node("/root/EventBus")
	watch_signals(bus)


func _tick(delta: float = 0.016) -> void:
	c.fsm.current_state.physics_update(delta)


func _meditate() -> void:
	c.nearby_altar = altar
	c.interact_pressed = true
	_tick()
	c.interact_pressed = false


func test_interact_in_range_enters_meditating() -> void:
	_meditate()
	assert_eq(c.fsm.current_state.name, &"Meditating")


func test_interact_without_altar_is_noop() -> void:
	c.interact_pressed = true
	_tick()
	assert_eq(c.fsm.current_state.name, &"Idle")


func test_altar_without_poem_is_noop() -> void:
	altar.poem = null
	c.nearby_altar = altar
	c.interact_pressed = true
	_tick()
	assert_eq(c.fsm.current_state.name, &"Idle")


func test_enter_plants_and_grants_immunity() -> void:
	c.velocity = Vector2(99.0, 99.0)
	_meditate()
	assert_eq(c.velocity, Vector2.ZERO)
	assert_false(c.hurtbox.monitoring, "inmune leyendo")
	assert_false(c.serenity.is_physics_processing(), "decay pausado")


func test_read_started_emitted_with_poem_data() -> void:
	_meditate()
	assert_signal_emitted_with_parameters(
		bus, "artifact_read_started", ["XOLO_01", "Canto de la Huida"]
	)


func test_close_restores_full_serenity_and_returns_idle() -> void:
	c.serenity.change(-60.0)
	_meditate()
	c.interact_pressed = true
	_tick()
	assert_eq(c.data.current_serenity, 100.0)
	assert_signal_emitted(bus, "artifact_read_completed")
	assert_eq(c.fsm.current_state.name, &"Idle")
	assert_true(c.hurtbox.monitoring, "hurtbox restaurada")


func test_meditation_escapes_panic() -> void:
	c.serenity.change(-200.0)
	_tick()
	assert_eq(c.fsm.current_state.name, &"Panic")
	_meditate()
	assert_eq(c.fsm.current_state.name, &"Meditating")
	c.interact_pressed = true
	_tick()
	assert_eq(c.fsm.current_state.name, &"Idle", "sale a Idle, no a Panic")
	assert_signal_emitted(bus, "panic_exited")


func test_no_meditation_in_air() -> void:
	c.fsm.change_state("Fall")
	c.grounded = false
	c.nearby_altar = altar
	c.interact_pressed = true
	_tick()
	assert_ne(c.fsm.current_state.name, &"Meditating")


func test_altar_is_reusable() -> void:
	for i: int in 2:
		c.serenity.change(-40.0)
		_meditate()
		c.interact_pressed = true
		_tick()
		assert_eq(c.data.current_serenity, 100.0, "lectura %d" % (i + 1))
		assert_eq(c.fsm.current_state.name, &"Idle")


func test_altar_area_marks_player_in_range() -> void:
	c.global_position = altar.global_position
	await wait_physics_frames(3)
	assert_eq(c.nearby_altar, altar, "body_entered marca al jugador")
