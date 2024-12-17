extends Button

var action_lock: bool
var is_in_freelook_camera: bool

func setActionLock(state: bool) -> void:
	action_lock = state
	updateDisabled()
	
func setIsInFreelook(state: bool) -> void:
	is_in_freelook_camera = state
	updateDisabled()
	
func updateDisabled() -> void:
	disabled = action_lock or is_in_freelook_camera
