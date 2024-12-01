class_name AreaInfo extends FofInfo

@export var world: WorldDatastore
@export var card_background: Image
@export var card_ids: Array[int]
@export var encounter_ids: Array[int]
@export var overworld_decoration: DecorationDatastore
@export var base_environment: Environment
@export var late_environment: Environment
@export var level_script: GDScript

static func getInfoPath() -> String: return "res://resources/fof/areas"
static func getFofName() -> String: return "Area"
