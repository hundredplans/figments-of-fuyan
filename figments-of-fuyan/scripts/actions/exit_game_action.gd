class_name ExitGameAction extends Action

func _init() -> void:
	super()
	
func onPreAction() -> void:
	if !Game.ActionManagerReference.actions.is_empty():
		onAppendAction(ExitGameAction.new())
		onFailAction()
	
func onPostAction() -> void:
	pass
