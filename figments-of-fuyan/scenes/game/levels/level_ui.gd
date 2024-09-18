extends Control

var save_file: SaveFileGD
var area: AreaGD
var World: Node3D
var mouse_in_ui: bool

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file
	area = save_file.area
	
	Game.ActionManagerReference.action_playing.connect(onActionPlaying)

func onMouseInUI(state: bool) -> void:
	mouse_in_ui = state

#region Action Lock
var is_action_playing: bool
func onUpdateActionLock() -> void:
	pass

func getActionLock() -> bool:
	return is_action_playing

func onActionPlaying(state: bool) -> void:
	World.onActionPlaying(state)
	is_action_playing = state
	onUpdateActionLock()

#region Hand
@onready var HandBox: Container = %HandBox
