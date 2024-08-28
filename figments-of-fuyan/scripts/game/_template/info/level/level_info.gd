class_name LevelInfoGD
extends Resource

static var INFO_PATH: String = "res://resources/game/levels/"
@export_group("Automatic")
@export var id: int
@export var name: String
@export var gdscript: GDScript
@export var area_id: int
@export var data: Array
@export_group("")
@export var lights: Array[PackedScene]

#region Setting Values
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(get_script(), id)
		
func setInfo(_name: String = "", _area_id: int = 1, _data: Array[SavedData] = [], _id: int = 0) -> void:
	id = _id
	if id == 0: StaticHelper.onAutoIncrementID(get_script(), id)
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
	
func setPreviousLevelInfoValues(level_info: LevelInfoGD) -> void:
	gdscript = level_info.gdscript
	lights = level_info.lights
	
func getBaseData() -> SavedDataLevel: return SavedDataLevel.new(id)
#endregion
