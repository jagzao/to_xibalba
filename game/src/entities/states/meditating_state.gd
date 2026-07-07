extends State
class_name MeditatingState
## Pausa Segura por Software: el mundo sigue; el gemelo queda plantado,
## inmune y sin decay de Serenidad mientras lee el códice.


func enter(_previous_state: String) -> void:
	var c := actor as CharacterBase
	c.velocity = Vector2.ZERO
	c.hurtbox.monitoring = false
	c.serenity.set_physics_process(false)
	var poem: PoemResource = c.nearby_altar.poem
	c.get_node("/root/EventBus").artifact_read_started.emit(
		poem.artifact_id, poem.content_text
	)


func physics_update(_delta: float) -> void:
	var c := actor as CharacterBase
	c.velocity = Vector2.ZERO
	if c.interact_pressed:
		c.serenity.change(c.nearby_altar.poem.serenity_restored)
		c.get_node("/root/EventBus").artifact_read_completed.emit()
		finished.emit("Idle")


func exit() -> void:
	var c := actor as CharacterBase
	c.hurtbox.monitoring = true
	c.serenity.set_physics_process(true)
