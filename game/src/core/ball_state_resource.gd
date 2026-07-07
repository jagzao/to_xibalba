extends Resource
class_name BallStateResource
## Datos de balance de la pelota mística.

enum State { LIGHT, DARKNESS }

@export var base_speed: float = 250.0
@export var light_multiplier: float = 1.2
@export var darkness_multiplier: float = 1.0
@export var graze_damage: float = 25.0
