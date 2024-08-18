@tool
extends GameObjectInfoGD
class_name UnitInfoGD

#region Exports
@export_group("Info")
@export var base_stats: UnitStatInfoGD
@export var rarity: RARITIES
@export_group("")
@export_group("Assets")
@export var art_pop: Texture2D
@export var art_mini: Texture2D
@export var audio: UnitAudioInfoGD
@export_group("")
#endregion

#region Enums
enum RARITIES {SCRAP, COMMON, RARE, EXALT, MINIBOSS, BOSS, CHAMPION}
#endregion

#region SettingID
func _init() -> void:
	id = StaticHelper.onAutoIncrementID("res://resources/game/game_object/unit/info/", UnitInfoGD, id)
#endregion
