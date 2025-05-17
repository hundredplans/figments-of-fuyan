extends CardGD

var bloodthirst_trigger_amount: int = 0 # Oscillates between 1 -> 2
const TRIGGER_BLOODTHIRST_AMOUNT: int = 2
const BLOODTHIRST_DELAY: float = 2.0

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidBloodthirst(action):
		onPushAction(BloodthirstAction.new(self, action))
	
func getDescription() -> String:
	return Helper.getDescription(super(), [bloodthirst_trigger_amount])

func onBloodthirst(action: DeathAction) -> void:
	bloodthirst_trigger_amount += 1
	if bloodthirst_trigger_amount < TRIGGER_BLOODTHIRST_AMOUNT: return
	else: bloodthirst_trigger_amount = 0
	
	var animation_action := AnimationAction.new(self, "Ability")
	animation_action.setActionDelay(BLOODTHIRST_DELAY)
	
	var actions: Array = [CameraChangeAction.new(self), animation_action, onGainShieldAction()]
	onPushAction(actions)

func onRegularReset() -> void:
	super()
	bloodthirst_trigger_amount = getDefaultCharges()
	
func getDefaultCharges() -> int:
	return 0

func onSave() -> SavedDataCard:
	ability_save['bloodthirst_trigger_amount'] = bloodthirst_trigger_amount
	return super()
