extends CardGD

const TIER_ONE_MULT: int = 1
const TIER_TWO_MULT: int = 2
const TIER_THREE_MULT: int = 2
const TIER_FOUR_MULT: int = 3

const COCONUT_SPRINGS_ID: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is GetDamageAction and action.Damager == self and action.damage_type == Game.DamageTypes.ATTACK:
			action.onAdd(getExtraDamage(action.Defender))
		elif action is AttackAction and action.Attacker == self and action.Defenders.size() == 1:
			action.onAddPlusDamage(getExtraDamage(action.Defenders[0]))
			
func getExtraDamage(Defender: CardGD) -> int:
	var card_ids: Array = Helper.getFofInfoID(AreaInfo, COCONUT_SPRINGS_ID).card_ids
	return Defender.getDeathIds().filter(func(x: int): return x in card_ids).size() * getTierMult()
	
func getTierMult() -> int:
	match tier:
		1: return TIER_ONE_MULT
		2: return TIER_TWO_MULT
		3: return TIER_THREE_MULT
		4: return TIER_FOUR_MULT
	return 0
	
