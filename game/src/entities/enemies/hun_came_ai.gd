extends BossBase
class_name HunCameAI
## Hun-Camé: melee agresivo con guadañas de hueso.


func _get_name() -> String:
	return "HunCame"


func _physics_process(delta: float) -> void:
	if blackboard == null:
		return
	var player_pos: Vector2 = blackboard.player_position
	var to_player: Vector2 = player_pos - global_position
	var speed: float = 80.0
	if not has_attack_token():
		speed = 40.0
	if to_player.length() > 10.0:
		velocity = to_player.normalized() * speed
	else:
		velocity = Vector2.ZERO
		_attack_melee()
	move_and_slide()


func _attack_melee() -> void:
	# Simulación de daño melee: en escena real conectamos hurtbox del jugador.
	# Aquí no tenemos referencia directa al jugador; BossDirector maneja colisiones.
	pass


func deal_melee_damage(target: CharacterBase) -> void:
	if target == null or stats == null:
		return
	var damage: float = stats.melee_damage
	if is_in_desperation():
		# Ignora Círculo de Sangre: daño directo a calaveras.
		target.skulls.lose_skull()
	else:
		target.blood_circle.take_damage(damage)
