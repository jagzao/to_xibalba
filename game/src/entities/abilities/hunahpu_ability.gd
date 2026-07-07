extends PlayerAbility
class_name HunahpuAbility
## Resplandor del Sol: K apunta cerbatana; Destello de Resplandor es stub v1.

@export var ranged: RangedAttackComponent


func execute_ability() -> void:
	if character == null or character.fsm == null:
		return
	var state_name: String = character.fsm.current_state.name if character.fsm.current_state != null else ""
	state_name = state_name.to_lower()
	var grounded: bool = character.grounded
	if state_name in ["idle", "move", "panic"] and grounded:
		character.fsm.change_state("Aim")


func trigger_flash() -> void:
	## STUB v1: iluminar habitación completa y cegar enemigos — sin enemigos aún.
	if not can_afford():
		return
	spend_cost()
