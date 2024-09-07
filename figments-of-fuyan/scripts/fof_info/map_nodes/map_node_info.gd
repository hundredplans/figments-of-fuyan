@tool
class_name MapNodeInfo extends FofInfo

#region Exports
@export var screen: PackedScene
@export var model: PackedScene
@export var is_unique_node: bool
#endregion

#region Globals
const GILDRED_NODE_RESOURCES: String = "res://scenes/game/map_effects/gildred_node_resources/gildred_node_resources.tscn"
const ALPHAGREY_MATERIAL: String = "res://resources/materials/game/base_material_alphagrey.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/white_outline.tres"
const MAP_NODE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/grey_outline.tres"
const MAP_NODE_LINK_PATH: String = "res://scenes/game/map_nodes/map_node_link.tscn"
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getDataFromID(id: int) -> GDScript:
	match id:
		2: return SavedDataMapNodeGildred
		_: return SavedDataMapNode
