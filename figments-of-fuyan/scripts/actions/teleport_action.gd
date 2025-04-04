class_name TeleportAction extends Action

var Card: CardGD
var Tile: TileGD
func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var actions: Array = []
	if Tile.isOccupied():
		actions.append(DestroyAction.new(Game.getFieldCard(Tile), Card))
	
	actions.append(OccupyAction.new(Card, Tile, true, true))
	Card.setPositionToTile(Tile)
	
	onPushAction(actions)
