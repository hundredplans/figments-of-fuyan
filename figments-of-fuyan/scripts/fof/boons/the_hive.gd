extends BoonGD

func onProcessAction(action: Action):
	super(action)
	if action.post:
		if action is DeathAction and action.Defender is CardGD and action.Defender.isAlly(1):
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()
	
func onBoon(_action: DeathAction):
	onPushAction(StatAction.new(Game.getAllyUnits(1).map(func(x: CardGD): return StatInfo.new(x, Game.Stats.ATTACK, 1, 2))))

func onBoonAdded():
	pass

func getDisabled():
	return super()

func getCharges():
	return super()
