extends LastWillGD

func onLastWillCondition(_a: Dictionary) -> bool:
	return true

func onLastWill(a: Dictionary) -> void:
	Units.on_unit_awakened(7, 0, [], a.Deather.team, a.Deather.Model.rot, a.Deather.Tile)
