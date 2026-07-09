extends BossBase
class_name VucubCameAI
## Vucub-Camé: soporte a distancia con proyectiles de sangre que restan Serenidad.


func _get_name() -> String:
	return "VucubCame"


func _physics_process(delta: float) -> void:
	if blackboard == null:
		return
	var player_pos: Vector2 = blackboard.player_position
	var to_player: Vector2 = player_pos - global_position
	var distance: float = to_player.length()
	var speed: float = 30.0
	# Se mantiene a distancia.
	var desired: float = 200.0
	if distance < desired:
		velocity = -to_player.normalized() * speed
	else:
		velocity = Vector2.ZERO
		if has_attack_token():
			_shoot_blood_projectile(player_pos)
	move_and_slide()


@export var blood_projectile_scene: PackedScene


func _shoot_blood_projectile(target_pos: Vector2) -> void:
	if blood_projectile_scene == null:
		return
	var projectile: BloodProjectile = blood_projectile_scene.instantiate() as BloodProjectile
	if projectile == null:
		return
	projectile.global_position = global_position
	var dir := target_pos - global_position
	var dmg := stats.ranged_serenity_cost if stats != null else 15.0
	projectile.setup(dir, dmg)
	get_tree().root.add_child(projectile)
	AudioManager.play_sfx_named(&"projectile", global_position)


func deal_ranged_damage(target: CharacterBase) -> void:
	if target == null or stats == null:
		return
	target.serenity.change(-stats.ranged_serenity_cost)
