extends Area2D
class_name LajaHirviendo
## Altar falso: quema al jugador si interactúa antes de resolver el puzzle.

@export var puzzle_room: CouncilPuzzleRoom


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	if puzzle_room != null and not puzzle_room.is_completed():
		c.blood_circle.take_damage(100.0)
		c.fsm.change_state("Stunned")
