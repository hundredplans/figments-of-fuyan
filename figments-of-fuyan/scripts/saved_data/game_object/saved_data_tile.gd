class_name SavedDataTile extends SavedDataGameObject

@export var tile_fill: bool

func _init(_id: int = 0, _variation: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _tile_fill: bool = false) -> void:
	super(_id, _variation, _coords, _tile_rotation)
	tile_fill = _tile_fill

func getInfoType() -> GDScript: return TileInfo
