extends GameFXGD

func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemoved, TriggerGD.REMOVE, TriggerGD.NULL)
	]
	
	var AppliedBy := AppliedByGD.new("DeepWater")
	if !Tiles.onCanDrown(Unit):
		Unit.stats("full_speed", -1, AppliedBy)
	else: Combat.onDestroyUnit(Unit, AppliedBy)

func onRemoved() -> void:
	Unit.stats("speed", 1, AppliedByGD.new("DeepWater"))
