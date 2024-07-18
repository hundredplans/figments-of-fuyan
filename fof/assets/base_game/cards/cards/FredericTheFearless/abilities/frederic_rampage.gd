extends RampageGD

func onRampageCondition() -> bool: return true
func onRampage() -> void:
	match Units.GameState.save_info.hero_id:
		1:
			Units.changeStats(StatInfoGD.new(Unit, AppliedBy, StatsGD.BOTH_HEALTH, 1))
			if is_visible: Unit.Model.on_play_animation("Ability")
