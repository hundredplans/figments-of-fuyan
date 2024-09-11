class_name ObjectInfo extends TileObjectInfo
	
@export var tile_coords: Array[Array] = [[Vector4.ZERO]]
@export var lock_rotation: bool
@export var lock_tile: bool
@export var solids: Array[bool]

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
