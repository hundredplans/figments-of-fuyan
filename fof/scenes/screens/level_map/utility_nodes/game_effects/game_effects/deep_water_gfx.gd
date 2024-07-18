extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemoved, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	
	var AppliedBy := AppliedByGD.new(AppliedByGD.DEEP_WATER)
	if !Tiles.onCanDrown(Unit):
		Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_SPEED, -1))
	else: Combat.onDestroyUnit(Unit, AppliedBy)

func onRemoved() -> void:
	Units.changeStats(StatInfoGD.new(Unit, AppliedByGD.new(AppliedByGD.DEEP_WATER), StatsGD.BOTH_SPEED, 1))
