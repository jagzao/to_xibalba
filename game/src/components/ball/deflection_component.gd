extends Node
class_name DeflectionComponent
## Desvío/parry de la pelota. Cada gemelo lo inyecta.

@export var stats: PerfectParryResource

var character: CharacterBase
var serenity: SerenityComponent

var _last_attack_time: int = 0


func setup(p_character: CharacterBody2D, p_serenity: SerenityComponent) -> void:
	character = p_character as CharacterBase
	serenity = p_serenity
	if stats == null:
		stats = PerfectParryResource.new()


func on_attack_pressed() -> void:
	_last_attack_time = Time.get_ticks_msec()


func try_deflect(p_ball: KineticBall2D) -> bool:
	if p_ball == null or character == null:
		return false
	var to_ball: Vector2 = p_ball.global_position - character.global_position
	if to_ball.length() > stats.deflection_range:
		return false
	var elapsed: float = (Time.get_ticks_msec() - _last_attack_time) / 1000.0
	var multiplier: float = 1.0
	if elapsed <= stats.window:
		multiplier = stats.velocity_multiplier
		if serenity != null:
			serenity.change(stats.serenity_bonus)
	var aim: Vector2 = character.aim_direction
	# Sin input de apuntado, desviamos hacia el lado opuesto de donde viene.
	if aim == Vector2.RIGHT and character.input_axis == 0.0:
		aim = -to_ball.normalized()
	p_ball.apply_deflection(aim, multiplier)
	p_ball.set_state_light()
	AudioManager.play_sfx_named(&"ball_parry", character.global_position)
	return true


func is_in_parry_window() -> bool:
	var elapsed: float = (Time.get_ticks_msec() - _last_attack_time) / 1000.0
	return elapsed <= stats.window
