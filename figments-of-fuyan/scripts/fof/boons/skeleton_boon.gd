extends BoonGD

func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and charges > 0:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: DeathAction) -> void:
	onPushAction(ChangeBoonChargesAction.new(self, -1))
	var Card: CardGD = action.Defender
	
	var NewCard: CardGD = Game.getNewFieldCard(29, action.Tile, 0, Card.tile_rotation, ascended, true)
	onPushAction(AwakenAction.new(NewCard, action.Tile))

func onBoonAdded() -> void:
	super()
	onResetCharges()
	
func getDefaultCharges() -> int:
	return 1
	
func getDisabled() -> bool:
	return charges == 0
