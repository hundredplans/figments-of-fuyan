@tool
class_name TileObjectInfoGD
extends GameObjectInfoGD

static var INFO_PATH: String = "res://resources/game/game_object/tile_object/info/"
# Locks the rotation to the 6 base axis
@export var solids: Array[bool]

#region SettingID
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(TileObjectInfoGD, id)
#endregion
