extends CardGD

const TIER_ONE_TURNS: int = 2
const TIER_TWO_TURNS: int = -1
const TIER_THREE_TURNS: int = -1
const TIER_FOUR_TURNS: int = -1

const TIER_ONE_CHARGES: int = 1
const TIER_TWO_CHARGES: int = 1
const TIER_THREE_CHARGES: int = 2
const TIER_FOUR_CHARGES: int = 2

const PALMY_PAUSE_DELAY: float = 2
var trauma_charges: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and trauma_charges > 0:
		onPushAction(TraumaAction.new(self, action))
			
func onTrauma(_death_action: DeathAction) -> void:
	trauma_charges -= 1
	
	var turns: int = getTierTurns()
	onForceAction(CameraChangeAction.new(self))
	var stat_action := StatAction.new(StatInfo.new(self, Game.Stats.MAX_SPEED, 1, turns))
	
	if isLevelVisible():
		stat_action.setActionDelay(PALMY_PAUSE_DELAY)
	
	onPushAction(stat_action)
	
func onRegularReset() -> void:
	super()
	trauma_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['trauma_charges'] = trauma_charges
	return super()
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [trauma_charges])

func getDefaultCharges() -> int:
	return getTierCharges()

func getTierTurns() -> int:
	match tier:
		1: return TIER_ONE_TURNS
		2: return TIER_TWO_TURNS
		3: return TIER_THREE_TURNS
		4: return TIER_FOUR_TURNS
	return 0
	
func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0
