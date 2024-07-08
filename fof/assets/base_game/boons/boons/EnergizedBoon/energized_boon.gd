extends BoonGD

var GameEffects: GameEffectsGD
func onTrigger(Unit: UnitGD, trigger: int, _args: Array) -> void:
	if trigger == TriggerGD.AWAKEN and Unit.team == 0:
		GameEffects.addGFX(Unit, GameFXGD.ENERGIZED_BOON, {"speed": 1 if !is_ascended else 2})
