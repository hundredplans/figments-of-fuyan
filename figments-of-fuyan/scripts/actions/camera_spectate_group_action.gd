class_name CameraSpectateGroupAction extends Action

# Team = -1 is spawn, 1 is enemies and neutrals
var team: int
func _init(_team: int = 0) -> void:
	super()
	team = _team
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	pass
