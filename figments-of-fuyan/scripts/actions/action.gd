class_name Action extends Resource

signal push_action
signal append_action
signal force_action

var failed: bool = false
var post: bool = false
var owner: Variant # FofGD or another action always

func _init() -> void:
	push_action.connect(Game.ActionManagerReference.onPushAction)
	append_action.connect(Game.ActionManagerReference.onAppendAction)
	force_action.connect(Game.ActionManagerReference.onForceAction)
	Game.ActionManagerReference.process_action.connect(onProcessAction)

#region Fillers
func getDelay() -> float: return 0
func onPreAction() -> void: pass
func onPostAction() -> void: pass
func onProcessAction(_action: Action) -> void: pass
#endregion
	
func onPushAction(action: Action) -> void:
	action.owner = self
	push_action.emit(action)
	
func onAppendAction(action: Action) -> void:
	action.owner = self
	append_action.emit(action)
	
func onFailAction() -> void:
	failed = true
