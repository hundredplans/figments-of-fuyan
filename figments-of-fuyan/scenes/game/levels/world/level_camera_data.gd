class_name LevelCameraData extends Resource

@export var spectate_type: Game.SpectateTypes
@export var ally_spectate_index: int
@export var spawn_spectate_index: int
@export var is_in_freelook: bool
@export var freelook_posrot: PosRot
@export var total_progress: Vector2
@export var camera_radius: float

func _init(_spectate_type := Game.SpectateTypes.ALLY, _ally_spectate_index: int = 0, _spawn_spectate_index: int = 0, _is_in_freelook: bool = false\
	,_freelook_posrot: PosRot = null, _total_progress: Vector2 = Vector2.ZERO, _camera_radius: float = 0) -> void:
		spectate_type = _spectate_type
		ally_spectate_index = _ally_spectate_index
		spawn_spectate_index = _spawn_spectate_index
		is_in_freelook = _is_in_freelook
		freelook_posrot = _freelook_posrot
		total_progress = _total_progress
		camera_radius = _camera_radius
