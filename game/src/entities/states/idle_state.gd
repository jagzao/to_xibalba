extends State
class_name IdleState


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = 0.0
	c.apply_gravity(delta)
	if c.data.is_in_panic:
		finished.emit("Panic")
		return
	if c.attack_pressed:
		c.melee.try_attack()
	if c.aim_pressed:
		finished.emit("Aim")
		return
	if c.dash_pressed:
		finished.emit("Dash")
		return
	if c.has_buffered_jump() and c.can_coyote_jump():
		finished.emit("Jump")
		return
	if not c.grounded:
		finished.emit("Fall")
		return
	if c.input_axis != 0.0:
		finished.emit("Move")
