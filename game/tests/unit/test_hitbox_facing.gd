extends "res://addons/gut/test.gd"

var character: CharacterBase


func before_each() -> void:
	character = load("res://src/entities/Ixbalanque.tscn").instantiate()
	character.data = PlayerDataResource.new()
	character.set_physics_process(false)
	add_child_autofree(character)


func test_hitbox_faces_right_by_default() -> void:
	var shape := character.hitbox.get_child(0) as CollisionShape2D
	assert_eq(shape.position.x, 16.0)


func test_hitbox_flips_when_facing_left() -> void:
	character.facing = -1.0
	character._update_hitbox_facing()
	var shape := character.hitbox.get_child(0) as CollisionShape2D
	assert_eq(shape.position.x, -16.0)
