class_name ClearTileObjectAction extends Action

var TileObject: TileObjectGD
func _init(_TileObject: TileObjectGD = null) -> void:
	super()
	TileObject = _TileObject
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	TileObject.onClear()

	for Card in Game.get_tree().get_nodes_in_group("FieldCardsGD"):
		Card.onRemoveVisibleGameObject(TileObject)
		
	if TileObject is TileGD:
		for Obj in TileObject.occupied_objects:
			Obj.occupied_tiles.erase(TileObject)
			Obj.occupied_coords.erase(TileObject.getCoords())
	
	elif TileObject is ObjectGD:
		for Tile in TileObject.occupied_tiles:
			Tile.occupied_objects.erase(TileObject)
