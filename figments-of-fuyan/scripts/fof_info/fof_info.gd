@tool
class_name FofInfo extends Resource

@export var id: int
@export var name: String
@export var gdscript: GDScript

func _init() -> void:
	id = StaticHelper.onAutoIncrementID(get_script(), id)

static func getInfoPath() -> String: return "res://resources/fof"
