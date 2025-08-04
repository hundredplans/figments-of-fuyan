extends BoonGD

const TIER_ONE_CHARGES: int = 1
const TIER_TWO_CHARGES: int = 2
const TIER_THREE_CHARGES: int = 3
const TIER_FOUR_CHARGES: int = 4

func getDefaultCharges(_tier: int = tier) -> int:
	match _tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0

func onBoonAdded() -> void:
	super()

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is StatAction and action.getCards().any(func(x: CardGD): return x.isAlly(0))\
		and !action.stat_infos.all(func(x: StatInfo): return x.values.all(func(y: int): return y <= 0)\
		or x.absolute or x.immutable) and charges > 0:
			onForceAction(BoonActivatedAction.new(self, action))

func onRetiered(_tier: int) -> void:
	var old_tier: int = tier
	super(_tier)
	if old_tier == tier: return
	var charges_difference: int = getDefaultCharges(tier) - getDefaultCharges(old_tier)
	onPushAction(ChangeBoonChargesAction.new(self, charges_difference))

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])

func onBoon(action: Action) -> void:
	onPushAction(ChangeBoonChargesAction.new(self, -1))
	var stat_infos: Array = action.stat_infos.filter(func(x: StatInfo): return x.Card.isAlly(0) and !x.absolute and !x.immutable)
	for stat_info in stat_infos:
		var values: Array = range(stat_info.values.size()).filter(func(i: int): return stat_info.values[i] > 0)
		for i in values:
			stat_info.values[i] *= 2
	
func getDisabled() -> bool:
	return charges == 0
	
