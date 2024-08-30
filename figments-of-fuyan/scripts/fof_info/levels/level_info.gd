@tool
class_name LevelInfo extends FofInfo
@export var area_id: int
@export var data: Array
@export var lights: Array[PackedScene]

func setInfo(_name: String = "", _area_id: int = 1) -> void:
	name = _name
	area_id = _area_id
	id = StaticHelper.onAutoIncrementID(LevelInfo, id)
	
static func getInfoPath() -> String: return "res://resources/fof/levels"
