class_name StartGameAction extends Action

const START_TIME: float = 6.5
func _init() -> void:
	super()
	
func onPreAction() -> void:
	setActionDelay(START_TIME if !Helper.admin_datastore.skip_level_start_animation else 0.0)
	
func onPostAction() -> void:
	pass
