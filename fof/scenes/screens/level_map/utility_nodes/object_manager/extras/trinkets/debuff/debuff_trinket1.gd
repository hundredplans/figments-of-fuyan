extends TrinketEffectGD

var description: String = "LAST WILL: MUTE the attacker"
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.LAST_WILL and Unit == _Unit:
		var Killer: UnitGD = args.AppliedBy.getUnit()
		if Killer != null:
			GameEffects.addGFX(Killer, GameFXGD.MUTE)
