extends Area2D
class_name JaguarHouse
## Balami-ha: jaguares espectrales que quitan 1 calavera al contacto.

@export var data: PlayerDataResource
@export var damage_skulls: int = 1


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
	if data.current_skulls > 0:
		data.current_skulls -= damage_skulls
