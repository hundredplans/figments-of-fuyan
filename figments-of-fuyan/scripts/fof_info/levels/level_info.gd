class_name LevelInfo extends FofInfo

@export_group("Automatic")
@export var data: Array
@export var lights: Array[PackedScene]
@export_group("")

@export_group("Manual")
@export var enemy_min_spawn_amount: int
@export var enemy_max_spawn_amount: int
@export var progress_min: int
@export var progress_max: int
@export var enemy_budget_offset: int
@export var difficulty: int
@export_group("")

const PALM_ISLAND_RESOURCES: String = "res://resources/datastore/areas/coconut_springs/palm_island_resources.tres"

func setInfo(_name: String = "") -> void:
	name = _name
	
static func getFofName() -> String: return "Level"
	
static func getInfoPath() -> String: return "res://resources/fof/levels"

func getEnemySpawnsInGroup(group: int) -> Array:
	return data.filter(func(x: SavedDataTileObject): return x is SavedDataSpawn and x.variation != 0 and group in x.groups)
	
func getRandomSpawnGroup() -> int:
	var groups: Dictionary = {}
	var objects: Array = data.filter(func(x: SavedDataTileObject): return x is SavedDataObject)
	
	for object_data: SavedDataObject in objects:
		for group: int in object_data.groups:
			groups[group] = null
			
	if groups.is_empty(): return randi() % 10
	return groups.keys().pick_random()
