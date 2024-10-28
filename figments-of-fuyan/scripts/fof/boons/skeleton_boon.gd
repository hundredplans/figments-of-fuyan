extends BoonGD

var skeleton_charges: int
func onProcessAction(action: Action) -> void:
	super(action)
	if action.post:
		if action is DeathAction and action.Defender.isAlly(0) and skeleton_charges > 0:
			onPushAction(BoonActivatedAction.new(self, action))
	
func onAscenscionChanged() -> void:
	super()

func getDescription() -> String:
	return super()

func onBoon(action: Action = null) -> void:
	skeleton_charges -= 1
	var Card: CardGD = action.Defender
	var Tile: TileGD = Card.Tile
	
	var NewCardData: SavedDataCard = Game.getBaseCard(12, Tile, 2, Card.tile_rotation, ascended)
	var NewCard: CardGD = SavedData.onLoadModel(NewCardData, Card)
	
	onPushAction(AwakenAction.new(NewCard, Tile))

func onBoonAdded() -> void:
	skeleton_charges = 1

func getDisabled() -> bool:
	return skeleton_charges == 0

func getCharges() -> int:
	return skeleton_charges
	
func onSave() -> SavedDataBoon:
	ability_save['skeleton_charges'] = skeleton_charges
	return super()
