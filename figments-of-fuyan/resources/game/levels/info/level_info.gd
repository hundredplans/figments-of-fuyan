class_name LevelInfoGD
extends Resource

@export_group("Automatic")
@export var id: int
@export var name: String
@export var area_id: int
@export var data: Array
@export_group("")

# Timeout in seconds
@export var trinket_amount: int = -1
@export var enemy_spawn_amount: int = -1
@export var ally_spawn_amount: int = -1
@export_range(0, 10000, 60) var timeout: int = 1200
@export var lights: Array[LightInfo]

#region Setting Values
func setAutoID() -> void:
	var DIR_PATH: String = "res://resources/game/levels/"
	var tile_object_infos: Array = Helper.getResourcesRecursive(DIR_PATH, LevelInfoGD).map(func(x: LevelInfoGD): return x.id)
	
	tile_object_infos.sort_custom(func(x: int, y: int): return x < y)
	
	id = getNonConsecutive(tile_object_infos)
	if id == -1: id = tile_object_infos.size() + 1
	else: id += 1
	notify_property_list_changed()
		
func setInfo(_name: String = "", _area_id: int = 1, _data: Array[TileObjectDataGD] = [], _id: int = 0) -> void:
	id = _id
	if id == 0: setAutoID()
	name = _name
	area_id = _area_id
	data = _data
	
func getNonConsecutive(arr: Array) -> int:
	var i: int = 1
	for x in arr:
		if i < arr.size() and arr[i] - arr[i-1] != 1:
			return arr[i - 1]
		i += 1
	return -1
func setSpawnPropertiesAutoValues(tile_objects: Array) -> void:
	if ally_spawn_amount == -1: ally_spawn_amount  = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 0)).size()
	if enemy_spawn_amount == -1: enemy_spawn_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 1)).size()
	if trinket_amount == -1: trinket_amount = tile_objects.filter(func(x: TileObjectGD): return x.isIDVariation(2, 3)).size()

func setPreviousLevelInfoValues(level_info: LevelInfoGD) -> void:
	ally_spawn_amount = level_info.ally_spawn_amount
	enemy_spawn_amount = level_info.enemy_spawn_amount
	trinket_amount = level_info.trinket_amount
	timeout = level_info.timeout
	lights = level_info.lights
#endregion
