extends FieldEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if Card.isValidRampage(action):
		onPushAction(FieldEffectActivatedAction.new(self, action))
		
func onFieldEffect(_death_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(FofObject, Game.Stats.MAX_HEALTH, 1)))
