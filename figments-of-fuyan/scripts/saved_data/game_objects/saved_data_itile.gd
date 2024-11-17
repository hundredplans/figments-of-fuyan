class_name SavedDataITile extends SavedDataTile

@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO,\
 	_tile_rotation: int = 0, _vision_datastore := VisionDatastore.new(), _variation: int = 0, _tile_fill: bool = false,\
	_occupy_state := TileGD.OccupyStates.NULL, _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _vision_datastore, _variation, _tile_fill, _occupy_state)
	ability_save = _ability_save
	
func getInfoType() -> GDScript: return TileInfo
