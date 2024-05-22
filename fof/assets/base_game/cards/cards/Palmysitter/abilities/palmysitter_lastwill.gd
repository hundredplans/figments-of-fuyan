extends LastWillGD

func onLastWillCondition() -> bool:
	return true

func onLastWill() -> void:
	Units.on_unit_awakened(7, 0, [], Deather.team, Deather.Model.rot, Deather.Tile)
