extends GutTest
## Mecánicas del MVP El Descenso: daño por caída, wall slide/jump,
## desmoronables, ácido, viento, grietas y BlindStalker.


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


# --- daño por caída ---

func test_hard_landing_damages_and_staggers() -> void:
	c.fall_distance = c.stats.fall_damage_height + 1.0
	c._on_landed()
	assert_eq(c.data.current_blood_circle, 100.0 - c.stats.fall_impact_damage)
	assert_eq(c.fsm.current_state.name, &"Stunned")
	assert_eq(c.fall_distance, 0.0)


func test_soft_landing_is_free() -> void:
	c.fall_distance = c.stats.fall_damage_height - 1.0
	c._on_landed()
	assert_eq(c.data.current_blood_circle, 100.0)
	assert_eq(c.fsm.current_state.name, &"Idle")


# --- wall slide / wall jump ---

func test_fall_to_wallslide_when_pressing_into_wall() -> void:
	c.fsm.change_state("Fall")
	c.grounded = false
	c.wall_direction = 1.0
	c.input_axis = 1.0
	_tick()
	assert_eq(c.fsm.current_state.name, &"WallSlide")


func test_wallslide_caps_fall_speed_and_resets_fall_distance() -> void:
	c.fsm.change_state("WallSlide")
	c.grounded = false
	c.wall_direction = 1.0
	c.input_axis = 1.0
	c.velocity.y = 500.0
	c.fall_distance = 400.0
	_tick()
	assert_lte(c.velocity.y, c.stats.wall_slide_speed)
	assert_eq(c.fall_distance, 0.0, "deslizarse frena la caida acumulada")


func test_wall_jump_pushes_away_from_wall() -> void:
	c.fsm.change_state("WallSlide")
	c.grounded = false
	c.wall_direction = 1.0
	c.input_axis = 1.0
	c.time_since_jump_pressed = 0.0
	_tick()
	assert_eq(c.fsm.current_state.name, &"Jump")
	assert_eq(c.velocity.x, -c.stats.wall_jump_push, "impulso opuesto a la pared")
	assert_eq(c.velocity.y, c.stats.jump_velocity)
	assert_eq(c.facing, -1.0)


func test_wallslide_detaches_without_input() -> void:
	c.fsm.change_state("WallSlide")
	c.grounded = false
	c.wall_direction = 1.0
	c.input_axis = 0.0
	_tick()
	assert_eq(c.fsm.current_state.name, &"Fall")


# --- plataforma desmoronable ---

func test_crumbling_platform_dies_in_delay_and_respawns() -> void:
	var p := CrumblingPlatform.new()
	add_child_autofree(p)
	p.set_physics_process(false)
	p._on_body_entered(c)
	p._physics_process(0.2)
	assert_false(p.crumbled, "aguanta antes de 0.4s")
	p._physics_process(0.3)
	assert_true(p.crumbled, "colapsa pasado crumble_delay")
	assert_false(p.visible)
	p._physics_process(p.respawn_delay + 0.01)
	assert_false(p.crumbled, "reaparece para reintentos")
	assert_true(p.visible)


# --- cenote ácido ---

func test_acid_pool_destroys_serenity_and_drains_blood() -> void:
	var pool := AcidPool.new()
	add_child_autofree(pool)
	pool.set_physics_process(false)
	pool._on_body_entered(c)
	assert_eq(c.data.current_serenity, 0.0, "serenidad destruida al instante")
	assert_true(c.data.is_in_panic)
	# en pánico el drenado sufre el multiplicador x1.5
	var drained: float = pool.blood_drain_per_second * PlayerDataResource.PANIC_DAMAGE_MULTIPLIER
	pool._physics_process(1.0)
	assert_eq(c.data.current_blood_circle, 100.0 - drained)
	pool._on_body_exited(c)
	pool._physics_process(1.0)
	assert_eq(c.data.current_blood_circle, 100.0 - drained,
		"fuera del cenote ya no drena")


# --- corriente de viento ---

func test_wind_current_applies_and_removes_force() -> void:
	var wind := WindCurrent.new()
	wind.force = Vector2(0.0, 400.0)
	add_child_autofree(wind)
	wind._on_body_entered(c)
	assert_eq(c.external_force, Vector2(0.0, 400.0), "succion activa")
	wind._on_body_exited(c)
	assert_eq(c.external_force, Vector2.ZERO)


# --- grieta + ocultamiento ---

func test_hide_in_crevice_kills_light_and_exit_restores() -> void:
	var crevice := CreviceSpot.new()
	add_child_autofree(crevice)
	c.nearby_crevice = crevice
	c.interact_pressed = true
	_tick()
	c.interact_pressed = false
	assert_eq(c.fsm.current_state.name, &"Hiding")
	assert_false(c.light.visible, "aura apagada en la grieta")
	c.interact_pressed = true
	_tick()
	assert_eq(c.fsm.current_state.name, &"Idle")
	assert_true(c.light.visible)


# --- BlindStalker ---

func test_stalker_hears_moving_prey_but_not_hidden_or_still() -> void:
	var stalker := BlindStalker.new()
	add_child_autofree(stalker)
	stalker.set_physics_process(false)
	c.velocity = Vector2(100.0, 0.0)
	assert_true(stalker.can_hear(c), "movimiento fuera de grieta = audible")
	c.velocity = Vector2.ZERO
	assert_false(stalker.can_hear(c), "inmovil = inaudible")
	c.velocity = Vector2(100.0, 0.0)
	var crevice := CreviceSpot.new()
	add_child_autofree(crevice)
	c.nearby_crevice = crevice
	c.interact_pressed = true
	_tick()
	c.velocity = Vector2(100.0, 0.0)
	assert_false(stalker.can_hear(c), "oculto en grieta = inaudible")


func test_stalker_contact_takes_skull() -> void:
	var stalker := BlindStalker.new()
	add_child_autofree(stalker)
	stalker.set_physics_process(false)
	stalker.global_position = c.global_position + Vector2(10.0, 0.0)
	stalker._prey = c
	c.velocity = Vector2(50.0, 0.0)
	stalker._physics_process(0.016)
	assert_eq(c.data.current_skulls, 2, "embestida quita 1 calavera")
