class_name DamageAction extends Action

var Damager: FofGD
var Defenders: Array
var damage: int
var damage_type: Game.DamageTypes
var ignore_armor_shield: bool
var ignore_armor_shield_success: bool
var armor: int
var fatal: bool

const SELFISH_BOON_ID: int = 27
const SHIELD_ID: int = 3

func _init(_Damager: FofGD = null, _Defenders: Variant = null, _damage: int = 0, _damage_type := Game.DamageTypes.ATTACK) -> void:
	super()
	Damager = _Damager
	
	if _Defenders is Array: Defenders = _Defenders
	elif _Defenders is GameObjectGD: Defenders = [_Defenders]
	
	damage = _damage
	damage_type = _damage_type
	
func setFatal(state: bool) -> void:
	fatal = state

func setIgnoreArmorShield(state: bool) -> void:
	ignore_armor_shield = state
	
func setArmor(val: int) -> void:
	armor = val

func onPreAction() -> void:
	if Defenders.is_empty(): onFailAction()

func onPostAction() -> void:
	var actions: Array = []
	var stat_infos: Array = []
	
	var selfish_boon_action: BoonActivatedAction
	for Card: CardGD in Defenders:
		var ShieldFieldEffect: FieldEffectGD = Card.getFirstFieldEffect(SHIELD_ID)
		var new_damage: int = max(0, damage) if (!fatal) else 99
		if !ignore_armor_shield:
			new_damage = max(0, new_damage - armor)
			if ShieldFieldEffect != null and new_damage > 0:
				new_damage = max(0, 1 - armor)
				actions.append(RemoveFieldEffectAction.new(ShieldFieldEffect))
		elif ShieldFieldEffect != null or armor > 0:
			setIgnoreArmorShieldSuccess(true)
			
		var SelfishBoon: BoonGD = Game.getSaveFile().getBoon(SELFISH_BOON_ID)
		if SelfishBoon != null and Card.isAlly(0) and Card.getRarity() == Game.Rarities.CHAMPION and new_damage > 0 and Card.getVisibleFieldCardsAllies().size() > 0:
			new_damage = max(new_damage - 1, 0)
			selfish_boon_action = BoonActivatedAction.new(SelfishBoon, self)
			
		new_damage *= -1
		stat_infos.append(StatInfo.new(Card, Game.Stats.HEALTH, new_damage))
	
	var stat_action := StatAction.new(stat_infos)
	stat_action.setLockActionDelay(lock_action_delay)
	actions.append(stat_action)
	if selfish_boon_action != null:
		actions.append(selfish_boon_action)
	onPushAction(actions)
	
func isIgnoreArmorShieldSuccess() -> bool:
	return ignore_armor_shield_success
	
func setIgnoreArmorShieldSuccess(_ignore_armor_shield_success: bool) -> void:
	ignore_armor_shield_success = _ignore_armor_shield_success
	
func getLogInfo() -> Array:
	var arr: Array = ["Damager: " + Damager.info.name]
	for Defender in Defenders: arr.append("Defender: " + Defender.info.name)
	arr.append("Damage: " + str(damage))
	return arr
