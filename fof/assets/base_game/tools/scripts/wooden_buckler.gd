extends ToolGD

func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if _Unit == Unit and (!is_ascended and trigger == TriggerGD.WHEN_STRUCK) or (is_ascended and trigger == TriggerGD.REVENGE and _Unit == Unit):
		Unit.stats("attack", 1, AppliedByGD.new("Tool", Unit))
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterDelay, true, DelayGD.new(1.5)), ActionManagerGD.PUSH)
		VFX.onCreateUnitVFX(Unit, "WoodenBuckler")

func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "WoodenBuckler")
