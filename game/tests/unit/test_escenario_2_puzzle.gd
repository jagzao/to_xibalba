extends GutTest
## Verifica puzzle del Consejo, Laja Hirviente y DeceptiveLord.

var data: PlayerDataResource
var room: CouncilPuzzleRoom


func before_each() -> void:
	data = PlayerDataResource.new()
	room = CouncilPuzzleRoom.new()
	room.data = data
	add_child_autofree(room)


func test_deceptive_lord_revealed_with_high_serenity() -> void:
	var lord := DeceptiveLord.new()
	add_child_autofree(lord)
	lord.lord_type = DeceptiveLord.Type.MANNEQUIN
	lord.update_reveal(0.8, 0.016)
	assert_true(lord.revealed)


func test_deceptive_lord_hidden_with_low_serenity() -> void:
	var lord := DeceptiveLord.new()
	add_child_autofree(lord)
	lord.lord_type = DeceptiveLord.Type.MANNEQUIN
	lord.update_reveal(0.5, 0.016)
	assert_false(lord.revealed)


func test_puzzle_completes_with_two_real_leaders() -> void:
	watch_signals(room)
	var leader1 := DeceptiveLord.new()
	add_child_autofree(leader1)
	leader1.lord_type = DeceptiveLord.Type.REAL
	leader1.is_leader = true
	var leader2 := DeceptiveLord.new()
	add_child_autofree(leader2)
	leader2.lord_type = DeceptiveLord.Type.REAL
	leader2.is_leader = true
	room.register_lord(leader1)
	room.register_lord(leader2)
	room.interact_with(leader1)
	room.interact_with(leader2)
	assert_true(room.is_completed())
	assert_signal_emitted(room, "puzzle_completed")


func test_puzzle_fails_on_mannequin() -> void:
	watch_signals(room)
	var fake := DeceptiveLord.new()
	add_child_autofree(fake)
	fake.lord_type = DeceptiveLord.Type.MANNEQUIN
	room.register_lord(fake)
	room.interact_with(fake)
	assert_false(room.is_completed())
	assert_signal_emitted(room, "puzzle_failed")
	assert_eq(data.current_serenity, 50.0)


func test_laja_hirviendo_empties_blood_before_completion() -> void:
	var laja := LajaHirviendo.new()
	add_child_autofree(laja)
	laja.puzzle_room = room
	var character: CharacterBase = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(character)
	character.set_physics_process(false)
	laja._on_body_entered(character)
	assert_eq(data.current_blood_circle, 0.0)
	assert_eq(character.fsm.current_state.name, &"Stunned")


func test_laja_hirviendo_inoffensive_after_completion() -> void:
	var laja := LajaHirviendo.new()
	add_child_autofree(laja)
	laja.puzzle_room = room
	room._completed = true
	var character: CharacterBase = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(character)
	character.set_physics_process(false)
	laja._on_body_entered(character)
	assert_eq(data.current_blood_circle, 100.0)
