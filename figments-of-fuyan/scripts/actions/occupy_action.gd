class_name OccupyAction extends Action

var Card: CardGD
var PreviousTile: TileGD
var Tile: TileGD
# For movement set to false
var apply_occupy_instant: bool
var force_occupy: bool # Removes any awakens trying for the tile

func _init(_Card: CardGD = null, _Tile: TileGD = null, _apply_occupy_instant: bool = true, _force_occupy: bool = false) -> void:
	super()
	Card = _Card
	Tile = _Tile
	apply_occupy_instant = _apply_occupy_instant
	force_occupy = _force_occupy

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
		
	var vision_cards_keys: Array = vision_cards.keys()
	#.filter(func(x: CardGD): return x == Card or x.isLevelVisible())
	onPushAction(VisionAction.new(vision_cards_keys, Card))

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "TileExists: " + str(Tile != null)]
