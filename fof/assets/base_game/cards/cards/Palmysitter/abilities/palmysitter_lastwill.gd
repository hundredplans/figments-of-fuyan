extends LastWillGD

func onLastWillCondition() -> bool:
	return true

func onLastWill() -> void:
	var _Unit: UnitGD = await Units.on_unit_awakened(7, 0, [], Deather.team, Deather.Model.rot, Deather.Tile)
	if _Unit != null: SpectateCamera.onSpectate(_Unit)
