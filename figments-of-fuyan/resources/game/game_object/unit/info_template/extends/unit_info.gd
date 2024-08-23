@tool
extends GameObjectInfoGD
class_name UnitInfoGD

static var INFO_PATH: String = "res://resources/game/game_object/unit/info/"
const CARD_UI_SCENE_PATH: String = "res://scenes/game/units/cards/card_ui.tscn"
#region Exports
@export var rarity: RARITIES
#endregion

#region Enums
enum RARITIES {SCRAP, NEUTRAL, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
#endregion

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_pop: Array[Image]
@export_group("")

@export_group("Base")
@export var collision_shape: PackedScene
@export var base_stats: Array[UnitStatInfoGD]
@export var heights: Array[UnitHeightInfoGD]
@export var audio: Array[UnitAudioInfoGD]
@export_group("")

#region Getters
func getHeight(variation: int) -> UnitHeightInfoGD:
	return heights[variation]

func getArtPop(variation: int) -> Image:
	return art_pop[variation]
	
func getBaseData() -> SavedDataUnit: return SavedDataUnit.new(id)
#endregion

#region SettingID
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(UnitInfoGD, id)
#endregion
