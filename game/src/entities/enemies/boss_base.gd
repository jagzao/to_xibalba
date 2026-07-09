extends CharacterBody2D
class_name BossBase
## Base común para jefes (Hun-Camé / Vucub-Camé). Sin lógica de movimiento compleja.

signal died

@export var stats: BossStatsResource
@export var blackboard: SharedBlackboard

var health: float = 200.0
var _dead: bool = false
var _desperation: bool = false


func _ready() -> void:
	if stats != null:
		health = stats.health
	_connect_hurtbox()
	_connect_hitbox()


func _connect_hurtbox() -> void:
	var hurtbox := get_node_or_null("Hurtbox") as Area2D
	if hurtbox == null:
		return
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)


func _connect_hitbox() -> void:
	var hitbox := get_node_or_null("Hitbox") as Area2D
	if hitbox == null:
		return
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		# Las hitboxes de jugador exponen take_hit(damage) o similar.
		# ponytail: asumimos que el área que entra es un hitbox ofensivo.
		var damage: float = area.get("damage") if area.get("damage") != null else 10.0
		take_damage(damage)


func _on_hitbox_body_entered(body: Node2D) -> void:
	var target := body as CharacterBase
	if target == null:
		return
	_deal_damage_to(target)


func _deal_damage_to(_target: CharacterBase) -> void:
	# Sobrescribir en subclases.
	pass


func take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0.0 and not _dead:
		_dead = true
		died.emit()


func is_dead() -> bool:
	return _dead


func activate_desperation() -> void:
	_desperation = true
	scale *= stats.desperation_size_scale


func is_in_desperation() -> bool:
	return _desperation


func has_attack_token() -> bool:
	if blackboard == null:
		return false
	var my_name: String = _get_name()
	return blackboard.attack_token == my_name


func _get_name() -> String:
	return ""
