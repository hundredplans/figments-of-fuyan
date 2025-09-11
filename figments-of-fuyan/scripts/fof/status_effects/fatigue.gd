class_name FatigueGD extends StatusEffectGD
	
func onProcessAction(action: Action) -> void:
	super(action)
	if !is_queued_for_deletion():
		if !action.post:
			if action is ChangeTurnStateAction and action.Card == Card and action.turn_state == Game.TurnStates.INACTIVE:
				if action.is_start_of_phase:
					turns -= 1
					if turns == 0:
						onPushAction(RemoveStatusEffectAction.new(self))
						return
				action.onFailAction()
				
				
		if action.post:
			if action is AddStatusEffectAction and action.StatusEffect == self:
				onPushAction(ChangeTurnStateAction.new(Card, Game.TurnStates.PASSED, false, true))
