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
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	Card.onCreateModel()
	Card.onIdle()
	Card.onCreateFieldInfo()
	Card.setTileRotation(Tile.getAllySpawnTile().tile_rotation)
	onPushAction(ChangeTurnStateAction.new(Card, Game.TurnStates.INACTIVE))
	
