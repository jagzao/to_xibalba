extends "res://addons/gut/test.gd"


func test_ball_court_instantiates() -> void:
	var court: Node2D = load("res://src/scenes/BallCourt.tscn").instantiate()
	add_child_autofree(court)
	assert_not_null(court.get_node("BallGameManager"))
	assert_not_null(court.get_node("Goals"))
	assert_not_null(court.get_node("RespawnMarker"))
