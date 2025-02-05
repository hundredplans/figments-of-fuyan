class_name ObjectInfo extends TileObjectInfo
	
@export var tile_coords: Array[Array] = [[Vector4.ZERO]]
@export var lock_rotation: bool
@export var lock_tile: bool
@export var ignore_collisions: bool
@export var solids: Array[bool]

@export_group("Interactables")
@export var active_effects: Array[ActiveEffectDatastore]
@export_group("")

const SPAWN_PARTICLE_SCENE_PATH: String = "res://scenes/particles/spawn_particle.tscn"
const SMOKE_PARTICLE_SCENE_PATH: String = "res://scenes/particles/smoke_particle.tscn"
const PALM_DOOR_SHORT_CLOSED_MESH_PATH: String = "res://resources/game/custom_collision_shapes/palm_door/palm_door_short_closed.tres"
const PALM_DOOR_SHORT_OPEN_MESH_PATH: String = "res://resources/game/custom_collision_shapes/palm_door/palm_door_short_open.tres"
const PALM_DOOR_TALL_CLOSED_MESH_PATH: String = "res://resources/game/custom_collision_shapes/palm_door/palm_door_tall_closed.tres"
const PALM_DOOR_TALL_OPEN_MESH_PATH: String = "res://resources/game/custom_collision_shapes/palm_door/palm_door_tall_open.tres"
const LOTTERY_COCONUT_DATASTORE_PATH: String = "res://resources/datastore/tile_objects/lottery_coconut_datastore.tres"

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
static func getFofName() -> String: return "Object"
