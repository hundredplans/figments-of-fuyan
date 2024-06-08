extends LastWillGD

func onLastWillCondition() -> bool:
	return true

func onLastWill() -> void:
	await Units.onUnitAwakened(7, 0, [], Deather.team, Deather.Model.rot, Deather.Tile)
