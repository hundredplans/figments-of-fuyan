extends CardGD

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 1
const TIER_THREE_HEAL: int = 2
const TIER_FOUR_HEAL: int = 2

var revenge_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRevenge(action) and revenge_charges != 0:
		onPushAction(RevengeAction.new(self, action.owner, true))
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [revenge_charges])
	
func onRevenge(action: DamageAction) -> void:
	super(action)
	var palm_ids: Array = Helper.getFofInfoID(AreaInfo, 1).card_ids
	if getVisibleFieldCardsAllies().any(func(x: CardGD): return x.info.id in palm_ids):
		revenge_charges -= 1
		onPushAction(HealAction.new(HealDatastore.new(self, getTierHeal())))

func onRegularReset() -> void:
	super()
	revenge_charges = getDefaultCharges()
	
func getDefaultCharges() -> int:
	return 2

func onSave() -> SavedDataCard:
	ability_save['revenge_charges'] = revenge_charges
	return super()
	
func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0
