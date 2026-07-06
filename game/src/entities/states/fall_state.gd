extends State
class_name FallState


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = c.input_axis * c.stats.speed
	c.apply_gravity(delta)
	if c.has_buffered_jump() and c.can_coyote_jump():
		finished.emit("Jump")
		return
	if c.grounded:
		finished.emit("Move" if c.input_axis != 0.0 else "Idle")
