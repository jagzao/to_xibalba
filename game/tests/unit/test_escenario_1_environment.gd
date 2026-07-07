extends GutTest
## Verifica entorno del Escenario 1.

const HUNAHPU: PackedScene = preload("res://src/entities/Hunahpu.tscn")

var data: PlayerDataResource
var character: Hunahpu


func before_each() -> void:
	data = PlayerDataResource.new()
	character = HUNAHPU.instantiate()
	character.data = data
	add_child_autofree(character)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)


func test_checkpoint_saves_respawn_position() -> void:
	var checkpoint := Checkpoint.new()
	checkpoint.data = data
	add_child_autofree(checkpoint)
	character.global_position = Vector2(123.0, 456.0)
	checkpoint._on_body_entered(character)
	assert_eq(data.respawn_position, Vector2(123.0, 456.0))


func test_hazard_floor_loses_skull_and_respawns() -> void:
	var hazard := HazardFloor.new()
	hazard.data = data
	hazard.stats = HazardResource.new()
	data.respawn_position = Vector2(999.0, 0.0)
	add_child_autofree(hazard)
	character.global_position = Vector2(10.0, 10.0)
	hazard._on_body_entered(character)
	assert_eq(data.current_skulls, 2)
	assert_eq(character.global_position, Vector2(999.0, 0.0))


func test_hazard_floor_does_not_touch_blood_circle() -> void:
	var hazard := HazardFloor.new()
	hazard.data = data
	hazard.stats = HazardResource.new()
	data.respawn_position = Vector2.ZERO
	add_child_autofree(hazard)
	hazard._on_body_entered(character)
	assert_eq(data.current_blood_circle, 100.0)


func test_invisible_platform_active_above_threshold() -> void:
	var platform := InvisiblePlatform.new()
	platform.data = data
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	platform.add_child(shape)
	add_child_autofree(platform)
	data.current_serenity = 50.0
	platform._update_collision()
	assert_false(shape.disabled)


func test_invisible_platform_disabled_below_threshold() -> void:
	var platform := InvisiblePlatform.new()
	platform.data = data
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	platform.add_child(shape)
	add_child_autofree(platform)
	data.current_serenity = 20.0
	platform._update_collision()
	assert_true(shape.disabled)


func test_serenity_zone_doubles_multiplier() -> void:
	var zone := SerenityZone.new()
	zone.stats = SerenityZoneResource.new()
	add_child_autofree(zone)
	zone._on_body_entered(character)
	assert_eq(character.serenity.environment_multiplier, 2.0)
	zone._on_body_exited(character)
	assert_eq(character.serenity.environment_multiplier, 1.0)
