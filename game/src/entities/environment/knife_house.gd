extends Area2D
class_name KnifeHouse
## Chayin-ha: navajas autónomas. Dash mal timed = Círculo de Sangre vaciado.

@export var data: PlayerDataResource
@export var drain_amount: float = 100.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func activate(player_data: PlayerDataResource) -> void:
	data = player_data
	monitoring = true


func deactivate() -> void:
	monitoring = false


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null or data == null:
		return
	if c.fsm.current_state.name == &"Dash":
		return
	data.current_blood_circle = 0.0
	if c.fsm.current_state.name != &"Stunned":
		c.fsm.change_state("Stunned")
