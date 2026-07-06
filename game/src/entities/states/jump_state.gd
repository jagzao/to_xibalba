extends State
class_name JumpState


func enter(_previous_state: String) -> void:
	var c := actor as CharacterBase
	c.consume_jump()
	c.velocity.y = c.stats.jump_velocity


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.x = c.input_axis * c.stats.speed
	c.apply_gravity(delta)
	if c.velocity.y >= 0.0:
		finished.emit("Fall")
