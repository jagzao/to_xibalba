extends State
class_name HidingState
## Oculto en una grieta: pegado a la pared trasera, aura de luz apagada.
## El BlindStalker no puede oírte aquí. Interact de nuevo para salir.


func enter(_previous_state: String) -> void:
	var c := actor as CharacterBase
	c.velocity = Vector2.ZERO
	c.light.visible = false


func physics_update(_delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity = Vector2.ZERO
	if c.interact_pressed:
		finished.emit("Idle")


func exit() -> void:
	var c := actor as CharacterBase
	c.light.visible = true
