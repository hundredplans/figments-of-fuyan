extends BoonGD

func onProcessAction(action: Action):
	super(action)
	if action is VisionAction:
		pass
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()

func onBoon(_action: Action = null):
	pass

func onBoonAdded():
	pass

func getDisabled():
	return super()

func getCharges():
	return super()
