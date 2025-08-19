extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if charges > 0 and action is AwakenAction and action.owner is PlayCardAction and action.owner.Card.info.rarity == Game.Rarities.CHAMPION:
			onPushAction(BoonActivatedAction.new(self, action))

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])

func onBoon(action: Action = null) -> void:
	action.Card.onCreateBaseStatusEffect(1, -1)
	onPushAction(ChangeBoonChargesAction.new(self, -1))

func onBoonAdded() -> void:
	super()
	
func onLevelStarted() -> void:
	super()

func getDisabled() -> bool:
	return super() or charges == 0

func getCharges() -> int:
	return super()
	
func getDefaultCharges() -> int:
	return 3
	
func onCardTurnPassed(Card: CardGD) -> void:
	super(Card)
