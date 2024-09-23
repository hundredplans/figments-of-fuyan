class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	force_action.emit(OccupyAction.new(Card, Tile))

func onPostAction() -> void:
	Card.onChangeCardPlace(CardGD.CARD_PLACES.FIELD)
	Card.onCreateModel()
	Card.onIdle()
	Card.setTileRotation(Card.tile_rotation)
