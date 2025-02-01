class_name PlayCardAction extends Action

var Card: CardGD
var Tile: TileGD

func _init(_Card: CardGD, _Tile: TileGD) -> void:
	super()
	Card = _Card
	Tile = _Tile
	
func onPostAction() -> void:
	var actions: Array = [RemoveCardAction.new(Card), EnergyAction.new(-Card.energy), AwakenAction.new(Card, Tile)]
	onPushAction(actions)
