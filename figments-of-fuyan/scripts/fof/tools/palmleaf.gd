extends ToolGD

const START_TURN_AMOUNT: int = 2
func onProcessAction(action: Action) -> void:
	super(action)
				
func onCardTurnPassed() -> void:
	super()
	if charges > 0:
		onPushAction(ChangeToolChargesAction.new(self, -1))

func onChangeCharges(delta: int) -> void:
	super(delta)
	if charges == 0:
		onPushAction(RemoveToolAction.new(Card))

func getDefaultCharges() -> int:
	return START_TURN_AMOUNT

func onToolHolderAwakened() -> void:
	super()
	if Card.getVisibleFieldCardsEnemies().is_empty():
		var stat_action := StatAction.new(StatInfo.new(Card, Game.Stats.MAX_SPEED, 1, START_TURN_AMOUNT))
		onPushAction(ToolActivatedAction.new(self, stat_action))
	
func onToolHolderDeath() -> void:
	super()
	
func onToolEquipped() -> void:
	super()
	
func onToolAction(action: StatAction) -> void:
	onPushAction(action)
	
func onToolUnequipped() -> void:
	super()

func getDescription(use_default_values: bool = false) -> String:
	if use_default_values:
		return super(use_default_values)
	return Helper.getDescription(super(), [charges])
