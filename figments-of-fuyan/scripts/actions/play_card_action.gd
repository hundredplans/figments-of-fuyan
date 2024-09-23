class_name PlayCardAction extends Action

var Card: CardGD
var Tile: TileGD
func _init(_Card: CardGD, _Tile: TileGD) -> void:
	super()
	Card = _Card
	Tile = _Tile
	
func onPostAction() -> void:
	onPushAction(RemoveCardAction.new(Card))
	onPushAction(EnergyAction.new(-Card.energy))
	onPushAction(AwakenAction.new(Card, Tile))
