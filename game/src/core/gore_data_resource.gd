extends Resource
class_name GoreDataResource
## Datos de pivotes y texturas para desmembramiento/gore.

@export var head_pivots: Array[Vector2] = []
@export var torso_pivots: Array[Vector2] = []
@export var limb_pivots: Array[Vector2] = []
@export var bone_exposed_texture: Texture2D
@export var blood_shader_params: Dictionary = {}
