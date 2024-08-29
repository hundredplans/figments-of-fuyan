@tool
class_name LevelInfo extends FofInfo
@export var area_id: int
@export var data: Array
@export var lights: Array[PackedScene]

func setInfo(_name: String = "", _area_id: int = 1, _data: Array[SavedData] = [], _id: int = 0) -> void:
	if _id == 0: StaticHelper.onAutoIncrementID(get_script(), id)
	else: id = _id
	
	name = _name
	area_id = _area_id
	data = _data
	
func setPreviousLevelInfoValues(level_info: LevelInfo) -> void:
	gdscript = level_info.gdscript
	lights = level_info.lights
	
static func getInfoPath() -> String: return "res://resources/fof/levels/"
