extends ToolGD

var trauma_charges: int
const TIER_ONE_CHARGES: int = 2
const TIER_TWO_CHARGES: int = -1
const TIER_THREE_CHARGES: int = -1
const TIER_FOUR_CHARGES: int = -1

const MINIMUM_TIER_ALLY_DIES: int = 3
const MINIMUM_TIER_UNIT_DIES: int = 4

const TIER_ONE_HEAL: int = 1
const TIER_TWO_HEAL: int = 1
const TIER_THREE_HEAL: int = 1
const TIER_FOUR_HEAL: int = 1

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if Card != null and charges != 0 and action is DeathAction and\
		(isValidTrauma(action) or isValidUnitDies() or isValidAllyDies(action)):
			onPushAction(ToolActivatedAction.new(self, getHealAction()))

func isValidTrauma(action: Action) -> bool:
	return Card.isValidTrauma(action) and tier < MINIMUM_TIER_ALLY_DIES
	
func isValidAllyDies(action: Action) -> bool:
	return tier >= MINIMUM_TIER_ALLY_DIES and action.Defender.isAlly(Card.getTeam())
		
func isValidUnitDies() -> bool:
	return tier >= MINIMUM_TIER_UNIT_DIES

func onToolAction(heal_action: HealAction) -> void:
	onPushAction([heal_action, ChangeToolChargesAction.new(self, -1, getDefaultCharges() == -1)])

func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0

func getTierHeal() -> int:
	match tier:
		1: return TIER_ONE_HEAL
		2: return TIER_TWO_HEAL
		3: return TIER_THREE_HEAL
		4: return TIER_FOUR_HEAL
	return 0
	
func getDefaultCharges() -> int:
	return getTierCharges()
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])

func onRetiered(_tier: int) -> void:
	super(_tier)
	onResetCharges()

func getHealAction() -> HealAction:
	var heal: int = getTierHeal()
	var heal_action := HealAction.new(HealDatastore.new(Card, heal))
	return heal_action
