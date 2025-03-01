extends BoonGD

func onProcessAction(action: Action):
	super(action)
	if !action.post:
		if action is ToolActivatedAction and action.Tool.Card != null and action.Tool.Card.isAlly(0):
			onForceAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()

func onBoon(action: ToolActivatedAction):
	action.onFailAction()

func onBoonAdded():
	pass

func getDisabled():
	return super()
