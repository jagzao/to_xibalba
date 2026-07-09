extends "res://addons/gut/test.gd"


func test_gore_data_resource_has_pivots() -> void:
	var gore := GoreDataResource.new()
	gore.head_pivots = [Vector2(8, 4)]
	gore.torso_pivots = [Vector2(8, 16)]
	gore.limb_pivots = [Vector2(4, 24), Vector2(12, 24)]
	assert_eq(gore.head_pivots.size(), 1)
	assert_eq(gore.torso_pivots.size(), 1)
	assert_eq(gore.limb_pivots.size(), 2)


func test_boss_fatality_scene_plays_and_finishes() -> void:
	var fatality := BossFatalityScene.new()
	fatality.duration = 0.2
	add_child_autofree(fatality)
	fatality.play()
	fatality._physics_process(0.2)
	assert_true(fatality.is_queued_for_deletion())


func test_boss_fatality_does_not_finish_early() -> void:
	var fatality := BossFatalityScene.new()
	fatality.duration = 0.3
	add_child_autofree(fatality)
	fatality.play()
	fatality._physics_process(0.1)
	assert_false(fatality.is_queued_for_deletion())


func test_sprite_animator_maps_fsm_states() -> void:
	var animator := SpriteAnimator.new()
	add_child_autofree(animator)
	animator.frames_root = "res://assets/sprites/players/hunahpu/frames"
	var frames := animator._build_frames()
	assert_true(frames.has_animation("idle"))
	assert_true(frames.has_animation("jump_fall"))


func test_sprite_animator_flip_follows_facing() -> void:
	var animator := SpriteAnimator.new()
	add_child_autofree(animator)
	animator._character = null
	# Sin personaje no debe romper
	animator._process(0.0)
	assert_false(animator.flip_h)
