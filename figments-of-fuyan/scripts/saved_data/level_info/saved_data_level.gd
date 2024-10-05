class_name SavedDataLevel extends SavedData
	
@export var timeout: int
@export var phase: Game.Phases
@export var level_camera_data: LevelCameraData
@export var data: Array
@export var energy: int
@export var max_energy: int
@export var enemy_spawn_ids: Array
@export var field_cards_data: Array
func _init(_id: int = 0, _first_init: bool = false, _data: Array = [], _timeout: int = 0, _enemy_spawn_ids: Array = [], _field_cards_data: Array = [], \
	_phase := Game.Phases.NULL, _level_camera_data: LevelCameraData = null, _energy: int = 0, _max_energy: int = 0) -> void:
	super(_id, _first_init)
	data = _data
	timeout = _timeout
	phase = _phase
	energy = _energy
	max_energy = _max_energy
	level_camera_data = _level_camera_data
	field_cards_data = _field_cards_data
	enemy_spawn_ids = _enemy_spawn_ids
	
func getInfoType() -> GDScript: return LevelInfo
