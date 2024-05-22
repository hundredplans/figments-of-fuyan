extends RampageGD

@export var HEAL_MULTIPLIER: int = 2
func onRampageCondition() -> bool: return !GameEffects.onGameFXExists(Unit, "AbilityActive")
func onRampage() -> void:
	Unit.setHealMultiplier(HEAL_MULTIPLIER)
	var trigger: Dictionary = GameEffects.onCreateTrigger("Heal", Unit.setHealMultiplier, "RemoveFX")
	GameEffects.onAddGameFX(Unit, "AbilityActive", {"ability": self}, [trigger])
	if is_visible: Unit.Model.on_play_animation("Ability")
