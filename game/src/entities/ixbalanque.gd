extends CharacterBase
class_name Ixbalanque
## Gemelo de la Luna. Inyecta IxbalanqueAbility y MeleeAttackComponent.

@onready var _ability: IxbalanqueAbility = $IxbalanqueAbility
@onready var _melee: MeleeAttackComponent = $MeleeAttackComponent
@onready var _hitbox: Area2D = $Hitbox


func _ready() -> void:
	super._ready()
	ability = _ability
	melee = _melee
	hitbox = _hitbox
	_ability.setup(self, EventBus)
	_ability.melee = _melee
	_melee.setup(self, serenity, _hitbox)
