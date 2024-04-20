extends RampageGD

func onRampage(Unit: UnitGD) -> void:
	match Unit.Units.GameState.hero_id:
		1:
			onGainStats(Unit, "health", 1, self)
			Unit.Model.on_play_animation("Ability")
