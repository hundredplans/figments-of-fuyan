@tool
class_name TileObjectInfoGD
extends GameObjectInfoGD

# Locks the rotation to the 6 base axis
@export var lock_rotation: bool
# Locks to only be placeable on tiles
@export var lock_tile: bool
@export var solids: Array[bool]

#region SettingID
func _init() -> void:
	id = StaticHelper.onAutoIncrementID("res://resources/game/game_object/tile_object/info/", TileObjectInfoGD, id)
#endregion
