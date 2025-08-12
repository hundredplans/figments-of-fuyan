class_name MapNodeInfo extends FofInfo

#region Exports
@export var screen: PackedScene
@export var icon: Texture2D
@export var model: PackedScene
@export var is_encounter: bool
@export var is_shop: bool
@export var is_unique: bool
@export var float_y: float
@export var legend_order: int
#endregion

#region Globals
const MAP_NODE_STATIC_BODY: String = "res://scenes/game/map_nodes/map_node_static_body.tscn"
const FIGHT_NODE_HOVER_UI: String = "res://scenes/game/map_nodes/extra/fight_node_hover_ui.tscn"
const EPIC_FIGHT_NODE_HOVER_UI: String = "res://scenes/game/map_nodes/extra/epic_fight_node_hover_ui.tscn"
const SHOP_HOVER_UI: String = "res://scenes/game/map_nodes/extra/shop_hover_ui.tscn"
const MAP_NODE_WALKABLE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/white_outline.tres"
const MAP_NODE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline/material/grey_outline.tres"
const MAP_NODE_LINK_PATH: String = "res://scenes/game/map_nodes/map_node_link.tscn"
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getFofName() -> String: return "MapNode"
