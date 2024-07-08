extends WhenHealedGD

func onWhenHealed() -> void:
	if !GameEffects.onGameFXExists(Unit, GameFXGD.ABILITY_ACTIVE):
		if is_visible: Unit.Model.on_play_animation("Ability")
		var OnHit := TriggerGD.new(null, Unit, onNeckusHit, TriggerGD.ON_HIT, TriggerGD.REMOVE_FX)
		var a: Dictionary = {"ability": self}
		GameEffects.addGFX(Unit, GameFXGD.ABILITY_ACTIVE, a, [OnHit])
		Unit.onChangeAIStat("aic", 2)

func onNeckusHit(Defender: UnitGD, AppliedBy: AppliedByGD) -> void:
	GameEffects.addGFX(Defender, GameFXGD.STAGGER)
	Unit.onResetAIStat("aic")
