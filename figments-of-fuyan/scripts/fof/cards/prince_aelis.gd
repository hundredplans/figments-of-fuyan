extends CardGD

func onChangeHandCardsEnergy(delta: int) -> void:
	for HandCard: CardGD in get_tree().get_nodes_in_group("HandCardsGD"):
		onPushAction(CardEnergyAction.new(HandCard, delta))

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onChangeHandCardsEnergy(-1)
	elif isValidLastWill(action):
		onChangeHandCardsEnergy(1)
	elif action.post and action is HandCardAction and isAlive():
		onPushAction(CardEnergyAction.new(action.Card, -1))
	
func getDescription() -> String:
	return super()
