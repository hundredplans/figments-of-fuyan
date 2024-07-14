extends ToolGD

func onTrigger(_Unit: UnitGD, trigger: int, _args: Array) -> void:
	if _Unit == Unit and (!is_ascended and trigger == TriggerGD.WHEN_STRUCK) or (is_ascended and trigger == TriggerGD.REVENGE and _Unit == Unit):
		Unit.stats("attack", 1, AppliedByGD.new("Tool", Unit))
		
