extends BoonGD

var skeleton_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and skeleton_charges > 0:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscend(state: bool) -> void:
	super(state)

func getDescription() -> String:
	return super()

func onBoon(action: DeathAction) -> void:
	skeleton_charges -= 1
	var Card: CardGD = action.Defender
	
	var NewCard: CardGD = Game.getNewFieldCard(29, action.Tile, 0, Card.tile_rotation, ascended, true)
	onPushAction(AwakenAction.new(NewCard, action.Tile))

func onBoonAdded() -> void:
	super()
	onResetCharges()
	
func onLevelStarted() -> void:
	super()
	onResetCharges()
	
func getDisabled() -> bool:
	return skeleton_charges == 0

func getCharges() -> int:
	return skeleton_charges
	
func onResetCharges() -> void:
	skeleton_charges = 1
	
func onSave() -> SavedDataBoon:
	ability_save['skeleton_charges'] = skeleton_charges
	return super()
