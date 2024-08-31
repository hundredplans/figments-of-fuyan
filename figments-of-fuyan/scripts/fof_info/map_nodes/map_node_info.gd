@tool
class_name MapNodeInfo extends FofInfo

#region Exports
@export var model: PackedScene
@export var is_unique_node: bool
#endregion

#region Globals
const MAP_NODE_MODEL_PATH: String = "res://scenes/game/map_node/map_node_model.tscn"
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getDataFromID(_id: int) -> GDScript:
	return SavedDataMapNodeStart
