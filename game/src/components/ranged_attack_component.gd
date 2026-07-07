extends Node
class_name RangedAttackComponent
## Cerbatana Mística: gasta bloque fijo de Serenidad por disparo.

signal fired(projectile: ProjectileLight)

@export var stats: RangedStatsResource

var character: CharacterBase
var serenity: SerenityComponent


func setup(p_character: CharacterBase, p_serenity: SerenityComponent) -> void:
	character = p_character
	serenity = p_serenity
	if stats == null:
		stats = RangedStatsResource.new()


func shoot(direction: Vector2) -> ProjectileLight:
	if character.data.current_serenity < stats.serenity_cost:
		return null
	serenity.change(-stats.serenity_cost)
	var p := ProjectileLight.new()
	p.direction = direction.normalized()
	p.speed = stats.projectile_speed
	p.damage = stats.damage
	p.lifetime = stats.lifetime
	p.global_position = character.global_position
	character.get_parent().add_child(p)
	fired.emit(p)
	return p
