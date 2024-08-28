@tool
class_name MapNodeInfoGD extends Resource

#region Exports
@export var id: int
@export var name: String
@export var model: PackedScene
@export var gdscript: Script
@export var is_unique_node: bool
#endregion

#region Globals
static var INFO_PATH: String = "res://resources/game/map_nodes/"
#endregion

func getBaseData() -> SavedDataMapNode:
	match id:
		1: return SavedDataMapNodeStart.new(id)
		2: return SavedDataMapNodeGildred.new(id)
		_: return SavedDataMapNodeStart.new(id)
	return SavedDataMapNode.new(id)
	
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(MapNodeInfoGD, id)
