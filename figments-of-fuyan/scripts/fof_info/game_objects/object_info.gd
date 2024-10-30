class_name ObjectInfo extends TileObjectInfo
	
@export var tile_coords: Array[Array] = [[Vector4.ZERO]]
@export var lock_rotation: bool
@export var lock_tile: bool
@export var solids: Array[bool]

@export_group("Interactables")
@export var active_effects: Array[ActiveEffectDatastore]
@export_group("")

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
