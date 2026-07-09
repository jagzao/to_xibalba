extends "res://addons/gut/test.gd"


func test_sinking_platform_has_detector() -> void:
	var platform: SinkingPlatform = load("res://src/entities/environment/SinkingPlatform.tscn").instantiate()
	add_child_autofree(platform)
	assert_not_null(platform.get_node("Detector"))
	assert_not_null(platform.get_node("CollisionShape2D"))


func test_sinking_platform_starts_sinking_on_body_entered() -> void:
	var platform: SinkingPlatform = load("res://src/entities/environment/SinkingPlatform.tscn").instantiate()
	add_child_autofree(platform)
	var player: CharacterBase = load("res://src/entities/Ixbalanque.tscn").instantiate()
	player.data = PlayerDataResource.new()
	player.set_physics_process(false)
	add_child_autofree(player)
	platform._on_detector_body_entered(player)
	assert_true(platform._sinking)
