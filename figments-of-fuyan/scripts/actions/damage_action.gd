class_name DamageAction extends Action

var Damager: GameObjectGD
var Defenders: Array
var damage: int
var is_fall_damage: bool = false

func _init(_Damager: GameObjectGD = null, _Defenders: Variant = null, _damage: int = 0, _is_fall_damage: bool = false) -> void:
	super()
	Damager = _Damager
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
	damage = _damage
	is_fall_damage = _is_fall_damage

func onPostAction() -> void:
	var stat_infos: Array = Defenders.map(func(x: GameObjectGD): return StatInfo.new(x, Game.Stats.HEALTH, -damage))
	onPushAction(StatAction.new(stat_infos))
	
func getLogInfo() -> Array:
	var arr: Array = ["Damager: " + Damager.info.name]
	for Defender in Defenders: arr.append("Defender: " + Defender.info.name)
	arr.append("Damage: " + str(damage))
	return arr
