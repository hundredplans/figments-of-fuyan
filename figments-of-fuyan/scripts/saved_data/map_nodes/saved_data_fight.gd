class_name SavedDataFight extends SavedDataMapNode

@export var level_info: LevelInfo
@export var spawn_group: String
@export var enemy_cards: Array # Array[SavedDataCard]
@export var level_rewards: LevelRewards

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _is_entered: bool = false, _is_finished: bool = false,\
	_rotation_y: float = 0, _ability_save: Dictionary = {}, _level_info: LevelInfo = null, _spawn_group: String = "", _enemy_cards: Array = [], _level_rewards: LevelRewards = null) -> void:
	super(_id, _first_init, _public_id, _map_location, _links, _is_entered, _is_finished, _rotation_y, _ability_save)
	level_info = _level_info
	spawn_group = _spawn_group
	enemy_cards = _enemy_cards
	level_rewards = _level_rewards
	
	
