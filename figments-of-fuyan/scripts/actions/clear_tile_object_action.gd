class_name ClearTileObjectAction extends Action

var TileObject: TileObjectGD
func _init(_TileObject: TileObjectGD = null) -> void:
	super()
	TileObject = _TileObject
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	TileObject.onClear()
