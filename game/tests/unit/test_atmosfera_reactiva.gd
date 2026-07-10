extends GutTest
## Atmósfera viva: glifos que despiertan con el jugador y niebla que reacciona.


const CHAR_SCENE: PackedScene = preload("res://src/entities/CharacterBase.tscn")

var c: CharacterBase


func before_each() -> void:
	c = CHAR_SCENE.instantiate()
	c.add_to_group("player")
	add_child_autofree(c)
	c.set_physics_process(false)
	c.serenity.set_physics_process(false)


func test_glyph_wakes_near_player_and_sleeps_far() -> void:
	var glyph := ReactiveGlyph.new()
	add_child_autofree(glyph)
	glyph.set_physics_process(false)
	c.global_position = glyph.global_position + Vector2(20.0, 0.0)
	assert_gt(glyph.target_energy(), 0.5, "cerca y con serenidad llena = despierto")
	c.global_position = glyph.global_position + Vector2(glyph.wake_radius + 50.0, 0.0)
	assert_eq(glyph.target_energy(), 0.0, "lejos = dormido")


func test_glyph_dims_with_low_serenity() -> void:
	var glyph := ReactiveGlyph.new()
	add_child_autofree(glyph)
	glyph.set_physics_process(false)
	c.global_position = glyph.global_position
	var bright: float = glyph.target_energy()
	c.data.current_serenity = 10.0
	assert_lt(glyph.target_energy(), bright,
		"menos luz del jugador = la roca despierta menos")


func test_glyph_energy_eases_toward_target() -> void:
	var glyph := ReactiveGlyph.new()
	add_child_autofree(glyph)
	glyph.set_physics_process(false)
	c.global_position = glyph.global_position
	glyph._physics_process(0.1)
	var first: float = glyph.energy
	glyph._physics_process(0.1)
	assert_gt(glyph.energy, first, "enciende progresivo, no instantaneo")


func test_fog_flees_from_player_movement() -> void:
	var fog := FogLayer.new()
	add_child_autofree(fog)
	fog.set_physics_process(false)
	fog._player = c
	c.velocity = Vector2(150.0, 0.0)
	for i: int in 20:
		fog.update_drift(0.1)
	assert_lt(fog.drift.x, fog.base_drift.x,
		"correr a la derecha empuja la niebla a la izquierda")


func test_fog_returns_to_base_drift_when_player_stops() -> void:
	var fog := FogLayer.new()
	add_child_autofree(fog)
	fog.set_physics_process(false)
	fog._player = c
	c.velocity = Vector2(150.0, 0.0)
	for i: int in 20:
		fog.update_drift(0.1)
	c.velocity = Vector2.ZERO
	for i: int in 40:
		fog.update_drift(0.1)
	assert_almost_eq(fog.drift.x, fog.base_drift.x, 1.0, "vuelve a su deriva")


func test_descenso_has_glyphs_and_fog() -> void:
	var level: Node2D = preload("res://src/scenes/Descenso.tscn").instantiate()
	add_child_autofree(level)
	var glyphs: int = 0
	var fogs: int = 0
	for child: Node in level.get_node("Atmosfera").get_children():
		if child is ReactiveGlyph:
			glyphs += 1
		elif child is FogLayer:
			fogs += 1
	assert_gte(glyphs, 6, "glifos reactivos a lo largo del pozo")
	assert_gte(fogs, 3, "niebla en fosa, ventiscas y grietas")
