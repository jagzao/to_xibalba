extends GutTest


const SCENE: PackedScene = preload("res://src/entities/Hunahpu.tscn")

var c: Hunahpu
var animator: SpriteAnimator


func before_each() -> void:
	c = SCENE.instantiate()
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)
	animator = c.get_node("CharacterVisuals/SpriteAnimator")
	animator.set_process(false)


func test_builds_all_hunahpu_animations() -> void:
	var expected: Dictionary[String, int] = {
		"idle": 5, "run": 8, "jump_fall": 5, "panic": 4,
		"aim": 5, "shoot": 4, "destello": 4, "meditate": 4, "hit": 3,
	}
	for anim: String in expected:
		assert_true(animator.sprite_frames.has_animation(anim), "falta " + anim)
		assert_eq(
			animator.sprite_frames.get_frame_count(anim), expected[anim], anim
		)


func test_aim_state_plays_aim_animation() -> void:
	c.fsm.change_state("Aim")
	assert_eq(animator.animation, &"aim")


func test_meditating_plays_meditate() -> void:
	var altar := Altar.new()
	altar.poem = PoemResource.new()
	add_child_autofree(altar)
	c.nearby_altar = altar
	c.fsm.change_state("Meditating")
	assert_eq(animator.animation, &"meditate")


func test_stunned_plays_hit() -> void:
	c.fsm.change_state("Stunned")
	assert_eq(animator.animation, &"hit")
