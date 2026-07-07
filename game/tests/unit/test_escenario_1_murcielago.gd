extends GutTest
## Verifica Murciélagos de la Periferia.

var data: PlayerDataResource
var murcielago: MurcielagoPeriferia
var character: CharacterBase


func before_each() -> void:
	data = PlayerDataResource.new()
	murcielago = MurcielagoPeriferia.new()
	murcielago.player_data = data
	murcielago.stats = MurcielagoResource.new()
	character = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(murcielago)
	add_child_autofree(character)
	murcielago.set_physics_process(false)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)


func test_passive_speed_with_high_serenity() -> void:
	data.current_serenity = 80.0
	murcielago.global_position = Vector2.ZERO
	murcielago._direction = 1.0
	murcielago._physics_process(1.0)
	assert_eq(murcielago.velocity.x, murcielago.stats.passive_speed)


func test_charges_when_serenity_low() -> void:
	data.current_serenity = 10.0
	murcielago.global_position = Vector2.ZERO
	character.global_position = Vector2(100.0, 0.0)
	murcielago.player = character
	murcielago._physics_process(1.0)
	assert_gt(murcielago.velocity.x, murcielago.stats.passive_speed)


func test_contact_damages_blood_circle_not_skulls() -> void:
	var before_blood: float = data.current_blood_circle
	var before_skulls: int = data.current_skulls
	murcielago.player = character
	murcielago._on_body_entered(character)
	assert_eq(data.current_blood_circle, before_blood - murcielago.stats.blood_damage)
	assert_eq(data.current_skulls, before_skulls)
