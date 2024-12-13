class_name SavedDataTile extends SavedDataTileObject

@export var tile_fill: bool
@export var occupy_state: TileGD.OccupyStates
@export var explored: ExploredGD

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO,\
 	_tile_rotation: int = 0, _vision_datastore := VisionDatastore.new(), _variation: int = 0, _tile_fill: bool = false,\
	_occupy_state := TileGD.OccupyStates.NULL, _explored: ExploredGD = null) -> void:
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _vision_datastore, _variation)
	tile_fill = _tile_fill
	occupy_state = _occupy_state
	explored = _explored

func getInfoType() -> GDScript: return TileInfo
