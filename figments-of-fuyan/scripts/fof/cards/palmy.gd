extends CardGD

var trauma_charges: int = 1
func onProcessAction(action: Action) -> void:
	super(action)
	if isValidTrauma(action) and trauma_charges > 0:
		onPushAction(TraumaAction.new(self))
			
func onTrauma(_death_action: DeathAction) -> void:
	var speed: int = 1 if !ascended else 2
	var actions: Array = [StatAction.new(self, Game.Stats.MAX_SPEED, speed), CameraChangeAction.new(self)]
	trauma_charges -= 1
	onPushAction(actions)
	
func onSave() -> SavedDataCard:
	ability_save['trauma_charges'] = trauma_charges
	return super()
	
