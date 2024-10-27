extends ToolGD

func onProcessAction(action: Action) -> void:
	super(action)
	if Card != null and Card.isValidLastWill(action):
		var Tile: TileGD = action.Tile
		var NewCardData: SavedDataCard = Game.getBaseCard(11, Tile, 2, Card.tile_rotation)
		var FieldCard: CardGD = SavedData.onLoadModel(NewCardData, Card)
		onPushAction(AwakenAction.new(FieldCard, Tile))
	
func onToolEquipped() -> void:
	pass
	
func onToolUnequipped() -> void:
	super()
