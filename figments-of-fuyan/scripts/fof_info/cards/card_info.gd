class_name CardInfo extends GameObjectInfo

const FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/field_info.tscn"
const INSPECT_CARD_SCREEN: String = "res://scenes/game/cards/ui/inspect_card_screen.tscn"
const CARD_UI_SCENE_PATH: String = "res://scenes/game/cards/ui/card_ui.tscn"
const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
@export_group("Card")
@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int
@export var rarity: Game.Rarities
@export var initial_traits: Array[int]
@export_multiline var ability_text: String
@export_multiline var flavor_text: String
@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_mini: Image
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
@export var ascended_traits: Array[int]
# Leave empty if no changes
@export_multiline var ascended_ability_text: String
@export_group("")

static func getInfoPath() -> String: return "res://resources/fof/cards"

static func getFofName() -> String: return "Card"

func getArtMini() -> ImageTexture: return ImageTexture.create_from_image(art_mini)
func getArtPop() -> ImageTexture: return ImageTexture.create_from_image(art_pop)
