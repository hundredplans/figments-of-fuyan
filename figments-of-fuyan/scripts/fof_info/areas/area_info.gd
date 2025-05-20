class_name AreaInfo extends FofInfo

@export var world: WorldDatastore
@export var card_background: Image
@export var champion_entrance_packed: PackedScene
@export var card_ids: Array[int]
@export var encounter_ids: Array[int]
@export var overworld_decoration: DecorationDatastore
@export var base_environment: Environment
@export var elite_environment: Environment
@export var base_level_script: GDScript
@export var base_tile_info: TileInfo
@export var default_light: PackedScene
@export var boss_music: AudioStream
@export var epic_datastores: Array[EpicAreaDatastore]
@export var main_menu_decoration: DecorationDatastore
@export var area_color: Color

@export_group("Tile Fill")
@export var tile_fill_material: ShaderMaterial
@export var tile_fill_greyscale_material: ShaderMaterial
@export_group("")

static func getInfoPath() -> String: return "res://resources/fof/areas"
static func getFofName() -> String: return "Area"
