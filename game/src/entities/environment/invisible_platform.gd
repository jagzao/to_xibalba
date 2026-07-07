extends StaticBody2D
class_name InvisiblePlatform
## Plataforma invisible cuya colisión depende del ratio de Serenidad.

@export var data: PlayerDataResource
@export var serenity_threshold: float = 0.30

var _collision: CollisionShape2D = null


func _ready() -> void:
	_find_collision()
	_update_collision()


func _physics_process(_delta: float) -> void:
	_update_collision()


func _find_collision() -> void:
	for child: Node in get_children():
		if child is CollisionShape2D:
			_collision = child
			break


func _update_collision() -> void:
	if _collision == null:
		_find_collision()
	if data == null or _collision == null:
		return
	var ratio: float = data.current_serenity / data.max_serenity
	_collision.disabled = ratio < serenity_threshold
