extends FieldEffectGD

const HIVE_BOON_ID: int = 14

func onProcessAction(action: Action) -> void:
	super(action)

func onFieldEffectAdded(_is_init: bool) -> void:
	super(_is_init)
	Card.card_turn_passed.connect(onCardTurnPassed)

func onIncrementAttack() -> void:
	setCharges(charges + 1)

func getDescription() -> String:
	return Helper.getDescription(super(), [getDisplayNumber()])
