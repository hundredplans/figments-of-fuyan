extends VBoxContainer

signal pressed
signal mouse_in_ui

@export var ActiveEffectBoxPacked: PackedScene

func onUpdate(active_effects: Array, Card: CardGD) -> void:
	for grandchild in getGrandchildren():
		grandchild.queue_free()
		grandchild.get_parent().remove_child(grandchild)
	
	for i in range(active_effects.size()):
		var active_effect: ActiveEffectDatastore = active_effects[i]
		var ActiveEffectBox: Control = ActiveEffectBoxPacked.instantiate()
		get_child(i % 2).add_child(ActiveEffectBox)
		
		ActiveEffectBox.setInfo(active_effect, Card, is_action_lock)
		ActiveEffectBox.mouse_in_ui.connect(func(x: bool): mouse_in_ui.emit(x))
		ActiveEffectBox.pressed.connect(func(x: ActiveEffectDatastore): pressed.emit(x))

func getGrandchildren() -> Array:
	var grandchildren: Array = []
	for child in get_children():
		for grandchild in child.get_children().filter(func(x: Control): return !x.is_queued_for_deletion()):
			grandchildren.append(grandchild)
	return grandchildren
	
var is_action_lock: bool
func onUpdateActionLock(state: bool) -> void:
	is_action_lock = state
	for grandchild in getGrandchildren():
		grandchild.onUpdateActionLock(state) 
