extends RampageGD

func onRampageCondition() -> bool: return true
func onRampage() -> void:
	match Units.GameState.save_info.hero_id:
		1:
			onGainStats(Unit, "health", 1, AppliedBy)
			if is_visible: Unit.Model.on_play_animation("Ability")
