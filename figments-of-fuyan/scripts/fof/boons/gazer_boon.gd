extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(_action: Action = null) -> void:
	pass

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
	
func getDefaultCharges() -> int:
	return 3
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
