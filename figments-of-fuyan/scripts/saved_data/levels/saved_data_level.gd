class_name SavedDataLevel extends SavedData
	
@export var phase: Game.Phases
@export var level_camera_data: LevelCameraData
@export var data: Array
@export var energy: int
@export var max_energy: int
@export var enemy_spawns: Array
@export var field_cards_data: Array
@export var is_elite: bool
@export var is_ended: bool
@export var rewards: Rewards
@export var anti_boons: Array
@export var old_player_vision: Array
@export var player_card_last_seen_turn: int
@export var level_area_datastore: LevelAreaDatastore

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _data: Array = [], _enemy_spawns: Array = [], _field_cards_data: Array = [], \
	_phase := Game.Phases.NULL, _level_camera_data: LevelCameraData = null, _energy: int = 0, _max_energy: int = 0, _is_elite: bool = false, _is_ended: bool = false,
	_rewards: Rewards = null, _anti_boons: Array = [], _old_player_vision: Array = [], _player_card_last_seen_turn: int = -1, _level_area_datastore: LevelAreaDatastore = null) -> void:
	super(_id, _first_init, _public_id)
	data = _data
	phase = _phase
	energy = _energy
	max_energy = _max_energy
	level_camera_data = _level_camera_data
	field_cards_data = _field_cards_data
	enemy_spawns = _enemy_spawns
	is_elite = _is_elite
	is_ended = _is_ended
	rewards = _rewards
	anti_boons = _anti_boons
	old_player_vision = _old_player_vision
	player_card_last_seen_turn = _player_card_last_seen_turn
	level_area_datastore = _level_area_datastore
	
func getInfoType() -> GDScript: return LevelInfo
		
