class_name MapNodeInfo extends FofInfo

#region Exports
@export var load_level: bool
@export var screen: PackedScene
@export var icon: Texture2D
@export var model: PackedScene
@export var is_unique_node: bool
@export var float_y: float 
@export var legend_order: int
#endregion

#region Globals
const MAP_NODE_STATIC_BODY: String = "res://scenes/game/map_nodes/map_node_static_body.tscn"
const FIGHT_NODE_HOVER_UI: String = "res://scenes/game/map_nodes/extra/fight_node_hover_ui.tscn"
const GILDRED_NODE_RESOURCES: String = "res://scenes/game/map_effects/gildred_node_resources/gildred_node_resources.tscn"
const ALPHAGREY_MATERIAL: String = "res://resources/materials/game/base_material_alphagrey.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/white_outline.tres"
const MAP_NODE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/grey_outline.tres"
const MAP_NODE_LINK_PATH: String = "res://scenes/game/map_nodes/map_node_link.tscn"
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getDataFromID(_id: int) -> GDScript:
	match _id:
		2: return SavedDataMapNodeGildred
		3: return SavedDataMapNodeFight
		4: return SavedDataMapNodeEliteFight
		5: return SavedDataMapNodeChiefFight
		6: return SavedDataMapNodeEliteChiefFight
		9: return SavedDataMapNodeMiniBossFight
		10: return SavedDataMapNodeBossFight
		_: return SavedDataMapNode
