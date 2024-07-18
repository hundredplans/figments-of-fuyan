extends ToolGD

func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if _Unit == Unit and (!is_ascended and trigger == TriggerGD.WHEN_STRUCK) or (is_ascended and trigger == TriggerGD.REVENGE and _Unit == Unit):
		Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TOOL, self), StatsGD.ATTACK, 1))
		ActionManager.onAddAction(ArgDelayActionGD.new(Callable(), onAfterDelay, true, DelayGD.new(1.5)), ActionManagerGD.PUSH)
		VFX.onCreateUnitVFX(Unit, "WoodenBuckler")

func onAfterDelay() -> void:
	VFX.onRemoveUnitVFX(Unit, "WoodenBuckler")
