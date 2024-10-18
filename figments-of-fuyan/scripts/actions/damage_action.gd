class_name DamageAction extends Action

var Damager: GameObjectGD
var Defender: GameObjectGD
var damage: int
var is_fall_damage: bool = false

func _init(_Damager: GameObjectGD = null, _Defender: GameObjectGD = null, _damage: int = 0, _is_fall_damage: bool = false) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	is_fall_damage = _is_fall_damage

func onPostAction() -> void:
	onPushAction(StatAction.new(Defender, Game.Stats.HEALTH, -damage))
