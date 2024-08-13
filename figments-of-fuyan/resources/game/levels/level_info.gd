@tool
class_name LevelInfo
extends Resource

@export var id: int
@export var name: String
@export var area_id: int
@export var data: Array[TileObjectData]

# Timeout in seconds
@export_range(0, 10000, 60) var timeout: int = 1200

#region SettingID
func setAutoID() -> void:
	var DIR_PATH: String = "res://resources/game/levels/"
	var tile_object_infos: Array = Array(DirAccess.get_files_at(DIR_PATH)).\
	filter(func(x: String): return x.ends_with(".tres")).\
	map(func(x: String): return load(DIR_PATH + x).id)
	
	tile_object_infos.sort_custom(func(x: int, y: int): return x < y)
	
	id = getNonConsecutive(tile_object_infos)
	if id == -1: id = tile_object_infos.size() + 1
	else: id += 1
	notify_property_list_changed()
		
func setInfo(_name: String = "", _area_id: int = 1, _data: Array[TileObjectData] = [], _id: int = 0) -> void:
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
#endregion
