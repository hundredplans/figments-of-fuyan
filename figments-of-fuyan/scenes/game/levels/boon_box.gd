extends GridContainer
@export var BoonIconPacked: PackedScene
var save_file: SaveFileGD

func setInfo(_save_file: SaveFileGD) -> void:
	save_file = _save_file

func onAddBoon(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon)

func onUpdate() -> void:
	for BoonIcon in get_children(): BoonIcon.queue_free()
	for Boon in save_file.boons:
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
