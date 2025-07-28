class_name BossIntentConditionResultSilasJumpAttack extends BossIntentConditionResult

@export var jump_to_coords: Vector4i
@export var start_jump_coords: Vector4i

func setJumpToCoords(_coords: Vector4i) -> void:
	jump_to_coords = _coords
	
func setStartJumpCoords(_coords: Vector4i) -> void:
	start_jump_coords = _coords

func getJumpToCoords() -> Vector4i:
	return jump_to_coords
	
func getStartJumpCoords() -> Vector4i:
	return start_jump_coords
