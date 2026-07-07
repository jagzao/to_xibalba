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


func _shoot_blood_projectile(target_pos: Vector2) -> void:
	# En escena real instanciaría un proyectil; en test se usa directamente sobre el jugador.
	pass


func deal_ranged_damage(target: CharacterBase) -> void:
	if target == null or stats == null:
		return
	target.serenity.change(-stats.ranged_serenity_cost)
