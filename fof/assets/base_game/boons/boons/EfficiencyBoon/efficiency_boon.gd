extends BoonGD

var charges: int = 0
func onTrigger(_Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == 0: charges = 0
	if trigger == TriggerGD.CARD_PLACED:
		charges += 1
		if charges == 2: Hand.on_change_energy(2 if is_ascended else 1)
		LevelUI.setBoonDisabled(self, charges == 2)
		
	if trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == 0:
		LevelUI.setBoonDisabled(self, false)
