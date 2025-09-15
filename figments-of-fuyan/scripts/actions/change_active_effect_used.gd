class_name ChangeActiveEffectUsedAction extends Action

var item: FofGD # CardGD, ToolGD, IObjectGD
var state: bool

func _init(_item: FofGD, _state: bool = false) -> void:
	super()
	item = _item
	state = _state
	
func onPreAction() -> void:
	onCheckFail()
	
func onPostAction() -> void:
	item.setActiveEffectUsed(state)

func onCheckFail() -> void:
	if item.getActiveEffectUsed() == state: onFailAction()
