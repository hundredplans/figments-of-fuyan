extends BoonGD

const MAX_LIMITED_ABILITY_PLACED: int = 4

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is AwakenAction and action.Card.isAlly(0) and isCardLimitedAbility(action.Card):
			onPushAction(BoonActivatedAction.new(self, action))
			
		if charges >= MAX_LIMITED_ABILITY_PLACED:
			if action is FinishAwakenAction:
				onPushAction(BoonActivatedAction.new(self, action))

func onBoon(action: Action = null) -> void:
	if action is AwakenAction: onPushAction(ChangeBoonChargesAction.new(self, 1))
	elif action is FinishAwakenAction:
		onResetCharges()
		onPushAction(ChangeActiveEffectChargesAction.new(action.Card, 1))

func onBoonAdded() -> void:
	super()

func getDisabled() -> bool:
	return super()

func isCardLimitedAbility(Card: CardGD) -> bool:
	return !Card.getCardTierDatastore(tier).getActiveAbilities().is_empty()
		
