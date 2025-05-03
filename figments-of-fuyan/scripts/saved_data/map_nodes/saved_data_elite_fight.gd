class_name SavedDataEliteFight extends SavedDataFight

@export var curse_id: int
func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _is_entered: bool = false, _is_finished: bool = false,\
	_rotation_y: float = 0, _ability_save: Dictionary = {}, _level_info: LevelInfo = null, _spawn_group: String = "", _enemy_cards: Array = [], _level_preview: LevelPreview = null,\
	_curse_id: int = 0) -> void:
		super(_id, _first_init, _public_id, _map_location, _links, _is_entered, _is_finished, _rotation_y, _ability_save, _level_info, _spawn_group, _enemy_cards, _level_preview)
		curse_id = _curse_id
