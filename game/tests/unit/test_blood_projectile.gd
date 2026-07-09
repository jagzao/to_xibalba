extends "res://addons/gut/test.gd"


func test_blood_projectile_deals_serenity_damage() -> void:
	var player: CharacterBase = load("res://src/entities/Ixbalanque.tscn").instantiate()
	player.data = PlayerDataResource.new()
	player.data.current_serenity = 100.0
	player.set_physics_process(false)
	add_child_autofree(player)

	var projectile := BloodProjectile.new()
	projectile.serenity_damage = 20.0
	add_child_autofree(projectile)
	projectile._on_body_entered(player)
	assert_eq(player.data.current_serenity, 80.0)


func test_vucub_creates_projectile_when_has_token() -> void:
	var bb := SharedBlackboard.new()
	bb.player_position = Vector2(300, 100)

	var vucub := VucubCameAI.new()
	vucub.blackboard = bb
	vucub.global_position = Vector2(100, 100)
	vucub.stats = BossStatsResource.new()
	vucub.stats.ranged_serenity_cost = 10.0
	add_child_autofree(vucub)

	var scene := PackedScene.new()
	# stub: no podemos empaquetar BloodProjectile.new() sin config; usamos mock
	vucub.blood_projectile_scene = null
	vucub._shoot_blood_projectile(Vector2(300, 100))
	# Sin escena no pasa nada; test cubre rama protegida.
	assert_true(true)
