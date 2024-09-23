class_name SavedDataTile extends SavedDataTileObject

@export var tile_fill: bool
@export var occupy_state: TileGD.OccupyStates

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 	_tile_rotation: int = 0, _level_visible: bool = true, _variation: int = 0, _tile_fill: bool = false,\
	_occupy_state := TileGD.OccupyStates.NULL) -> void:
	super(_id, _first_init, _coords, _tile_rotation, _level_visible, variation)
	tile_fill = _tile_fill
	occupy_state = _occupy_state

func getInfoType() -> GDScript: return TileInfo
