extends CharacterBase
class_name Hunahpu
## Gemelo del Sol. Inyecta HunahpuAbility y RangedAttackComponent.

@onready var _ability: HunahpuAbility = $HunahpuAbility
@onready var _ranged: RangedAttackComponent = $RangedAttackComponent
@onready var _hitbox: Area2D = $Hitbox


func _ready() -> void:
	super._ready()
	ability = _ability
	ranged = _ranged
	hitbox = _hitbox
	_ability.setup(self, EventBus)
	_ability.ranged = _ranged
	_ranged.setup(self, serenity)
