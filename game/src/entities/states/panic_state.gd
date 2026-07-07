extends State
class_name PanicState
## Serenidad en 0: luz al mínimo y daño x1.5 (los aplica PlayerDataResource).
## Aquí: puede moverse y saltar, pero pierde dash, ataque y apuntado.


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = c.input_axis * c.stats.speed
	c.apply_gravity(delta)
	if c.has_buffered_jump() and c.can_coyote_jump():
		c.consume_jump()
		c.velocity.y = c.stats.jump_velocity
	if c.interact_pressed and c.can_meditate():
		finished.emit("Meditating")
		return
	if not c.data.is_in_panic:
		finished.emit("Idle")
