extends RampageGD

func onRampage(is_visible: bool, Unit: UnitGD, AppliedBy: AppliedByGD) -> void:
	match Units.GameState.hero_id:
		1:
			onGainStats(Unit, "health", 1, AppliedBy)
			if is_visible: Unit.Model.on_play_animation("Ability")
