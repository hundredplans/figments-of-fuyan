extends BoonGD

func onProcessAction(action: Action):
	super(action)
	if !action.post:
		if action is StatAction:
			onForceAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool):
	super(state)

func getDescription():
	return super()

func onBoon(action: StatAction):
	for stat_info in action.stat_infos.filter(func(x: StatInfo): return x.Card.isAlly(0)):
		if !stat_info.immutable and !stat_info.absolute:
			for i in range(stat_info.values.size()):
				if stat_info.types[i] != Game.Stats.HEALTH:
					if stat_info.values[i] > 0:
						stat_info.values[i] = 0

func onBoonAdded():
	pass

func getDisabled():
	return super()

func getCharges():
	return super()
