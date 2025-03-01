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
	onResetCharges()

func getDisabled() -> bool:
	return super()
