class_name ChangeActiveEffectChargesAction extends Action

var item: FofGD
var delta: int
var set_to_infinite: bool

func _init(_item: FofGD = null, _delta: int = 0, _set_to_infinite: bool = false) -> void:
	super()
	item = _item
	delta = _delta
	set_to_infinite = _set_to_infinite
	
func onPreAction() -> void:
	pass
	
func onPostAction() -> void:
	var current_charges: int = item.getActiveEffectCharges()
	if set_to_infinite:
		item.setActiveEffectCharges(-1)
		
	elif current_charges >= 0:
		item.setActiveEffectCharges(current_charges + delta)
		
	if current_charges == 0 and item is ToolGD and item.getRarity() == Game.Rarities.MINI:
		onPushAction(RemoveToolAction.new(item.Card))
