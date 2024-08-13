@tool
class_name TileObjectInfo
extends Resource

@export var id: int
@export var name: String

# Locks the rotation to the 6 base axis
@export var lock_rotation: bool
# Locks to only be placeable on tiles
@export var lock_tile: bool

@export_group("Scripts")
# The base script to generate data
@export var data: GDScript
# The script for the logic
@export var gdscript: GDScript
@export_group("")

@export var models: Array[PackedScene]
@export var points: Array[Array]
@export var solids: Array[bool]

#region SettingID
func _init() -> void:
	if Engine.is_editor_hint():
		var DIR_PATH: String = "res://resources/game/tile_object/info/"
		var tile_object_infos: Array = Array(DirAccess.get_files_at(DIR_PATH)).\
		filter(func(x: String): return x.ends_with(".tres")).\
		map(func(x: String): return load(DIR_PATH + x).id)
		
		tile_object_infos.sort_custom(func(x: int, y: int): return x < y)
		
		id = getNonConsecutive(tile_object_infos)
		if id == -1: id = tile_object_infos.size() + 1
		else: id += 1
		notify_property_list_changed()

func getNonConsecutive(arr: Array) -> int:
	var i: int = 1
	for x in arr:
		if i < arr.size() and arr[i] - arr[i-1] != 1:
			return arr[i - 1]
		i += 1
	return -1
#endregion
#region Data

func createData() -> TileObjectData:
	var resource := Resource.new()
	resource.script = data
	resource.id = id
	return resource
#endregion
#region Models
func getModel(loaded_data: TileObjectData = createData()) -> TileObjectGD:
	var variation: int = loaded_data.variation
	var packed_scene: PackedScene = models[variation]
	var _model: Node3D = packed_scene.instantiate()
	_model.script = gdscript
	_model.setInfo(self, loaded_data)
	return _model
#endregion
