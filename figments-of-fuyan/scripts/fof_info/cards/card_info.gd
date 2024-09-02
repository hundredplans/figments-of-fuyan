@tool
class_name CardInfo extends GameObjectInfo

const CARD_UI_SCENE_PATH: String = "res://scenes/game/fof/units/ui/card_ui.tscn"

@export_group("Card")
@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int
@export var rarity: RARITIES
@export_multiline var flavor_text: String
@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
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
@export var base_stats: CardStatDatastore
@export var height: CardHeightDatastore
@export var audio: CardAudioDatastore

enum RARITIES {SCRAP, NEUTRAL, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
static func getInfoPath() -> String: return "res://resources/fof/cards"
