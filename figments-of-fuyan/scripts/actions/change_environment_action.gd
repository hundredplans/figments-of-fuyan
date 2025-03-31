class_name ChangeEnvironmentAction extends Action

var environment: Environment
func _init(_environment: Environment = null) -> void:
	super()
	environment = _environment
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
