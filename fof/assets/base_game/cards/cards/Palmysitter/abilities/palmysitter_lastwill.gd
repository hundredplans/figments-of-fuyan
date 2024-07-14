extends LastWillGD

func onLastWillCondition() -> bool:
	return true

func onLastWill() -> void:
	ActionManager.onAddAction(DelayActionGD.new(Units.onUnitAwakened.bind(7, Deather.team, Deather.Model.rot, Deather.Tile), is_visible))
	
