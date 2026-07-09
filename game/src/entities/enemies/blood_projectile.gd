extends Area2D
class_name BloodProjectile
## Proyectil de sangre de Vucub-Camé. Resta Serenidad al impactar jugador.

@export var speed: float = 250.0
@export var serenity_damage: float = 15.0

var direction: Vector2 = Vector2.LEFT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	var player := body as CharacterBase
	if player == null:
		return
	if player.data != null:
		player.data.change_serenity(-serenity_damage)
		player.serenity.change(0.0)
	queue_free()


func setup(dir: Vector2, dmg: float) -> void:
	direction = dir.normalized()
	serenity_damage = dmg
