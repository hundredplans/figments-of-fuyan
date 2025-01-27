class_name GetDamageAction extends Action

var Damager: GameObjectGD
var Defenders: Array
var damage: int
var damage_type: Game.DamageTypes

enum DamageType {ATTACK, FALL_DAMAGE, OTHER}

var mults: Array
var adds: Array

func _init(_Damager: GameObjectGD = null, _Defenders: Variant = null, _damage: int = 0, _damage_type := Game.DamageTypes.OTHER) -> void:
	super()
	Damager = _Damager
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
	damage = _damage
	damage_type = _damage_type
	
func onPreAction():
	pass
	
func onPostAction():
	for add in adds: damage += add
	for mult in mults: damage *= mult
	damage = max(damage, 0)
	
func onAdd(value: int) -> void:
	adds.append(value)
	
func onMult(value: int) -> void:
	mults.append(value)
	
