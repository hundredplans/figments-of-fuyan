class_name ObjectInfoGD
extends TileObjectInfoGD
	
@export var tile_coords: Array[Array] = [[Vector4.ZERO]]
@export var lock_rotation: bool
@export var lock_tile: bool
@export var solids: Array[bool]

func getBaseData() -> SavedDataObject: return SavedDataObject.new(id)
