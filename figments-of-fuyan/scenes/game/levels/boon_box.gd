extends GridContainer
@export var BoonIconPacked: PackedScene

signal mouse_in_ui

func onAddBoon(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon)
	BoonIcon.mouse_in_ui.connect(onMouseInUI)

func onUpdate() -> void:
	for BoonIcon in get_children(): BoonIcon.queue_free()
	for Boon in Game.getSaveFile().getBoons():
		onAddBoon(Boon)

func onUpdateBoonChargesAndDisabled(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = onFindBoonIcon(Boon)
	if BoonIcon != null:
		BoonIcon.onUpdateCharges(Boon.getCharges())
		BoonIcon.setDisabled(Boon.getDisabled())

func onFindBoonIcon(Boon: BoonGD) -> TextureRect:
	for BoonIcon in get_children():
		if BoonIcon.Boon == Boon: return BoonIcon
	return null
	
func onUpdateBoonAscension(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = onFindBoonIcon(Boon)
	if BoonIcon != null:
		BoonIcon.onUpdateAscension(Boon.ascended)
		
func onMouseInUI(state: bool) -> void:
	mouse_in_ui.emit(state)
