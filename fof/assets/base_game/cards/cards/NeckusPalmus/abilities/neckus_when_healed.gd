extends WhenHealedGD

func onWhenHealed() -> void:
	if !GameEffects.onGameFXExists(Unit, "IdleAbility"):
		if is_visible: Unit.Model.on_play_animation("Ability")
		var a: Dictionary = {}
		a["AbilityActive"] = []
		a["AbilityActive"].append(GameEffects.onCreateTrigger("EndTurn", null, "RemoveFX"))
		a["AbilityActive"].append(GameEffects.onCreateTrigger("OnHit", Combat.onStagger, "RemoveFX"))
		
		a.ability = self
		var trigger: Dictionary = GameEffects.onCreateTrigger("NextTurn", GameEffects.onAddGameFX.bind(Unit, "AbilityActive", a, a.AbilityActive), "RemoveFX")
		GameEffects.onAddGameFX(Unit, "IdleAbility", a, [trigger])
