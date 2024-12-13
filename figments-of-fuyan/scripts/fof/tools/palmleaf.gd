extends ToolGD

var turns_remaining: int = 2
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is ChangePhaseAction and Game.isAdvanceTurn(action.phase, Card.team):
			turns_remaining -= 1
			if turns_remaining == 0:
				onPushAction(RemoveToolAction.new(Card))
			
	
func onToolEquipped() -> void:
	if Card.getVisibleFieldCardsEnemies().is_empty():
		var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.MAX_SPEED, 1))
		onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)
	
func onToolUnequipped() -> void:
	super()

func onSave() -> SavedDataTool:
	ability_save["turns_remaining"] = turns_remaining
	return super()

func getDescription() -> String:
	return Helper.getDescriptionNumeric(super(), [turns_remaining], [["Expires in ", "[2]"]])
