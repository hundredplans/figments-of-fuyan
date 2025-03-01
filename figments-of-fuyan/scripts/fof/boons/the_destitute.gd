extends BoonGD

func onProcessAction(action: Action):
	super(action)
	if !action.post:
		if action is EnergyAction and action.owner is DeathAction and action.delta > 1:
			onForceAction(BoonActivatedAction.new(self, action))
			
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()

func onBoon(action: EnergyAction):
	action.energy -= 1

func onBoonAdded():
	pass

func getDisabled():
	return super()

func isAddRequirementMet() -> bool:
	return get_tree().get_nodes_in_group("DeckCardsGD").any(func(x: CardGD): return x.Tool != null)
