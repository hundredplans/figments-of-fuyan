class_name TileInfo extends TileObjectInfo

const FALL_DAMAGE_EFFECT_SCENE_PATH: String = "res://scenes/game/tiles/fall_damage_effect.tscn"
const PATH_HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/grey.tres"
const MOVEMENT_RANGE_ATTACKABLE_MATERIAL: String = "res://resources/materials/colors/unshaded/pink.tres"
const MOVEMENT_RANGE_MATERIAL: String = "res://resources/materials/colors/unshaded/light_grey.tres"
const HOVERED_MATERIAL: String = "res://resources/materials/colors/unshaded/white.tres"
const ALLY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/green.tres"
const ENEMY_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/red.tres"
const NEUTRAL_OCCUPY_MATERIAL: String = "res://resources/materials/colors/unshaded/brown.tres"
const ACTIVE_EFFECT_RANGE_MATERIAL: String = "res://resources/materials/colors/unshaded/orange.tres"
const ACTIVE_EFFECT_PICKABLE_MATERIAL: String = "res://resources/materials/colors/unshaded/pink.tres"
const REGULAR_OUTLINE_MATERIAL: String = "res://resources/materials/colors/unshaded/black.tres"
const GREYSCALE_OUTLINE_MATERIAL: String = "res://resources/materials/colors/unshaded/dark_grey.tres"

const LIGHTER_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/lighter_red_tile_intent"
const RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/red_tile_intent"
const GREEN_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/green_tile_intent"
const BLACK_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/black_tile_intent"
const DARK_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/dark_red_tile_intent"
const PURPLE_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/purple_tile_intent"
const LIGHT_RED_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/light_red_tile_intent"
const YELLOW_TILE_INTENT_MODEL_PATH: String = "res://assets/models/general/tile_intents/yellow_tile_intent"
const TILE_MODEL_SCENE_PATH: String = "res://scenes/game/tiles/tile_model.tscn"

const REGULAR_TILE_CYLINDER_MESH_PATH: String = "res://resources/game/tiles/regular_tile_cylinder.tres"
const SHORT_TILE_CYLINDER_MESH_PATH: String = "res://resources/game/tiles/short_tile_cylinder.tres"

const REGULAR_TILE_CONVEX_SHAPE_PATH: String = "res://resources/game/tiles/regular_convex_shape.tres"
const SHORT_TILE_CONVEX_SHAPE_PATH: String = "res://resources/game/tiles/short_convex_shape.tres"

const DECORATION_TOP_CYLINDER: String = "res://resources/game/tiles/decoration_top_cylinder.tres"
const REGULAR_TOP_CYLINDER: String = "res://resources/game/tiles/regular_top_cylinder.tres"

const TILE_FILL_SCENE_PATH: String = "res://scenes/game/tiles/tile_fill.tscn"

@export_group("Regular Materials")
@export var tile_top_material: ShaderMaterial
@export var tile_bottom_material: ShaderMaterial
@export var tile_fill_material: ShaderMaterial
@export_group("")

@export_group("Greyscale Materials")
@export var tile_top_greyscale_material: ShaderMaterial
@export var tile_bottom_greyscale_material: ShaderMaterial
@export var tile_fill_greyscale_material: ShaderMaterial
@export_group("")

@export var is_short: bool

static func getInfoPath() -> String: return "res://resources/fof/tile_objects"
func getModel(parent: Node3D, is_decoration: bool = false) -> Node3D:
	var TileModel: Node3D = load(TILE_MODEL_SCENE_PATH).instantiate()
	parent.add_child(TileModel)
	
	var tier_outline_mesh: MeshInstance3D = TileModel.get_node("TierOutlineMeshInstance3D")
	var outline_mesh: MeshInstance3D = TileModel.get_node("OutlineMeshInstance3D")
	var bottom_mesh: MeshInstance3D = TileModel.get_node("BottomMeshInstance3D")
	var top_mesh: MeshInstance3D = TileModel.get_node("TopMeshInstance3D")
	var collision_shape: CollisionShape3D = TileModel.get_node("StaticBody3D/CollisionShape3D")
	
	outline_mesh.visible = !is_decoration
	bottom_mesh.mesh = load(REGULAR_TILE_CYLINDER_MESH_PATH if !is_short else SHORT_TILE_CYLINDER_MESH_PATH)
	bottom_mesh.position.y = 0.15 if !is_short else 0.1
	top_mesh.mesh = load(REGULAR_TOP_CYLINDER if !is_decoration else DECORATION_TOP_CYLINDER)
	top_mesh.position.y = 0.3002 if !is_short else 0.2002
	tier_outline_mesh.position.y = 0.3001 if !is_short else 0.2001
	outline_mesh.position.y = 0.3 if !is_short else 0.2
	collision_shape.shape = load(REGULAR_TILE_CONVEX_SHAPE_PATH if !is_short else SHORT_TILE_CONVEX_SHAPE_PATH)
	return TileModel
	
func getTileBottomMaterial() -> ShaderMaterial:
	return tile_bottom_material
	
func getTileTopMaterial() -> ShaderMaterial:
	return tile_top_material
	
func getTileFillMaterial() -> ShaderMaterial:
	return tile_fill_material
	
func getTileBottomGreyscaleMaterial() -> ShaderMaterial:
	return tile_bottom_greyscale_material
	
func getTileTopGreyscaleMaterial() -> ShaderMaterial:
	return tile_top_greyscale_material
	
func getTileFillGreyscaleMaterial() -> ShaderMaterial:
	return tile_fill_greyscale_material
	
static func getFofName() -> String: return "Tile"

func getTileIntentModelPath(tile_intent: Game.TileIntents, _variation: int = 0) -> String:
	var path: String = ""
	match tile_intent:
		Game.TileIntents.RED: path = RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.GREEN: path = GREEN_TILE_INTENT_MODEL_PATH
		Game.TileIntents.DARK_RED: path = DARK_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.PURPLE: path = PURPLE_TILE_INTENT_MODEL_PATH
		Game.TileIntents.LIGHT_RED: path = LIGHT_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.LIGHTER_RED: path = LIGHTER_RED_TILE_INTENT_MODEL_PATH
		Game.TileIntents.YELLOW: path = YELLOW_TILE_INTENT_MODEL_PATH
		Game.TileIntents.BLACK: path = BLACK_TILE_INTENT_MODEL_PATH
	
	path += ".glb"
	return path
