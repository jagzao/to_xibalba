extends "res://addons/gut/test.gd"


func test_council_room_instantiates() -> void:
	var room: Node2D = load("res://src/scenes/CouncilRoom.tscn").instantiate()
	add_child_autofree(room)
	assert_not_null(room.get_node("CouncilPuzzleRoom"))
	assert_not_null(room.get_node("LajaHirviendo"))
	assert_not_null(room.get_node("Seats"))
	assert_not_null(room.get_node("ThroneMarkers"))
