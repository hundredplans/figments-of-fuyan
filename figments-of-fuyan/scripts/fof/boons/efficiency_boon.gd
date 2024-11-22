extends BoonGD

var played_this_turn: int = 0
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and action.phase == Game.Phases.HAND:
			onPushAction(BoonActivatedAction.new(self, action))
		elif action is PlayCardAction:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onUpdateAscenscion() -> void:
	super()

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	if action is ChangePhaseAction:
		played_this_turn = 0
	elif action is PlayCardAction:
		played_this_turn += 1
		if played_this_turn == 2:
			var energy_gain: int = 1 if !ascended else 2
			onPushAction(EnergyAction.new(energy_gain))

func onBoonAdded() -> void:
	pass

func onSave() -> SavedDataBoon:
	ability_save['played_this_turn'] = played_this_turn
	return super()
	
func getDisabled() -> bool:
	return played_this_turn >= 2
	
func getCharges() -> int:
	return played_this_turn
