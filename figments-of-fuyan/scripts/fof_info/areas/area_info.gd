class_name AreaInfo extends FofInfo

@export var world: WorldDatastore
@export var card_background: Image
@export var card_ids: Array[int]
@export var encounter_ids: Array[int]
@export var overworld_decoration: DecorationDatastore
@export var base_environment: Environment
@export var elite_environment: Environment
@export var base_level_script: GDScript
@export var base_tile_info: TileInfo
@export var default_light: PackedScene
@export var boss_music: AudioStreamWAV

@export_group("Boss")
@export var miniboss_ids_to_level: Array[IdToId]
@export var boss_ids_to_level: Array[IdToId]
@export_group("")

static func getInfoPath() -> String: return "res://resources/fof/areas"
static func getFofName() -> String: return "Area"
