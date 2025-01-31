extends StatusEffectGD
	
func onProcessAction(action: Action) -> void:
	super(action)
	if !is_queued_for_deletion():
		if !action.post:
			if action is ChangeTurnStateAction and action.Card == Card and action.turn_state == Game.TurnStates.INACTIVE:
				action.turn_state = Game.TurnStates.PASSED
				action.onCheckFail()
				turns -= 1
				if turns == 0:
					onPushAction(RemoveStatusEffectAction.new(self))
		if action.post:
			if action is AddStatusEffectAction and action.StatusEffect == self:
				onPushAction(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED))

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
