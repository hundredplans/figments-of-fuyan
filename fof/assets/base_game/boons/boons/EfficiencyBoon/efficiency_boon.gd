extends BoonGD

var turn_count: int = 0
var cards_played: int = 0

func onTrigger(_Unit: UnitGD, trigger: int, args: Array) -> void:
	if trigger == TriggerGD.CARD_PLACED:
		if turn_count != LevelMap.turns: cards_played = 0
		turn_count = LevelMap.turns
		cards_played += 1
		if cards_played == 2: Hand.on_change_energy(2 if is_ascended else 1)
		LevelUI.setBoonDisabled(self, cards_played == 2)
		
	if trigger == TriggerGD.START_TURN_GLOBAL and args[0].onTeam() == 0:
		LevelUI.setBoonDisabled(self, false)
