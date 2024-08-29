@tool
class_name CardInfo extends GameObjectInfo

@export_multiline var flavor_text: String
@export var model: PackedScene
@export var points: Array
@export var rarity: RARITIES
@export var abilities: Array[AbilityDatastore]
@export var art_mini_coordinate: Vector2i
@export var art_pop: Image
@export var collision_shape: PackedScene
@export var base_stats: CardStatDatastore
@export var height: CardHeightDatastore
@export var audio: CardAudioDatastore

enum RARITIES {SCRAP, NEUTRAL, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
static func getInfoPath() -> String: return "res://resources/fof/cards/"
