class_name HurtAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int
var health_damage: int

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _health_damage: int = 0) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	health_damage = _health_damage
	
func onPreAction() -> void:
	setActionDelay(0.0 if health_damage == 0 else 1.8)

func onPostAction() -> void:
	if health_damage > 0: Defender.onHurt()
