class_name DamageAction extends Action

var Damager: GameObjectGD
var Defenders: Array
var damage: int
var damage_type: Game.DamageTypes
var ignore_armor_shield: bool
var armor: int

const SHIELD_ID: int = 3

func _init(_Damager: GameObjectGD = null, _Defenders: Variant = null, _damage: int = 0, _damage_type := Game.DamageTypes.ATTACK) -> void:
	super()
	Damager = _Damager
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
	damage = _damage
	damage_type = _damage_type

func setIgnoreArmorShield(state: bool) -> void:
	ignore_armor_shield = state
	
func setArmor(val: int) -> void:
	armor = val

func onPreAction() -> void:
	if Defenders.is_empty(): onFailAction()

func onPostAction() -> void:
	var actions: Array = []
	var stat_infos: Array = []
	
	for Card: CardGD in Defenders:
		var ShieldFieldEffect: FieldEffectGD = Card.getFirstFieldEffect(SHIELD_ID)
		var new_damage: int = max(0, damage)
		if !ignore_armor_shield:
			new_damage = max(0, new_damage - armor)
			if ShieldFieldEffect != null:
				new_damage = min(damage, 1)
				if new_damage > 0:
					actions.append(RemoveFieldEffectAction.new(ShieldFieldEffect))
		new_damage *= -1
		stat_infos.append(StatInfo.new(Card, Game.Stats.HEALTH, new_damage))
	
	var stat_action := StatAction.new(stat_infos)
	stat_action.setLockActionDelay(lock_action_delay)
	actions.push_front(stat_action)
	onPushAction(actions)
	
func getLogInfo() -> Array:
	var arr: Array = ["Damager: " + Damager.info.name]
	for Defender in Defenders: arr.append("Defender: " + Defender.info.name)
	arr.append("Damage: " + str(damage))
	return arr
