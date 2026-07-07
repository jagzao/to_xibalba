extends GutTest
## Verifica BallGoal y BallGameManager.

var data: PlayerDataResource
var character: CharacterBase
var manager: BallGameManager
var ball: KineticBall2D


func before_each() -> void:
	data = PlayerDataResource.new()
	character = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(character)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)
	manager = BallGameManager.new()
	add_child_autofree(manager)
	ball = KineticBall2D.new()
	ball.stats = BallStateResource.new()
	add_child_autofree(ball)


func test_ball_goal_gods_shifts_balance_to_light() -> void:
	var goal := BallGoal.new()
	add_child_autofree(goal)
	goal.side = BallGoal.SIDE_GODS
	goal.balance_shift = 10.0
	watch_signals(EventBus)
	goal._on_body_entered(ball)
	assert_signal_emitted_with_parameters(EventBus, "balance_changed", [-10.0])


func test_ball_goal_twins_shifts_balance_to_darkness() -> void:
	var goal := BallGoal.new()
	add_child_autofree(goal)
	goal.side = BallGoal.SIDE_TWINS
	goal.balance_shift = 10.0
	watch_signals(EventBus)
	goal._on_body_entered(ball)
	assert_signal_emitted_with_parameters(EventBus, "balance_changed", [10.0])


func test_manager_extreme_darkness_loses_skull() -> void:
	manager.player = character
	manager.shift_balance(100.0)
	assert_eq(data.current_skulls, 2)
	assert_eq(manager.balance, 0.0)


func test_manager_clamps_balance() -> void:
	manager.player = character
	manager.shift_balance(200.0)
	assert_eq(manager.balance, 0.0)
	assert_eq(data.current_skulls, 2)
