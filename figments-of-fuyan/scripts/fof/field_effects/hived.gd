extends FieldEffectGD

const HIVE_BOON_ID: int = 14
var one_turn_amount: int
var two_turn_amount: int

func onProcessAction(action: Action) -> void:
	super(action)

func onFieldEffectAdded() -> void:
	Card.card_turn_passed.connect(onCardTurnPassed)

func onCardTurnPassed() -> void:
	one_turn_amount = two_turn_amount
	two_turn_amount = 0
	
	if one_turn_amount == 0 and two_turn_amount == 0:
		onRemoveFromCard()

func onSave() -> SavedData:
	ability_save['one_turn_amount'] = one_turn_amount
	ability_save['two_turn_amount'] = two_turn_amount
	return super()

func onIncrementTwoTurnAmount() -> void:
	two_turn_amount += 1

func getDescription() -> String:
	if two_turn_amount > 0 and one_turn_amount > 0:
		return Helper.getDescription(super(), [two_turn_amount, one_turn_amount])
	
	if two_turn_amount > 0:
		return Helper.getDescription("Has [X] ATT for [2] Turns", [two_turn_amount])
		
	if one_turn_amount > 0:
		return Helper.getDescription("Has [X] ATT for [1] Turn", [one_turn_amount])
		
	return Helper.getDescription(super(), [two_turn_amount, one_turn_amount])
