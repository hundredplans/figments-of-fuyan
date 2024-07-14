extends ToolGD

func onTrigger(_Unit: UnitGD, trigger: int, _args: Array) -> void:
	if trigger == TriggerGD.LAST_WILL and Unit == _Unit:
		if !is_ascended:
			for __Unit in Units.onFindAdjacentUnits(Unit, 1):
				Combat.onDMG(__Unit, AppliedByGD.new("Tool", Unit), 1)
		else:
			for __Unit in Units.onFindAdjacentUnits(Unit, 2).filter(func(x: UnitGD): return x.team != Unit.team):
				Combat.onDMG(__Unit, AppliedByGD.new("Tool", Unit), 1)
