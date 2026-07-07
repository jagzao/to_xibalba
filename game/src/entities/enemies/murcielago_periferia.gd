extends CharacterBody2D
class_name MurcielagoPeriferia
## Murciélago de la Periferia: pasivo con luz alta, carga cuando la Serenidad baja.

@export var stats: MurcielagoResource
@export var player_data: PlayerDataResource
@export var player: CharacterBase = null

var _direction: float = 1.0


func _physics_process(delta: float) -> void:
	if player_data == null or stats == null:
		return
	var ratio: float = player_data.current_serenity / player_data.max_serenity
	var speed: float = stats.passive_speed
	var velocity := Vector2.ZERO
	if ratio < stats.serenity_threshold and player != null:
		speed = stats.charge_speed
		velocity = (player.global_position - global_position).normalized() * speed
	else:
		velocity = Vector2(_direction * speed, 0.0)
		if abs(global_position.x) > 200.0:
			_direction *= -1.0
	set_velocity(velocity)
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	var c := body as CharacterBase
	if c == null:
		return
	if player == null:
		player = c
	c.blood_circle.take_damage(stats.blood_damage)
