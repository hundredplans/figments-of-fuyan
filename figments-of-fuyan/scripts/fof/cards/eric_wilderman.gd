extends CardGD

func onProcessAction(action: Action) -> void:
	super(action)
	if isValidArrive(action):
		onPushAction(ArriveAction.new(self, action))
	elif action.post and action is RemoveFieldEffectAction\
	and action.FieldEffect.info.id == SHIELD_ID and action.FieldEffect.Card == self:
		onShieldLost()

func onArrivePre(_action: AwakenAction) -> void:
	pass

func onArrive(_action: AwakenAction) -> void:
	onAbility()
	onGainShield()
	
func onShieldLost() -> void:
	onAbility()
	onPushAction(StatAction.new(StatInfo.new(self, Game.Stats.ATTACK, 1)))
