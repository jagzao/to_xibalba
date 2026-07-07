extends GutTest
## Verifica pelota y desvíos del Juego de Pelota.

var data: PlayerDataResource
var ball: KineticBall2D
var character: CharacterBase
var deflection: DeflectionComponent


func before_each() -> void:
	data = PlayerDataResource.new()
	ball = KineticBall2D.new()
	ball.stats = BallStateResource.new()
	character = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(ball)
	add_child_autofree(character)
	ball.set_physics_process(false)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)
	deflection = DeflectionComponent.new()
	deflection.stats = PerfectParryResource.new()
	deflection.setup(character, character.serenity)
	add_child_autofree(deflection)


func test_ball_spawns_light_by_default() -> void:
	assert_eq(ball.state, BallStateResource.State.LIGHT)


func test_set_state_darkness() -> void:
	ball.set_state_darkness()
	assert_eq(ball.state, BallStateResource.State.DARKNESS)


func test_deflection_changes_state_to_light() -> void:
	ball.set_state_darkness()
	ball.global_position = character.global_position + Vector2(10.0, 0.0)
	character.aim_direction = Vector2.LEFT
	deflection.on_attack_pressed()
	var ok: bool = deflection.try_deflect(ball)
	assert_true(ok)
	assert_eq(ball.state, BallStateResource.State.LIGHT)


func test_deflection_out_of_range_fails() -> void:
	ball.global_position = character.global_position + Vector2(1000.0, 0.0)
	deflection.on_attack_pressed()
	assert_false(deflection.try_deflect(ball))


func test_perfect_parry_doubles_velocity_and_restores_serenity() -> void:
	data.current_serenity = 50.0
	ball.global_position = character.global_position + Vector2(10.0, 0.0)
	character.aim_direction = Vector2.RIGHT
	deflection.on_attack_pressed()
	deflection.try_deflect(ball)
	var expected_speed: float = ball.stats.base_speed * ball.stats.light_multiplier * deflection.stats.velocity_multiplier
	assert_almost_eq(ball.linear_velocity.length(), expected_speed, 0.1)
	assert_eq(data.current_serenity, 70.0)


func test_normal_deflection_no_serenity_bonus() -> void:
	data.current_serenity = 50.0
	ball.global_position = character.global_position + Vector2(10.0, 0.0)
	character.aim_direction = Vector2.RIGHT
	# No llamamos on_attack_pressed para simular parry fallido.
	deflection.try_deflect(ball)
	var expected_speed: float = ball.stats.base_speed * ball.stats.light_multiplier
	assert_almost_eq(ball.linear_velocity.length(), expected_speed, 0.1)
	assert_eq(data.current_serenity, 50.0)


func test_darkness_ball_graze_damages_blood_circle() -> void:
	ball.set_state_darkness()
	ball.stats.graze_damage = 25.0
	ball._on_body_entered(character)
	assert_eq(data.current_blood_circle, 75.0)


func test_light_ball_no_graze_damage() -> void:
	ball.set_state_light()
	ball._on_body_entered(character)
	assert_eq(data.current_blood_circle, 100.0)
