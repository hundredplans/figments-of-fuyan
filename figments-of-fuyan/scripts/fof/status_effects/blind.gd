extends StatusEffectGD

const BLIND_DELAY: float = 0.5
func onStatusEffectAdded(_action: AddStatusEffectAction) -> void:
	var vision_action := VisionAction.new(Card)
	vision_action.setActionDelay(BLIND_DELAY)
	onPushAction(vision_action)

func onProcessAction(action: Action) -> void:
	super(action)
	
func onClear() -> void:
	super()
	onPushAction(VisionAction.new(Card))
	
	# Exists for tile intents, otherwise they dont update
	if Card.getTile() == null: return
	for Tile: TileGD in (Game.getAdjacentTiles(Card.getTile()) + [Card.getTile()]).filter(func(x: TileGD): return x != null): 
		Tile.onUpdateLevelVisible()

func getDescription() -> String:
	return Helper.getDescription(super(), [turns])
