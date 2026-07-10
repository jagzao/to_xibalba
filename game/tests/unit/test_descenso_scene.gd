extends GutTest
## Greybox de la Sala 1 del MVP: las 5 cápsulas del Descenso.


const SCENE: PackedScene = preload("res://src/scenes/Descenso.tscn")

var level: Node2D


func before_each() -> void:
	level = SCENE.instantiate()
	add_child_autofree(level)


func test_scene_instantiates_dark() -> void:
	var cm: CanvasModulate = level.get_node("CanvasModulate")
	assert_lt(cm.color.r, 0.1, "mundo casi negro: la luz del jugador manda")


func test_walls_are_slidable_static_bodies() -> void:
	assert_true(level.get_node("WallLeft") is StaticBody2D)
	assert_true(level.get_node("WallRight") is StaticBody2D)


func test_capsules_exist_in_falling_order() -> void:
	var order: Array[String] = [
		"A1_Brecha", "A2_ZigZag", "A3_Fosa", "A4_Ventiscas", "A5_Umbral"
	]
	var last_y: float = -99999.0
	for name: String in order:
		var capsule: Node2D = level.get_node(name)
		assert_not_null(capsule, "falta " + name)
		assert_gt(capsule.position.y, last_y - 1.0, name + " debe estar debajo de la anterior")
		last_y = capsule.position.y


func test_a2_zigzag_alternates_crumbling_sides() -> void:
	var xs: Array[float] = []
	for child: Node in level.get_node("A2_ZigZag").get_children():
		if child is CrumblingPlatform:
			xs.append(child.position.x)
	assert_gte(xs.size(), 4, "zig-zag necesita minimo 4 desmoronables")
	for i: int in range(1, xs.size()):
		assert_ne(signf(xs[i]), signf(xs[i - 1]), "lados alternados")


func test_a3_has_center_blocker_and_acid() -> void:
	assert_true(level.get_node("A3_Fosa/Estalactita") is StaticBody2D)
	assert_true(level.get_node("A3_Fosa/Cenote") is AcidPool)


func test_a4_has_push_and_suction_winds() -> void:
	var push_wind: WindCurrent = level.get_node("A4_Ventiscas/VientoEmpuje")
	var suction: WindCurrent = level.get_node("A4_Ventiscas/VientoSuccion")
	assert_gt(push_wind.force.x, 0.0, "empuja horizontal")
	assert_eq(push_wind.force.y, 0.0)
	assert_gt(suction.force.y, 0.0, "succiona hacia abajo")


func test_a5_floor_deeper_than_fall_damage_height() -> void:
	var floor_y: float = level.get_node("A5_Umbral").position.y \
		+ level.get_node("A5_Umbral/Suelo").position.y
	var stats := MovementStatsResource.new()
	assert_gt(floor_y, stats.fall_damage_height,
		"caer directo desde arriba DEBE doler: obliga a frenar en paredes")


func test_checkpoints_at_top_and_bottom() -> void:
	assert_not_null(level.get_node("A1_Brecha/Checkpoint"))
	assert_not_null(level.get_node("A5_Umbral/Checkpoint"))


func test_exit_leads_to_rios() -> void:
	var exit: Area2D = level.get_node("Exit")
	assert_string_contains(exit.next_scene_path, "Escenario1")
