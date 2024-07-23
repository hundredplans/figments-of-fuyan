extends StatusFXGD

var turns: int = 0

func onAfterSetInfo(_turns: int) -> void:
	turns = _turns

func onTrigger(Unit: UnitGD, trigger: int, args: TriggerInfoGD) -> void:
	if trigger == TriggerGD.START_TURN_GLOBAL and args.team_relation.onTeam() == Unit.team:
		turns -= 1
		if turns == 0: onRemoveSelf()
