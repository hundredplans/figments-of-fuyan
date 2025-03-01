extends FieldEffectGD

const HIVE_BOON_ID: int = 14
var attack_gained: int

func onProcessAction(action: Action) -> void:
	super(action)

func onFieldEffectAdded() -> void:
	super()
	Card.card_turn_passed.connect(onCardTurnPassed)

func onIncrementAttack() -> void:
	attack_gained += 1

func getDescription() -> String:
	return Helper.getDescription(super(), [attack_gained])
