extends BoonGD

const SHILLING_AMOUNT: int = 2
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Damager != null and action.Damager.isValidDuelistRampage(action):
			onPushAction(ChangeShillingsAction.new(SHILLING_AMOUNT))
	
func onAscend(state: bool) -> void:
	super(state)

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
