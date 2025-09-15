class_name MapNodeInfo extends FofInfo

#region Exports
@export var screen: PackedScene
@export var icon: Texture2D
@export var model: PackedScene
@export var is_encounter: bool
@export var is_shop: bool
@export var is_unique: bool
@export var float_y: float
#endregion

#region Globals
const MAP_NODE_STATIC_BODY: String = "res://scenes/game/map_nodes/map_node_static_body.tscn"
const FIGHT_NODE_HOVER_UI: String = "res://scenes/game/map_nodes/extra/fight_node_hover_ui.tscn"
const EPIC_FIGHT_NODE_HOVER_UI: String = "res://scenes/game/map_nodes/extra/epic_fight_node_hover_ui.tscn"
const ENCOUNTER_HOVER_UI: String = "res://scenes/game/map_nodes/extra/encounter_hover_ui.tscn"
const MAP_NODE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline_3/material/light_grey_outline.tres"
const MAP_NODE_LINK_PATH: String = "res://scenes/game/map_nodes/map_node_link.tscn"

const MAP_NODE_WALKABLE_OUTLINE_PATH: String = "res://resources/materials/game/base_material_outline_3/material/white_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_BOSS: String = "res://resources/materials/game/base_material_outline_3/material/boss_color_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_MINIBOSS: String = "res://resources/materials/game/base_material_outline_3/material/miniboss_color_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_ENCOUNTER: String = "res://resources/materials/game/base_material_outline_3/material/encounter_color_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_SHOP: String = "res://resources/materials/game/base_material_outline_3/material/shop_color_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_FIGHT: String = "res://resources/materials/game/base_material_outline_3/material/fight_color_outline.tres"
const MAP_NODE_WALKABLE_OUTLINE_PATH_ELITE_FIGHT: String = "res://resources/materials/game/base_material_outline_3/material/elite_fight_color_outline.tres"
#endregion

static func getInfoPath() -> String: return "res://resources/fof/map_nodes"
static func getFofName() -> String: return "MapNode"

func getMapNodeWalkableOutlinePath() -> String:
	if is_shop: return MAP_NODE_WALKABLE_OUTLINE_PATH_SHOP
	elif is_encounter: return MAP_NODE_WALKABLE_OUTLINE_PATH_ENCOUNTER
	elif id == 3: return MAP_NODE_WALKABLE_OUTLINE_PATH_FIGHT
	elif id == 4: return MAP_NODE_WALKABLE_OUTLINE_PATH_ELITE_FIGHT
	elif id == 7: return MAP_NODE_WALKABLE_OUTLINE_PATH_MINIBOSS
	elif id == 8: return MAP_NODE_WALKABLE_OUTLINE_PATH_BOSS
	return MAP_NODE_WALKABLE_OUTLINE_PATH
