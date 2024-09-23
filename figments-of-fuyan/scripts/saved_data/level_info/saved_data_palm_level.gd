class_name SavedDataPalmLevel extends SavedDataLevel

@export var decoration_datas: Array
@export var decoration_coords: Array


func _init(_id: int = 0, _first_init: bool = false, _data: Array = [], _timeout: int = 0, \
	_phase := Game.Phases.START, _level_camera_data: LevelCameraData = null, _energy: int = 0, _max_energy: int = 0,\
	_decoration_datas: Array = [],  _decoration_coords: Array = []) -> void:
	super(_id, _first_init, _data, _timeout, _phase, _level_camera_data, _energy, _max_energy)
	decoration_datas = _decoration_datas
	decoration_coords = _decoration_coords
	
func getInfoType() -> GDScript: return PalmLevelInfo
