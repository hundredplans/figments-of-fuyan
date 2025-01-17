class_name CardInfo extends GameObjectInfo

const FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/field_info.tscn"
const INSPECT_CARD_SCREEN: String = "res://scenes/game/cards/ui/inspect_card_screen.tscn"
const CARD_UI_SCENE_PATH: String = "res://scenes/game/cards/ui/card_ui.tscn"
const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
const UNIT_VISIBLE_PARTICLE_SCENE_PATH: String = "res://scenes/particles/unit_visible_particle.tscn"
const BASE_MATERIAL_ASCENDED_PATH: String = "res://resources/materials/game/base_material_ascended.tres"

const BASE_MATERIAL_BROWN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_brown_transparent.tres"
const BASE_MATERIAL_GREEN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_green_transparent.tres"
const BASE_MATERIAL_RED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent.tres"
const BASE_MATERIAL_ALPHAGREY_PATH: String = "res://resources/materials/game/base_material_alphagrey.tres"

@export_group("Card")
@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int
@export var rarity: Game.Rarities
@export var initial_traits: Array[SavedDataTrait]
@export var active_abilities: Array[ActiveAbilityDatastore]
@export_multiline var flavor_text: String
@export_multiline var description: String
@export_multiline var ascended_description: String

@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_mini: Texture2D
@export var art_pop: Image
@export_group("")

@export_group("3D")
@export var model: PackedScene
@export var points: Array
@export var collision_shape: PackedScene
@export_group("")

@export_group("Height")
@export var stat: float
@export var top: float
@export var eye: float
@export_group("")

@export_group("Ascended")
@export var plus_attack: int
@export var plus_health: int
@export var plus_speed: int
@export var plus_energy: int
@export var ascended_traits: Array[SavedDataTrait]
@export_group("")

@export var archetype: ArchetypeInfo

static func getInfoPath() -> String: return "res://resources/fof/cards"

static func getFofName() -> String: return "Card"

func getArtMini() -> Texture2D: return art_mini
func getArtPop() -> ImageTexture: return ImageTexture.create_from_image(art_pop)
func getIcon() -> Texture2D: return art_mini
func getDescription(ascended: bool = false) -> String:
	return description if !ascended else (ascended_description if !ascended_description.is_empty() else description)

func getStats(ascended: bool = false) -> StatsDatastore:
	return StatsDatastore.new(\
		attack + (plus_attack if ascended else 0),
		health + (plus_health if ascended else 0),
		speed + (plus_speed if ascended else 0),
		energy + (plus_energy if ascended else 0))

func getColoredBaseMaterial(team: int) -> ShaderMaterial:
	match team:
		0: return load(BASE_MATERIAL_GREEN_TRANSPARENT_PATH)
		1: return load(BASE_MATERIAL_RED_TRANSPARENT_PATH)
		2: return load(BASE_MATERIAL_BROWN_TRANSPARENT_PATH)
	return null
