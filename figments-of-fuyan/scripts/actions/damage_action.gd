class_name DamageAction extends Action

var Damager: GameObjectGD
var Defenders: Array
var damage: int
var damage_type: Game.DamageTypes

func _init(_Damager: GameObjectGD = null, _Defenders: Variant = null, _damage: int = 0, _damage_type := Game.DamageTypes.ATTACK) -> void:
	super()
	Damager = _Damager
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
	damage = _damage
	damage_type = _damage_type

func onPreAction() -> void:
	if Defenders.is_empty(): onFailAction()

func onPostAction() -> void:
	var stat_infos: Array = Defenders\
		.filter(func(x: GameObjectGD): return x is CardGD)\
		.map(func(x: GameObjectGD): return StatInfo.new(x, Game.Stats.HEALTH, -damage))
	
	var stat_action := StatAction.new(stat_infos)
	stat_action.setLockActionDelay(lock_action_delay)
	onPushAction(stat_action)
	
func getLogInfo() -> Array:
	var arr: Array = ["Damager: " + Damager.info.name]
	for Defender in Defenders: arr.append("Defender: " + Defender.info.name)
	arr.append("Damage: " + str(damage))
	return arr
