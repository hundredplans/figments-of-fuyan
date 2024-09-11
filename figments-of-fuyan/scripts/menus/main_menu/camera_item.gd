class_name CameraItem extends Resource

@export var name: String
@export var type: TYPES
@export var menu: PackedScene

enum TYPES {NULL, MAIN_MENU, PLAY_TABLE}

func _init(_name: String = "", _type: TYPES = TYPES.NULL) -> void:
	name = _name
	type = _type

static func getCameraItemInArray(arr: Array[CameraItem], camera_item_name: String) -> CameraItem:
	for item in arr:
		if item.name == camera_item_name: return item
	return null
