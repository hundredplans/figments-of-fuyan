class_name CardInfo extends GameObjectInfo

const CARD_UI_SCENE_PATH: String = "res://scenes/game/cards/ui/card_ui.tscn"
@export_group("Card")
@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int
@export var rarity: Game.Rarities
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

@export var abilities: Array[AbilityDatastore]

static func getInfoPath() -> String: return "res://resources/fof/cards"

static func getFofName() -> String: return "Card"

func getArtMini() -> ImageTexture: return ImageTexture.create_from_image(art_mini)
func getArtPop() -> ImageTexture: return ImageTexture.create_from_image(art_pop)
