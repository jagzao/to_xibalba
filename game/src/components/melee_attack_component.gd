extends Node
class_name MeleeAttackComponent
## Combo de corte de obsidiana. Golpe dentro de la ventana post-dash
## (time_since_dash <= absorption_window) restaura Serenidad (Ixbalanqué).

signal hit_confirmed(target: Area2D)

@export var stats: CombatStatsResource

var character: CharacterBase
var serenity: SerenityComponent
var hitbox: Area2D

var _cooldown_left: float = 0.0
var _active_left: float = 0.0


func setup(
	p_character: CharacterBase, p_serenity: SerenityComponent, p_hitbox: Area2D
) -> void:
	character = p_character
	serenity = p_serenity
	hitbox = p_hitbox
	if stats == null:
		stats = CombatStatsResource.new()
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	tick(delta)


func tick(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _active_left > 0.0:
		_active_left -= delta
		if _active_left <= 0.0:
			hitbox.monitoring = false


func try_attack() -> bool:
	if hitbox == null or _cooldown_left > 0.0:
		return false
	_cooldown_left = stats.cooldown
	_active_left = stats.active_time
	hitbox.monitoring = true
	return true


func _on_area_entered(target: Area2D) -> void:
	if target.has_method("take_hit"):
		target.take_hit(stats.damage)
	if character != null and character.time_since_dash <= stats.absorption_window:
		serenity.change(stats.absorption_serenity)
	hit_confirmed.emit(target)
