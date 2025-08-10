extends GridContainer
@export var BoonIconPacked: PackedScene

signal mouse_in_ui

func onAddBoon(Boon: BoonGD) -> void:
	var BoonIcon: Control = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon)
	BoonIcon.setDisabled(Boon.getDisabled())

func onUpdate() -> void:
	for BoonIcon in get_children(): BoonIcon.queue_free()
	for Boon in Game.getSaveFile().getBoons():
		onAddBoon(Boon)

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
