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
	if Card.Tile != null: Card.Tile.onOccupy(null, true)
	
	Card.Tile = Tile
	Card.coords = Tile.getCoords()
	Tile.onOccupy(Card, apply_occupy_instant)
	Card.setPositionToTile()
