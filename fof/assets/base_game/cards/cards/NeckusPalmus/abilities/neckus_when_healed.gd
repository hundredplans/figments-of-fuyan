extends WhenHealedGD

func onWhenHealed() -> void:
	if !GameEffects.onGameFXExists(Unit, GameFXGD.ABILITY_ACTIVE):
		if is_visible: Unit.Model.on_play_animation("Ability")
		var OnHit := TriggerGD.new(null, Unit, Combat.onStagger, TriggerGD.ON_HIT, TriggerGD.REMOVE_FX)
		var a: Dictionary = {"ability": self}
		GameEffects.onAddGameFX(Unit, GameFXGD.ABILITY_ACTIVE, a, [OnHit])
