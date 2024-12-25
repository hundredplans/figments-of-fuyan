class_name StartGameAction extends Action

const START_TIME: int = 6.5
func _init() -> void:
	super()
	
func onPreAction() -> void:
	setActionDelay(START_TIME if !Helper.getAdmin() else 0)
	
func onPostAction() -> void:
	pass
