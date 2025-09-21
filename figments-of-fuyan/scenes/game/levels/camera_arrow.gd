extends DefaultButton

var action_lock: bool
var is_in_freelook_camera: bool

func setActionLock(state: bool) -> void:
	action_lock = state
	onUpdateDisabled()
	
func setIsInFreelook(state: bool) -> void:
	is_in_freelook_camera = state
	onUpdateDisabled()
	
func onUpdateDisabled() -> void:
	setDisabled(action_lock or is_in_freelook_camera)
