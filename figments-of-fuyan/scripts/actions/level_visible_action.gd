class_name LevelVisibleAction extends Action

var Discoverer: GameObjectGD
var game_objects: Array
var state: bool

func _init(_Discoverer: GameObjectGD = null, _state: bool = false, _game_objects: Array = []) -> void:
	super()
	Discoverer = _Discoverer
	state = _state
	game_objects = _game_objects
	
func onPostAction() -> void:
	for GameObject in game_objects:
		GameObject.setLevelVisible(state, Discoverer)
