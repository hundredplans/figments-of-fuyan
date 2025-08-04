extends CardGD

const TIER_ONE_MAX_HP: int = 1
const TIER_TWO_MAX_HP: int = 2
const TIER_THREE_MAX_HP: int = 2
const TIER_FOUR_MAX_HP: int = 3

var when_healed_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidWhenHealed(action) and when_healed_charges > 0: # Has to be max hp
		onPushAction(WhenHealedAction.new(self, action))

func onWhenHealed(_action: StatAction) -> void:
	when_healed_charges -= 1
	var max_hp_gain: int = getTierMaxHp()
	onPushAction(StatAction.new(StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [max_hp_gain, max_hp_gain])))

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [when_healed_charges])

func getDefaultCharges() -> int:
	return 3
	
func onSave() -> SavedDataCard:
	ability_save['when_healed_charges'] = when_healed_charges
	return super()
	
func onRegularReset() -> void:
	super()
	when_healed_charges = getDefaultCharges()

func getTierMaxHp() -> int:
	match tier:
		1: return TIER_ONE_MAX_HP
		2: return TIER_TWO_MAX_HP
		3: return TIER_THREE_MAX_HP
		4: return TIER_FOUR_MAX_HP
	return 0
