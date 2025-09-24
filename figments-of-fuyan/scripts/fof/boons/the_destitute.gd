extends BoonGD

func onProcessAction(action: Action):
	super(action)
	#if !action.post:
		#if action is EnergyAction and action.owner is DeathAction and action.delta > 1:
			#onForceAction(BoonActivatedAction.new(self, action))

func onBoonAdded():
	pass

func isAddRequirementMet() -> bool:
	return get_tree().get_nodes_in_group("DeckCardsGD").any(func(x: CardGD): return x.Tool != null)
