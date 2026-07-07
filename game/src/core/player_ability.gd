extends Node
class_name PlayerAbility
## Habilidad de gemelo: extiende Node, exporta serenity_cost, y ejecuta lógica propia.
## No tiene escena asociada; cada gemelo la inyecta como componente hijo.

@export var stats: AbilityResource

var character: CharacterBase
var event_bus: Node


func setup(p_character: CharacterBody2D, p_event_bus: Node) -> void:
	character = p_character as CharacterBase
	event_bus = p_event_bus
	if stats == null:
		stats = AbilityResource.new()


func can_afford() -> bool:
	if character == null or character.data == null:
		return false
	return character.data.current_serenity >= stats.serenity_cost


func spend_cost() -> void:
	if character == null:
		return
	var s: SerenityComponent = character.serenity
	if s != null:
		s.change(-stats.serenity_cost)


func execute_ability() -> void:
	pass
