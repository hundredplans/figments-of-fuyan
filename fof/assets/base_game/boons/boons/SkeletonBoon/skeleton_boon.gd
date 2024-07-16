extends BoonGD

var charges: int
func onTrigger(Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.LAST_WILL and Unit.team == 0 and charges > 0:
		ActionManager.onAddAction(DelayActionGD.new(onDelayFinished.bind(Unit), true))
		
func onDelayFinished(Unit: UnitGD) -> void:
	var _Unit: UnitGD = await Units.onUnitAwakened(25, Unit.team, Unit.Model.rot, Unit.Tile)
	if _Unit: charges -= 1
	LevelUI.setBoonDisabled(self, charges == 0)
		
func onArrive() -> void:
	charges = 2 if is_ascended else 1
