extends TrinketEffectGD

var description: String = "Gain [+1/0]; Gain [+0/1] on this unit's first RAMPAGE"
func onReady() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TRINKET, self), StatsGD.ATTACK, 1))
	
func onTrigger(_Unit: UnitGD, trigger: int, _args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.RAMPAGE and Unit == _Unit:
		Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.TRINKET, self), StatsGD.BOTH_HEALTH, 1))
		onRemoveGameFX()
