extends GameObject
signal load_world
signal equip_sky

var _LevelMap: PackedScene = preload("res://scenes/screens/level_map/level_map.tscn")
var LevelMap: Node3D
var GameState: Node

func _ready() -> void:
	var levels: Array = Helper.on_item_dicts("Level").filter(on_is_level_valid)
	GameState.level_info = levels[randi() % levels.size()]
	
	LevelMap = _LevelMap.instantiate()
	LevelMap.GameState = GameState
	LevelMap.LevelUI = self
	
	load_world.emit(LevelMap)
	equip_sky.emit(GameState.area_info.id, false)
	
func on_is_level_valid(level_info: Dictionary) -> bool:
	return level_info.area == GameState.area_info.id and level_info.difficulty == abs(GameState.map_progress.y - GameState.map_info.map_size)

func _queue_free() -> void:
	if !Helper.settings_loaded:
		GameState._queue_free()
		load_world.emit(null)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("SelectLeft"): LevelMap.SpectateCamera.on_select_spectate_camera_direction(-1)
	elif Input.is_action_just_pressed("SelectRight"): LevelMap.SpectateCamera.on_select_spectate_camera_direction(1)
