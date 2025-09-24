class_name AreaInfo extends FofInfo

@export var champion_id: int
@export var card_background: Image
@export var champion_entrance_packed: PackedScene
@export var card_ids: Array[int]
@export var overworld_decoration: DecorationDatastore
@export var base_environment: Environment
@export var base_level_script: GDScript
@export var base_tile_info: TileInfo
@export var default_light: PackedScene
@export var boss_music: AudioStream
@export var epic_datastores: Array[EpicAreaDatastore]
@export var main_menu_decoration: DecorationDatastore

@export_group("Area Colors")
@export var area_color: Color
@export var secondary_area_color: Color
@export var tertiary_area_color: Color
@export_group("")

@export_group("Tile Fill")
@export var tile_fill_material: ShaderMaterial
@export var tile_fill_greyscale_material: ShaderMaterial
@export_group("")

@export var background_scene: PackedScene
@export var loading_screens: Array[LoadingScreenDatastore]
@export var area_icon: Texture2D

static func getInfoPath() -> String: return "res://resources/fof/areas"
static func getFofName() -> String: return "Area"

func getBaseEnvironment() -> Environment: return base_environment
func getChampionID() -> int: return champion_id
func getAreaColor() -> Color: return area_color
func getSecondAreaColor() -> Color: return secondary_area_color
func getThirdAreaColor() -> Color: return tertiary_area_color
func getBackgroundScene() -> Node3D: return background_scene.instantiate()
func getAreaIcon() -> Texture2D: return area_icon

func getRandomLoadingScreenDatastore() -> LoadingScreenDatastore:
	return loading_screens.pick_random()

func getLoadingScreens() -> Array:
	return loading_screens
