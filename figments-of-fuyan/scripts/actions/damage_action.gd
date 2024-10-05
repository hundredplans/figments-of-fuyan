class_name DamageAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage

func onPostAction() -> void:
	Defender.onDMG(Damager, damage)
