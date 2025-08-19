class_name ChangeEndOfTurnCardDrawAction extends Action

var delta: int
func _init(_delta: int = 0) -> void:
	super()
	delta = _delta
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	Game.getSaveFile().setEndOfTurnCardDraw(Game.getSaveFile().getEndOfTurnCardDraw() + delta)
