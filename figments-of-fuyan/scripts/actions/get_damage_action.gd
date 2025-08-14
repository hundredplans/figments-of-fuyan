class_name GetDamageAction extends Action

const SHIELD_ID: int = 3

var Damager: GameObjectGD
var Defender: CardGD
var damage: int
var damage_type: Game.DamageTypes
var ignore_armor_shield: bool
enum DamageType {ATTACK, FALL_DAMAGE, OTHER}

var armor: int
var mults: Array
var adds: Array

func _init(_Damager: GameObjectGD = null, _Defender: CardGD = null, _damage: int = 0, _damage_type := Game.DamageTypes.OTHER) -> void:
	super()
	Damager = _Damager
	Defender = _Defender
	damage = _damage
	damage_type = _damage_type
	
func onPreAction():
	pass
	
func onPostAction():
	for add in adds: damage += add
	for mult in mults: damage *= mult
	damage = max(damage, 0)
	
	if ignore_armor_shield: return
	var ShieldFieldEffect: FieldEffectGD = Defender.getFirstFieldEffect(SHIELD_ID)
	if ShieldFieldEffect != null:
		damage = 1
		
	damage = max(damage - armor, 0)
	
func setArmor(_armor: int) -> void:
	armor = _armor
	
func onAdd(value: int) -> void:
	adds.append(value)
	
func onMult(value: int) -> void:
	mults.append(value)
	
func setIgnoreArmorShield(value: bool) -> void:
	ignore_armor_shield = value
	
func getDamage() -> int:
	return damage
