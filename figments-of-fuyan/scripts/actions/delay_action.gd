class_name DelayAction extends Action

func _init(_delay: float = 0.0) -> void:
	super()
	action_delay = _delay
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
