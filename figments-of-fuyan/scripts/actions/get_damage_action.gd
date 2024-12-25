class_name GetDamageAction extends Action

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
	
func onPreAction():
	pass
	
func onPostAction():
	pass
