extends Node
class_name BossDirector
## Sincroniza combate doble Hun-Camé / Vucub-Camé.

@export var stats: BossStatsResource
@export var blackboard: SharedBlackboard

var hun_came: HunCameAI = null
var vucub_came: VucubCameAI = null
var _swap_timer: float = 0.0
var _desperation: bool = false


func start_fight() -> void:
	if blackboard == null:
		blackboard = SharedBlackboard.new()
	blackboard.attack_token = "HunCame"
	_swap_timer = 0.0
	_desperation = false


func register_boss(hun: HunCameAI, vucub: VucubCameAI) -> void:
	hun_came = hun
	vucub_came = vucub
	if hun != null:
		hun.died.connect(_on_boss_died)
	if vucub != null:
		vucub.died.connect(_on_boss_died)


func update(delta: float, player: CharacterBase) -> void:
	if blackboard == null or player == null:
		return
	blackboard.player_position = player.global_position
	if _desperation:
		return
	_swap_timer += delta
	if _swap_timer >= stats.token_swap_interval:
		_swap_timer = 0.0
		_swap_token()


func _swap_token() -> void:
	if blackboard.attack_token == "HunCame":
		blackboard.attack_token = "VucubCame"
	else:
		blackboard.attack_token = "HunCame"


func _on_boss_died() -> void:
	if _desperation:
		return
	_desperation = true
	blackboard.desperation_active = true
	if hun_came != null and not hun_came.is_dead():
		hun_came.activate_desperation()
	if vucub_came != null and not vucub_came.is_dead():
		vucub_came.activate_desperation()
