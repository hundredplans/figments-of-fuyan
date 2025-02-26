extends StatusEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if !action.post:
		if action is StatAction and action.hasCard(Card):
			for stat_info in action.stat_infos.filter(func(x: StatInfo): return x.Card == Card):
				for i in range(stat_info.types.size()):
					var type: Game.Stats = stat_info.types[i]
					if type == Game.Stats.SPEED:
						stat_info.values[i] = 0
	
func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
	
func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(Card, Game.Stats.SPEED, 0, 0, true, false, true)))
