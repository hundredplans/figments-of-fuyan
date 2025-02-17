class_name LevelInfo extends FofInfo
@export_group("Automatic")
@export var area_id: int
@export var data: Array
@export var lights: Array[PackedScene]
@export_group("")

@export_group("Manual")
@export var enemy_min_spawn_amount: int
@export var enemy_max_spawn_amount: int
@export var progress_min: int
@export var progress_max: int
@export var enemy_budget_offset: int
@export_group("")

const PALM_ISLAND_RESOURCES: String = "res://resources/datastore/areas/coconut_springs/palm_island_resources.tres"

func setInfo(_name: String = "", _area_id: int = 1) -> void:
	name = _name
	area_id = _area_id
	
static func getFofName() -> String: return "Level"
	
static func getInfoPath() -> String: return "res://resources/fof/levels"

func getSpawnsInGroup(group: String) -> Array:
	return data.filter(func(x: SavedDataTileObject): return x is SavedDataSpawn and x.spawn_id == 0 and group in x.groups)

func getEnemySpawnsInGroup(group: String) -> Array:
	return getSpawnsInGroup(group).filter(func(x: SavedDataSpawn): return x.variation != 0)
	
func getRandomSpawnGroup() -> String:
	var groups: Dictionary = {}
	var spawns: Array = data.filter(func(x: SavedDataTileObject): return x is SavedDataSpawn and x.spawn_id == 0)
	
	for spawn_data: SavedDataSpawn in spawns:
		for group: String in spawn_data.groups:
			groups[group] = null
	return groups.keys().pick_random()
