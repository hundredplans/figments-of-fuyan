extends ToolGD

const ARMOR_TRAIT_ID: int = 1

const TIER_ONE_ARMOR_VALUE: int = 1
const TIER_TWO_ARMOR_VALUE: int = 1
const TIER_THREE_ARMOR_VALUE: int = 2
const TIER_FOUR_ARMOR_VALUE: int = 2

const TIER_ONE_TURNS: int = 2
const TIER_TWO_TURNS: int = 3
const TIER_THREE_TURNS: int = 2
const TIER_FOUR_TURNS: int = 3

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if Card != null and Card.isValidRevenge(action) and charges != 0:
			onPushAction(ToolActivatedAction.new(self, action))
	
func onToolAction(_action: StatAction) -> void:
	var trait_data := SavedDataTrait.new(ARMOR_TRAIT_ID, true, 0, getArmorValue())
	
	var overworld_trait := OverworldTrait.new(trait_data, OverworldTrait.AddedBy.BUCKLER, true, getArmorTurns())
	var actions: Array = [AddOverworldTraitAction.new(Card, overworld_trait, true), ChangeToolChargesAction.new(self, -1)]
	onPushAction(actions)
	
func getArmorValue() -> int:
	match tier:
		1: return TIER_ONE_ARMOR_VALUE
		2: return TIER_TWO_ARMOR_VALUE
		3: return TIER_THREE_ARMOR_VALUE
		4: return TIER_FOUR_ARMOR_VALUE
	return 0
	
func getArmorTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
	
func onRetiered(tier: int) -> void:
	super(tier)
	onResetCharges()
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])
	
func getDefaultCharges() -> int:
	return 1 if tier == 1 else 2
