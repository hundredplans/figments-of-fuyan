extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidWhenHealed(action): # Has to be max hp
		onPushAction(WhenHealedAction.new(self, action))

func onWhenHealed(_action: StatAction) -> void:
	var max_hp_gain: int = 1 if !ascended else 2
	onPushAction(StatAction.new(StatInfo.new(self, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [max_hp_gain, max_hp_gain])))
