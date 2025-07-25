extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)

func onBoon(_action: Action = null) -> void:
	pass

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
