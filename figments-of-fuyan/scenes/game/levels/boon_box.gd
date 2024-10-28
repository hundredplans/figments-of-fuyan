extends GridContainer
@export var BoonIconPacked: PackedScene

func onAddBoon(Boon: BoonGD) -> void:
	var BoonIcon: TextureRect = BoonIconPacked.instantiate()
	add_child(BoonIcon)
	BoonIcon.setInfo(Boon)

func onUpdate() -> void:
	for BoonIcon in get_children(): BoonIcon.queue_free(); print(BoonIcon)
	for Boon in get_tree().get_nodes_in_group("BoonsGD"):
		onAddBoon(Boon)
