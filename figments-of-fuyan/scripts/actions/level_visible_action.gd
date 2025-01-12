class_name LevelVisibleAction extends Action

var state: bool
var game_objects: Array

func _init(_state: bool = false, _game_objects: Array = []) -> void:
	super()
	state = _state
	game_objects = _game_objects
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	for GameObject in game_objects:
		GameObject.setLevelVisible(state)

func getLogInfo() -> Array:
	return ["State: " + str(state), "Amount: " + str(game_objects.size())]
