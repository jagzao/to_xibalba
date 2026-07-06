extends Resource
class_name MovementStatsResource
## Balance de movimiento. Nunca hardcodear estos valores en lógica.

@export var speed: float = 150.0
@export var jump_velocity: float = -320.0
@export var gravity: float = 980.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var dash_speed: float = 400.0
@export var dash_iframes: int = 12
@export var frames_per_second: float = 60.0
