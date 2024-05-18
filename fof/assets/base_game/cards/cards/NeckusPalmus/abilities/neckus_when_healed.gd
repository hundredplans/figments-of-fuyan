extends WhenHealedGD

func onWhenHealed(a: Dictionary) -> void:
	if !GameEffects.onGameFXExists(a.Unit, "IdleAbility"):
		if a.is_visible: a.Unit.Model.on_play_animation("Ability")
		var AppliedBy := AppliedByGD.new()
		AppliedBy.Applier = a.Unit
		AppliedBy.type = "Ability"
		
		a["AbilityActive"] = []
		a["AbilityActive"].append(GameEffects.onCreateTrigger("EndTurn", null, "RemoveFX"))
		a["AbilityActive"].append(GameEffects.onCreateTrigger("OnHit", Combat.onStagger, "RemoveFX"))
		
		var trigger: Dictionary = GameEffects.onCreateTrigger("NextTurn", GameEffects.onAddGameFX.bind(a.Unit, "AbilityActive", a, a.AbilityActive), "RemoveFX")
		GameEffects.onAddGameFX(a.Unit, "IdleAbility", a, [trigger])
