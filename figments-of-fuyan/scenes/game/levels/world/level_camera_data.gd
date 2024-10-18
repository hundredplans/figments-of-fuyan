class_name LevelCameraData extends Resource

@export var coords: Vector4i
@export var is_in_freelook: bool
@export var freelook_posrot: PosRot
@export var total_progress: Vector2
@export var camera_radius: float

func _init(_coords := Vector4i.ZERO, _is_in_freelook: bool = false\
	,_freelook_posrot: PosRot = null, _total_progress: Vector2 = Vector2.ZERO, _camera_radius: float = 0) -> void:
		coords = _coords
		is_in_freelook = _is_in_freelook
		freelook_posrot = _freelook_posrot
		total_progress = _total_progress
		camera_radius = _camera_radius
