extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	
func onAscend(state: bool) -> void:
	super(state)

func onBoon(_action: Action = null) -> void:
	pass

func onBoonAdded() -> void:
	pass

func getDisabled() -> bool:
	return super()
