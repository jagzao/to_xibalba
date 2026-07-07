extends State
class_name AimState
## Apuntado 360°: el gemelo se planta firme; al soltar, dispara ProjectileLight.


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = 0.0
	c.apply_gravity(delta)
	if not c.aim_held:
		c.ranged.shoot(c.aim_direction)
		finished.emit("Idle")
