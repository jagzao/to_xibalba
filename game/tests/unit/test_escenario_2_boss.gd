extends GutTest
## Verifica BossDirector y jefes dobles.

var data: PlayerDataResource
var character: CharacterBase
var blackboard: SharedBlackboard
var director: BossDirector
var hun: HunCameAI
var vucub: VucubCameAI


func before_each() -> void:
	data = PlayerDataResource.new()
	character = load("res://src/entities/CharacterBase.tscn").instantiate()
	character.data = data
	add_child_autofree(character)
	character.set_physics_process(false)
	character.serenity.set_physics_process(false)
	blackboard = SharedBlackboard.new()
	director = BossDirector.new()
	director.blackboard = blackboard
	director.stats = BossStatsResource.new()
	hun = HunCameAI.new()
	hun.blackboard = blackboard
	hun.stats = director.stats
	vucub = VucubCameAI.new()
	vucub.blackboard = blackboard
	vucub.stats = director.stats
	add_child_autofree(director)
	add_child_autofree(hun)
	add_child_autofree(vucub)
	director.register_boss(hun, vucub)
	director.start_fight()


func test_starts_with_hun_came_token() -> void:
	assert_eq(blackboard.attack_token, "HunCame")
	assert_true(hun.has_attack_token())
	assert_false(vucub.has_attack_token())


func test_swap_token_after_interval() -> void:
	director.update(director.stats.token_swap_interval + 0.1, character)
	assert_eq(blackboard.attack_token, "VucubCame")
	assert_false(hun.has_attack_token())
	assert_true(vucub.has_attack_token())


func test_desperation_activates_on_death() -> void:
	hun.take_damage(999.0)
	assert_true(blackboard.desperation_active)
	assert_true(vucub.is_in_desperation())


func test_hun_deals_blood_damage_normal() -> void:
	hun.deal_melee_damage(character)
	assert_eq(data.current_blood_circle, 100.0 - director.stats.melee_damage)
	assert_eq(data.current_skulls, 3)


func test_hun_deals_skull_damage_in_desperation() -> void:
	hun.activate_desperation()
	hun.deal_melee_damage(character)
	assert_eq(data.current_blood_circle, 100.0)
	assert_eq(data.current_skulls, 2)


func test_vucub_deals_serenity_damage() -> void:
	vucub.deal_ranged_damage(character)
	assert_eq(data.current_serenity, 100.0 - director.stats.ranged_serenity_cost)
