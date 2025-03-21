class_name BossIntentConditionResultBatAttack extends BossIntentConditionResult

@export var tile_rotation: int
@export var bat_coords: Dictionary[Vector4i, String] = {}

func setTileRotation(_tile_rotation: int) -> void:
	tile_rotation = _tile_rotation
	
func getTileRotation() -> int:
	return tile_rotation

func setBatCoords(_bat_coords: Dictionary[Vector4i, String]) -> void:
	bat_coords = _bat_coords

func getBatCoords() -> Dictionary[Vector4i, String]:
	return bat_coords
