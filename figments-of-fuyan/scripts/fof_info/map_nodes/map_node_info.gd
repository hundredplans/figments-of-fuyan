@tool
class_name MapNodeInfo extends FofInfo

#region Exports
@export var model: PackedScene
@export var is_unique_node: bool
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getDataFromID(_id: int) -> GDScript:
	return SavedDataMapNodeStart
