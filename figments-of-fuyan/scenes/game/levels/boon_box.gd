extends GridContainer
@export var BoonIconPacked: PackedScene

func onAddBoon(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon)

func onUpdate() -> void:
	for BoonIcon in get_children(): BoonIcon.queue_free()
	for Boon in get_tree().get_nodes_in_group("BoonsGD"):
		onAddBoon(Boon)

func onUpdateBoonChargesAndDisabled(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = onFindBoonIcon(Boon)
	if BoonIcon != null:
		BoonIcon.onUpdateCharges(Boon.getCharges())
		BoonIcon.onUpdateDisabled(Boon.getDisabled())

func onFindBoonIcon(Boon: BoonGD) -> TextureRect:
	for BoonIcon in get_children():
		if BoonIcon.Boon == Boon: return BoonIcon
	return null
	
func onUpdateBoonAscension(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = onFindBoonIcon(Boon)
	if BoonIcon != null:
		BoonIcon.onUpdateAscension(Boon.ascended)
