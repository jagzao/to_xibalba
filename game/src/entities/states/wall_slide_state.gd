extends State
class_name WallSlideState
## Deslizamiento por pared rugosa: frena la caída (y el daño por impacto).
## Saltar impulsa en dirección opuesta para encadenar wall jumps.


func enter(_previous_state: String) -> void:
	var c := actor as CharacterBase
	c.reset_fall_distance()


func physics_update(delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity.y = minf(c.velocity.y + c.stats.gravity * delta, c.stats.wall_slide_speed)
	c.reset_fall_distance()
	if c.has_buffered_jump():
		c.consume_jump()
		c.velocity.x = -c.wall_direction * c.stats.wall_jump_push
		c.velocity.y = c.stats.jump_velocity
		c.facing = -c.wall_direction
		finished.emit("Jump")
		return
	if c.grounded:
		finished.emit("Idle")
		return
	if c.wall_direction == 0.0 or signf(c.input_axis) != c.wall_direction:
		finished.emit("Fall")
