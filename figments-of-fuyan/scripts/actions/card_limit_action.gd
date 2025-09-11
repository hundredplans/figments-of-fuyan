class_name CardLimitAction extends Action

@export var delta: int
func _init(_delta: int = 0) -> void:
	super()
	delta = _delta
	
func onPostAction() -> void:
	Game.getSaveFile().onUpdateCardLimit(delta)

func getDelta() -> int: return delta
