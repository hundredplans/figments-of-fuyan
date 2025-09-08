extends GridContainer
@export var BoonIconPacked: PackedScene

signal mouse_in_ui

func onAddBoon(Boon: BoonGD, visual: bool = false) -> void:
	var BoonIcon: Control = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon, false, false, true)
	BoonIcon.onShowTierLabel()
	BoonIcon.setDisabled(Boon.getDisabled())
	
	if visual:
		BoonIcon.onItemGainedVisual()

func onUpdate(Boon: BoonGD = null, remove: bool = false) -> void:
	if Boon == null:
		for BoonIcon in get_children(): BoonIcon.queue_free()
		for _Boon in Game.getSaveFile().getBoons():
			onAddBoon(_Boon, false)
	elif !remove:
		onAddBoon(Boon, true)
	elif remove:
		for BoonIcon in get_children():
			if BoonIcon.getItem() == Boon: BoonIcon.queue_free()

func onUpdateBoonChargesAndDisabled(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = onFindBoonIcon(Boon.info.id)
	if BoonIcon != null:
		BoonIcon.onUpdateCharges(Boon.getCharges())
		BoonIcon.setDisabled(Boon.getDisabled())

func onFindBoonIcon(id: int) -> TextureRect:
	for BoonIcon in get_children():
		if BoonIcon.Boon.info.id == id: return BoonIcon
	return null
		
var is_mouse_in_ui: bool
func onMouseInUI(state: bool) -> void:
	is_mouse_in_ui = state
	mouse_in_ui.emit(state)
