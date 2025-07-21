extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.HAND:
			onResetCharges()
		elif action is PlayCardAction:
			onPushAction(ChangeBoonChargesAction.new(self, 1))
	
func onAscend(state: bool) -> void:
	super(state)

func onBoon(_action: Action = null) -> void:
	var energy_gain: int = 1 if !ascended else 2
	onPushAction(EnergyAction.new(energy_gain))

func onBoonAdded() -> void:
	super()
	
func getDisabled() -> bool:
	return false
	
func onChangeCharges(delta: int) -> void:
	super(delta)
	if charges != 0 and charges % 2 == 0:
		onPushAction(BoonActivatedAction.new(self, null))
	
