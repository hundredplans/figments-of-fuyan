class_name OccupyAction extends Action

var Card: CardGD
var Tile: TileGD
# For movement set to false
var apply_occupy_instant: bool

func _init(_Card: CardGD = null, _Tile: TileGD = null, _apply_occupy_instant: bool = true) -> void:
	super()
	Card = _Card
	Tile = _Tile
	apply_occupy_instant = _apply_occupy_instant

func onPostAction() -> void:
	var coords: Vector4i # Last coords of Tile if null otherwise new coords
	if Card.Tile != null:
		Card.Tile.onOccupy(null, true)
		coords = Card.Tile.getCoords()
	
	Card.Tile = Tile
	
	if Tile != null:
		Card.coords = Tile.getCoords()
		coords = Card.coords
		
		Tile.onOccupy(Card, apply_occupy_instant)
		Card.setPositionToTile()

	var vision_cards: Array = Game.inVisionCards(coords)
	if Tile != null: vision_cards.append(Card)
	onPushAction(VisionAction.new(vision_cards))

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name, "TileExists: " + str(Tile != null)]
