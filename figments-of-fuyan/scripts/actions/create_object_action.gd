class_name CreateObjectAction extends Action

var id: int
var Tile: TileGD

func _init(_id: int = 0, _Tile: TileGD = null) -> void:
	super()
	id = _id
	Tile = _Tile
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var level: LevelGD = Game.get_tree().get_nodes_in_group("LevelsGD")[0]
	var data: SavedDataObject = Helper.getFofInfoID(TileObjectInfo, id).saved_data.new(id, true)
	data.coords = Tile.getCoords()
	
	var TileObject: TileObjectGD = level.onLoadTileObjectInit(data)
	TileObject.setPosition(TileObject.coords, TileObject.onCoordsToPosition())
	TileObject.onLoadDataLevel()
	
	for Card in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.onAddVisibleGameObject(TileObject)
	
	level.setOccupiedTiles(TileObject)
	onPushAction(VisionAction.new(Game.inVisionRangeCards(Tile, true)))
	
