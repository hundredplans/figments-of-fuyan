class_name SavedDataCactusLevel extends SavedDataLevel

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _data: Array = [], _enemy_spawns: Array = [], _field_cards_data: Array = [], \
	_phase := Game.Phases.NULL, _level_camera_data: LevelCameraData = null, _energy: int = 0, _max_energy: int = 0, _is_elite: bool = false, _is_ended: bool = false,
	_rewards: Rewards = null, _anti_boons: Array = []) -> void:
	super(_id, _first_init, _public_id, _data, _enemy_spawns, _field_cards_data, _phase, _level_camera_data, _energy, _max_energy,\
	_is_elite, _is_ended, _rewards, _anti_boons)
	
func getInfoType() -> GDScript: return LevelInfo
	
