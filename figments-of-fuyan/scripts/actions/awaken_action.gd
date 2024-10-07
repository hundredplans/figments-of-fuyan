class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD
var tile_rotation: int

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	force_action.emit(OccupyAction.new(Card, Tile))

func onPostAction() -> void:
	var SpawnObject: SpawnGD = Tile.getSpawnTile()
	if SpawnObject != null: Card.tile_rotation = SpawnObject.tile_rotation
	
	Card.onCreateInitialTraits()
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	Card.onAwaken()
	onPushAction(ChangeTurnStateAction.new(Card, Game.TurnStates.INACTIVE))
	
