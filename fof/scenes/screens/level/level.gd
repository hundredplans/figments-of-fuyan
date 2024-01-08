extends Control
signal load_world
signal equip_sky

var _LevelMap: PackedScene = preload("res://scenes/screens/level/level_map.tscn")
var LevelMap: Node3D
var GameState: Node

func _ready() -> void:
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	
	load_world.emit(LevelMap)
	equip_sky.emit(GameState.area_info.id, false)
	
	var levels: Array = Helper.on_item_dicts("Level").filter(on_is_level_valid)
	GameState.level_info = levels[randi() % levels.size()]
	
	LevelMap.on_load_default_world_state()
	LevelMap.on_load_world_history()
	
func on_is_level_valid(level_info: Dictionary) -> bool:
	return level_info.area == GameState.area_info.id and level_info.difficulty == abs(GameState.map_progress.y - GameState.map_info.map_size)

func _queue_free() -> void:
	if !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)
