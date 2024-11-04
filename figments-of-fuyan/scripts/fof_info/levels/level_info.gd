class_name LevelInfo extends FofInfo
@export_group("Automatic")
@export var area_id: int
@export var data: Array
@export var lights: Array[PackedScene]
@export_group("")

@export_group("Manual")
@export var trinket_amount: int 
@export var enemy_min_spawn_amount: int
@export var enemy_max_spawn_amount: int
@export var ally_spawn_amount: int
@export var progress_min: int
@export var progress_max: int
@export_range(0, 10000, 60) var timeout: int = 1200
@export_group("")

const PALM_ISLAND_RESOURCES: String = "res://resources/datastore/areas/coconut_springs/palm_island_resources.tres"

func setInfo(_name: String = "", _area_id: int = 1) -> void:
	name = _name
	area_id = _area_id
	
static func getFofName() -> String: return "Level"
	
static func getInfoPath() -> String: return "res://resources/fof/levels"

static func getDataFromType(type: GDScript) -> GDScript:
	match type:
		PalmLevelInfo: return SavedDataPalmLevel
		_: return SavedDataLevel

func setSpawnPropertiesAutoValues(tile_objects: Array) -> void:
	ally_spawn_amount  = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 0)).size()
	enemy_min_spawn_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 1)).size()
	enemy_max_spawn_amount = enemy_max_spawn_amount
	trinket_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 3)).size()
