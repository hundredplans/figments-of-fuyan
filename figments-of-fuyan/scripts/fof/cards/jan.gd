extends CardGD

var rampage_charges: int = 1
const DEFAULT_ATTACK: int = 1
const ASCENDED_ATTACK: int = 2
const RAMPAGE_DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges > 0:
		onPushAction(RampageAction.new(self, action))
	
func onRampage(_death_action: DeathAction) -> void:
	var attack_value: int = DEFAULT_ATTACK if !getAscended() else ASCENDED_ATTACK
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(RAMPAGE_DELAY)
	
	var camera_change_action := CameraChangeAction.new(self)
	rampage_charges -= 1
	
	onPushAction([camera_change_action, animation_action, StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, attack_value))])

func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	return super()
	
func onRegularReset() -> void:
	super()
	rampage_charges = getDefaultCharges()
	
func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [rampage_charges])
	
func getDefaultCharges() -> int:
	return 1
