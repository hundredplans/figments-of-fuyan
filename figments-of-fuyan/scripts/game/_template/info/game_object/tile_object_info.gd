@tool
class_name TileObjectInfoGD
extends GameObjectInfoGD

static var INFO_PATH: String = "res://resources/game/tile_objects/"
# Locks the rotation to the 6 base axis

#region SettingID
func _init() -> void:
	id = StaticHelper.onAutoIncrementID(TileObjectInfoGD, id)
#endregion
