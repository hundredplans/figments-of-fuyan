class_name Action extends Resource

signal push_action
signal append_action

var post: bool = false
var owner: Variant # FofGD or another action ALWAYS

func _init() -> void:
	push_action.connect(Game.ActionManagerReference.onPushAction)
	append_action.connect(Game.ActionManagerReference.onAppendAction)
	Game.ActionManagerReference.pre_action.connect(onProcessAction)
	Game.ActionManagerReference.post_action.connect(onProcessAction)

func getDelay() -> float: return 0

func onProcess() -> void:
	pass

func onProcessAction(_action: Action) -> void:
	pass
	
func onPushAction(action: Action) -> void:
	action.owner = self
	push_action.emit(action)
	
func onAppendAction(action: Action) -> void:
	action.owner = self
	append_action.emit(action)
