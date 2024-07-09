extends BoonGD

var charges: int = 0
func onTrigger(_Unit: UnitGD, trigger: int, args: Array) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL and args[0].onTeam() == 0 and charges > 0:
		for Unit in Units.on_units(TeamRelationGD.new(1)):
			GameEffects.addGFX(Unit, GameFXGD.DAZE)
			GameEffects.addGFX(Unit, GameFXGD.STAGGER)
		charges -= 1
		LevelUI.setBoonDisabled(self, charges == 0)
		
func onArrive() -> void:
	charges = 2 if is_ascended else 1
