class_name BossIntentConditionResultFanBlind extends BossIntentConditionResult

@export var tile_rotation: int # Which way the fan blind faces

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation

func getTileRotation() -> int:
	return tile_rotation
