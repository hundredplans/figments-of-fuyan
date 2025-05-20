extends FieldEffectGD

const HIVE_BOON_ID: int = 14

func onProcessAction(action: Action) -> void:
	super(action)

func onFieldEffectAdded() -> void:
	super()
	Card.card_turn_passed.connect(onCardTurnPassed)

func onIncrementAttack() -> void:
	setCharges(charges + 1)

func getDescription() -> String:
	return Helper.getDescription(super(), [getDisplayNumber()])
