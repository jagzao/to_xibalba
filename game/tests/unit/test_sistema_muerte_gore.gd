extends "res://addons/gut/test.gd"

var data: PlayerDataResource
var death_manager: DeathManager
var gore: GoreEffect


func before_each() -> void:
	data = PlayerDataResource.new()
	data.max_serenity = 100.0
	data.current_serenity = 100.0
	data.max_blood_circle = 100.0
	data.current_blood_circle = 100.0
	data.max_skulls = 3
	data.current_skulls = 3
	data.respawn_position = Vector2(200, 100)

	gore = GoreEffect.new()
	add_child_autofree(gore)

	death_manager = DeathManager.new()
	death_manager.data = data
	death_manager.gore = gore
	add_child_autofree(death_manager)


func after_each() -> void:
	data = null


func test_gore_blood_spawns_red_particles() -> void:
	gore.play(GoreEffect.Type.BLOOD)
	await get_tree().create_timer(0.05).timeout
	var particles := _find_particles()
	assert_eq(particles.size(), 1)
	if particles.size() > 0:
		assert_eq(particles[0].color, Color(0.6, 0.0, 0.0))


func test_gore_skull_spawns_bone_particles() -> void:
	gore.play(GoreEffect.Type.SKULL)
	await get_tree().create_timer(0.05).timeout
	var particles := _find_particles()
	assert_eq(particles.size(), 1)
	if particles.size() > 0:
		assert_eq(particles[0].color, Color(0.9, 0.9, 0.85))


func test_gore_fall_does_not_spawn_particles() -> void:
	gore.play(GoreEffect.Type.FALL)
	await get_tree().create_timer(0.05).timeout
	var particles := _find_particles()
	assert_eq(particles.size(), 0)


func test_gore_shake_is_safe_without_camera() -> void:
	gore.play(GoreEffect.Type.BLOOD)
	gore._camera = null
	gore._physics_process(0.05)
	assert_true(gore._active)


func test_death_manager_respawns_and_loses_skull() -> void:
	var player: CharacterBase = load("res://src/entities/CharacterBase.tscn").instantiate()
	player.data = data
	player.set_physics_process(false)
	add_child_autofree(player)
	death_manager.player = player
	death_manager._on_player_died("blood")
	assert_eq(data.current_skulls, 2)
	assert_eq(player.global_position, Vector2(200, 100))


func test_death_manager_game_over_at_zero_skulls() -> void:
	death_manager._busy = false
	data.current_skulls = 0
	var screen := DeathScreen.new()
	add_child_autofree(screen)
	death_manager.death_screen = screen
	death_manager._on_player_died("blood")
	assert_true(screen._overlay.modulate.a > 0.0 or screen.game_over_scene != null)


func test_double_death_blocked() -> void:
	death_manager._busy = false
	death_manager._on_player_died("blood")
	assert_eq(data.current_skulls, 2)
	death_manager._busy = true
	death_manager._on_player_died("blood")
	assert_eq(data.current_skulls, 2)


func _find_particles() -> Array[CPUParticles2D]:
	var out: Array[CPUParticles2D] = []
	for c in gore.get_children():
		if c is CPUParticles2D:
			out.append(c)
	return out
