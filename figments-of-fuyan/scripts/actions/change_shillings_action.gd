class_name ChangeShillingsAction extends Action

@export var delta: int
func _init(_delta: int = 0) -> void:
	super()
	delta = _delta
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.getSaveFile().shillings = max(Game.getSaveFile().getShillings() + delta, 0)
	
func getDelta() -> int:
	return delta
