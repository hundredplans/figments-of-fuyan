extends FieldEffectGD

func onProcessAction(action: Action) -> void:
	super(action)
	if Card != null and Card.isValidRampage(action): # It's null before it's added
		onPushAction(FieldEffectActivatedAction.new(self, action))
		
func onFieldEffect(_death_action: DeathAction) -> void:
	onPushAction(StatAction.new(StatInfo.new(Card, [Game.Stats.MAX_HEALTH, Game.Stats.HEALTH], [1, 1])))
