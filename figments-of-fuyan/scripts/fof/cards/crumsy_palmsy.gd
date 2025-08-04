extends CardGD

const ANIMATION_DELAY: float = 2.0
const STAT_CHANGE_DELAY: float = 2.0

var rampage_charges: int
var trauma_charges: int
var bloodthirst_charges: int

const TIER_ONE_CHARGES: int = 1
const TIER_TWO_CHARGES: int = 2
const TIER_THREE_CHARGES: int = -1
const TIER_FOUR_CHARGES: int = -1

func onAwaken() -> void:
	super()
	onResetCharges()

func onFofInit() -> void:
	super()
	onResetCharges()

func onRegularReset() -> void:
	super()
	onResetCharges()
	
func onRetiered(tier: int) -> void:
	super(tier)
	onResetCharges()

func onResetCharges() -> void:
	var default_charges: int = getTierCharges()
	rampage_charges = default_charges
	trauma_charges = default_charges
	bloodthirst_charges = default_charges

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges != 0:
		onPushAction(RampageAction.new(self, action))
	elif isValidTrauma(action) and trauma_charges != 0:
		onPushAction(TraumaAction.new(self, action))
	elif isValidBloodthirst(action) and bloodthirst_charges != 0:
		onPushAction(BloodthirstAction.new(self, action))
	
func onRampage(_action: DeathAction) -> void:
	onEffect()
	if rampage_charges > 0:
		rampage_charges -= 1
	
func onTrauma(_action: DeathAction) -> void:
	onEffect()
	if trauma_charges > 0:
		trauma_charges -= 1
	
func onBloodthirst(_action: DeathAction) -> void:
	onEffect()
	if bloodthirst_charges > 0:
		bloodthirst_charges -= 1
	
func onEffect() -> void:
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(ANIMATION_DELAY)
	
	var stat_action := StatAction.new(StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1]))
	if isLevelVisible():
		stat_action.setActionDelay(STAT_CHANGE_DELAY)
	
	var actions: Array = [animation_action, stat_action]
	onPushAction(actions)
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [rampage_charges, trauma_charges, bloodthirst_charges])
	
func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	ability_save['trauma_charges'] = trauma_charges
	ability_save['bloodthirst_charges'] = bloodthirst_charges
	return super()
	
func getTierCharges() -> int:
	match tier:
		1: return TIER_ONE_CHARGES
		2: return TIER_TWO_CHARGES
		3: return TIER_THREE_CHARGES
		4: return TIER_FOUR_CHARGES
	return 0
