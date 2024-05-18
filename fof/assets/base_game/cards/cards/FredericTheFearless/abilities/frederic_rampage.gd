extends RampageGD

func onRampageCondition(_a: Dictionary) -> bool: return true
func onRampage(a: Dictionary) -> void:
	match Units.GameState.hero_id:
		1:
			onGainStats(a.Unit, "health", 1, a.AppliedBy)
			if a.is_visible: a.Unit.Model.on_play_animation("Ability")
