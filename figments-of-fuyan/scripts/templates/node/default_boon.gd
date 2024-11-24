extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onAscend(state: bool) -> void:
	super()

func getDescription() -> String:
	return super()

func onBoon(_action: Action = null) -> void:
	pass

func onBoonAdded() -> void:
	pass

func getDisabled() -> bool:
	return super()

func getCharges() -> int:
	return super()
