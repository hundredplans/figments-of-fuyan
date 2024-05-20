extends RampageGD

@export var HEAL_MULTIPLIER: int = 2
func onRampageCondition(a: Dictionary) -> bool: return !GameEffects.onGameFXExists(a.Unit, "AbilityActive")
func onRampage(a: Dictionary) -> void:
	a.Unit.setHealMultiplier(HEAL_MULTIPLIER)
	var trigger: Dictionary = GameEffects.onCreateTrigger("Heal", a.Unit.setHealMultiplier, "RemoveFX")
	a.ability = self
	GameEffects.onAddGameFX(a.Unit, "AbilityActive", a, [trigger])
	if a.is_visible: a.Unit.Model.on_play_animation("Ability")
