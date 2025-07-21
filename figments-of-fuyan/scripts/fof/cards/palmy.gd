extends CardGD

const PALMY_PAUSE_DELAY: float = 2
var trauma_charges: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and trauma_charges > 0:
		onPushAction(TraumaAction.new(self, action))
			
func onTrauma(_death_action: DeathAction) -> void:
	trauma_charges -= 1
	
	var turns: int = 2 if !ascended else 0
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
	return 1
