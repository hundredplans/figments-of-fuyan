extends CardGD
	
var rampage_charges: int = 1
const RAMPAGE_DELAY: float = 2.0

func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [rampage_charges], [["RAMPAGE ", "[1]"]])

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidRampage(action) and rampage_charges > 0:
		onPushAction(RampageAction.new(self, action))
	
func onRampage(_death_action: DeathAction) -> void:
	var attack_value: int = 1
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(RAMPAGE_DELAY)
	
	var camera_change_action := CameraChangeAction.new(self)
	rampage_charges -= 1
	
	var shield_action: AddFieldEffectAction = onCreateBaseFieldEffectAction(SHIELD_ID)
	onPushAction([camera_change_action, animation_action,
		StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, attack_value)),
		shield_action])
	
func getDefaultCharges() -> int:
	return 1
	
func onRegularReset() -> void:
	super()
	rampage_charges = getDefaultCharges()
	
func onSave() -> SavedDataCard:
	ability_save['rampage_charges'] = rampage_charges
	return super()
	
