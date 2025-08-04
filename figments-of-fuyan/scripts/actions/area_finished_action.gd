class_name AreaFinishedAction extends Action

var difficulty: int
func _init(_difficulty: int = 1) -> void:
	super()
	difficulty = _difficulty
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.getSaveFile().onAreaFinished(difficulty)
