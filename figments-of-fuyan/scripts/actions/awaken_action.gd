class_name AwakenAction extends Action

var Card: CardGD
var Tile: TileGD
var tile_rotation: int

func _init(_Card: CardGD = null, _Tile: TileGD = null) -> void:
	super()
	Card = _Card
	Tile = _Tile

func onPreAction() -> void:
	onForceAction(OccupyAction.new(Card, Tile))

func onPostAction() -> void:
	var SpawnObject: SpawnGD = Tile.getSpawnTile()
	if SpawnObject != null: Card.tile_rotation = SpawnObject.tile_rotation
	
	Card.onChangeCardPlace(Game.CardPlaces.FIELD)
	Card.onAwaken()
	Card.onCreateInitialTraits()
	Card.onCreateInitialActiveAbilities()
	
	if Card.Tool != null:
		onPushAction(AddToolAction.new(Card, Card.Tool))

func getLogInfo() -> Array:
	return ["Card: " + Card.info.name]
