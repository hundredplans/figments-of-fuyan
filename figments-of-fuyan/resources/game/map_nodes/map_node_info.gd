@tool
class_name MapNodeInfoGD extends Resource

#region Exports
@export var id: int
@export var name: String
@export var icon: Image
@export var gdscript: Script
@export var is_unique_node: bool
#endregion

#region Globals
static var INFO_PATH: String = "res://resources/game/map_nodes/info/"
#endregion

func getBaseData() -> SavedDataMapNode: return Helper.getResourcesRecursiveID(MapNodeInfoGD, id)
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(MapNodeInfoGD, id)
