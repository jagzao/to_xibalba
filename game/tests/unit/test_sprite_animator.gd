extends GutTest


const SCENE: PackedScene = preload("res://src/entities/Ixbalanque.tscn")

var c: Ixbalanque
var animator: SpriteAnimator


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	animator = c.get_node("CharacterVisuals/SpriteAnimator")
	animator.set_process(false)


func test_builds_animations_from_frame_folders() -> void:
	for anim: String in ["idle", "run", "dash", "jump_fall", "panic", "melee"]:
		assert_true(animator.sprite_frames.has_animation(anim), "falta " + anim)
	assert_eq(animator.sprite_frames.get_frame_count("run"), 4)
	assert_eq(animator.sprite_frames.get_frame_count("jump_fall"), 5)


func test_starts_playing_idle() -> void:
	assert_eq(animator.animation, &"idle")
	assert_true(animator.is_playing())


func test_state_changes_drive_animation() -> void:
	c.fsm.change_state("Move")
	assert_eq(animator.animation, &"run")
	c.fsm.change_state("Dash")
	assert_eq(animator.animation, &"dash")
	c.fsm.change_state("Fall")
	assert_eq(animator.animation, &"jump_fall")
	c.fsm.change_state("Panic")
	assert_eq(animator.animation, &"panic")


func test_states_without_own_anim_fall_back() -> void:
	c.fsm.change_state("Stunned")
	assert_eq(animator.animation, &"panic")
	c.fsm.change_state("Aim")
	assert_eq(animator.animation, &"idle")


func test_flip_follows_facing() -> void:
	c.facing = -1.0
	animator._process(0.0)
	assert_true(animator.flip_h)
	c.facing = 1.0
	animator._process(0.0)
	assert_false(animator.flip_h)


func test_loop_config() -> void:
	assert_true(animator.sprite_frames.get_animation_loop("run"))
	assert_false(animator.sprite_frames.get_animation_loop("jump_fall"))
