class_name OccupyAction extends Action

var Card: CardGD
var PreviousTile: TileGD
var Tile: TileGD
# For movement set to false
var apply_occupy_instant: bool

func _init(_Card: CardGD = null, _Tile: TileGD = null, _apply_occupy_instant: bool = true) -> void:
	super()
	Card = _Card
	Tile = _Tile
	apply_occupy_instant = _apply_occupy_instant

func onPreAction() -> void:
	PreviousTile = Card.Tile

func onPostAction() -> void:
	var coords: Vector4i # Last coords of Tile if null otherwise new coords
	if Card.Tile != null:
		Card.Tile.onOccupy(null, true)
		coords = Card.Tile.getCoords()
	
	Card.Tile = Tile
	
	if Tile != null:
		Card.coords = Tile.getCoords()
		coords = Card.coords
		
		for _Tile in Game.getAdjacentOrCloserTiles(Tile, Card.max_speed - 1).filter(func(x: TileGD): return !x.explored.getExploredByTeam(Card.team)):
			_Tile.explored.addExploredTeam(Card.team)
			
		Tile.onOccupy(Card, apply_occupy_instant)
		Card.setPositionToTile()

	var vision_cards: Dictionary = {}
	for OtherCard in Game.inVisionRangeCardsCoords(coords, true):
		vision_cards[OtherCard] = null
	
	for OtherCard in Game.get_tree().get_nodes_in_group("FieldCardsGD").filter(func(x: CardGD): return Card in x.getVisibleFieldCards()):
		vision_cards[OtherCard] = null
	
	for VisionCard in vision_cards:
		VisionCard.onTileOccupiedIsInVision(Tile, PreviousTile, Card)
		
	onPushAction(VisionAction.new(vision_cards.keys(), Card))

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "TileExists: " + str(Tile != null)]
