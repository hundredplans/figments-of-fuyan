extends CardGD

const PALMY_PAUSE_DELAY: float = 2
var trauma_charges: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and trauma_charges > 0:
		onPushAction(TraumaAction.new(self, action))
			
func onTrauma(_death_action: DeathAction) -> void:
	var speed: int = 1 if !ascended else 2
	var camera_change_action := CameraChangeAction.new(self)
	camera_change_action.setActionDelayWithOverride(PALMY_PAUSE_DELAY)
	var actions: Array = [StatAction.new(StatInfo.new(self, Game.Stats.MAX_SPEED, speed)), camera_change_action]
	trauma_charges -= 1
	onPushAction(actions)
	
func onSave() -> SavedDataCard:
	ability_save['trauma_charges'] = trauma_charges
	return super()
	
func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [trauma_charges], [["TRAUMA ", "[1]"]])
