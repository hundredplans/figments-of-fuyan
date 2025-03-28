class_name CardOffset extends Resource

@export var position: Vector3
@export var rotation: Vector3 # Saved in radians

func _init(_position := Vector3.ZERO, _rotation := Vector3.ZERO):
	position = _position
	rotation = _rotation

func getPositionOffset() -> Vector3:
	return position
	
func getRotationOffset() -> Vector3:
	return rotation

func setPositionOffset(_position: Vector3) -> void:
	position = _position
	
func setRotationOffset(_rotation: Vector3) -> void:
	rotation = _rotation
