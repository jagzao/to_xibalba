extends PlayerAbility
class_name IxbalanqueAbility
## Fuerza de la Luna: K = dash (Paso del Jaguar); Manto de Jaguar es stub v1.

@export var melee: MeleeAttackComponent


func execute_ability() -> void:
	if character == null or character.fsm == null:
		return
	var state_name: String = character.fsm.current_state.name if character.fsm.current_state != null else ""
	state_name = state_name.to_lower()
	var allowed: Array[String] = ["idle", "move", "jump", "fall", "panic"]
	if state_name not in allowed:
		return
	character.fsm.change_state("Dash")


func trigger_cloak() -> void:
	## STUB v1: camuflaje en sombras — sin mecánica de sigilo aún.
	if not can_afford():
		return
	spend_cost()
