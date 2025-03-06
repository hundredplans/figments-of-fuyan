class_name TileIntentDatastore extends Resource

func _init(_intent_type := Game.TileIntents.NULL, _offset_datastore: OffsetDatastore = null, _coords := Vector4i.ZERO) -> void:
	intent_type = _intent_type
	offset_datastore = _offset_datastore
	coords = _coords
	
@export var coords: Vector4i
@export var offset_datastore: OffsetDatastore # Relative to card
@export var intent_type: Game.TileIntents

func getTile() -> TileGD:
	if isStaticTile(): return Game.getTile(coords)
	return offset_datastore.getTile(coords)

func isStaticTile() -> bool:
	return offset_datastore == null

func setTileRotation(tile_rotation: int) -> void:
	offset_datastore.setTileRotation(tile_rotation)
