extends ToolGD

const SPEED_AMOUNT: int = 1
const TIER_ONE_TURN_AMOUNT: int = 1
const TIER_TWO_TURN_AMOUNT: int = 2
const TIER_THREE_TURN_AMOUNT: int = 3
const TIER_FOUR_TURN_AMOUNT: int = 4
var remaining_turn_amount: int

func onSave() -> SavedDataTool:
	ability_save['remaining_turn_amount'] = remaining_turn_amount
	return super()

func onProcessAction(action: Action) -> void:
	super(action)
	if Card != null and Card.isValidEndOfTurn(action) and remaining_turn_amount > 0:
		remaining_turn_amount -= 1
		if remaining_turn_amount == 0:
			onPushAction(RemoveToolAction.new(Card))
				
func onCardTurnPassed() -> void:
	super()

func onToolHolderAwakened() -> void:
	super()
	remaining_turn_amount = getSpeedTurnAmount()
	var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.MAX_SPEED, SPEED_AMOUNT, remaining_turn_amount))
	onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return super()

func getSpeedTurnAmount() -> int:
	match tier:
		1: return TIER_ONE_TURN_AMOUNT
		2: return TIER_TWO_TURN_AMOUNT
		3: return TIER_THREE_TURN_AMOUNT
		4: return TIER_FOUR_TURN_AMOUNT
	return 0
