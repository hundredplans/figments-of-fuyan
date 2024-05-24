extends RampageGD

@export var HEAL_MULTIPLIER: int = 2
func onRampageCondition() -> bool: return !GameEffects.onGameFXExists(Unit, "AbilityActive")
func onRampage() -> void:
	Unit.setHealMultiplier(HEAL_MULTIPLIER)
	var Trigger := TriggerGD.new(null, Unit, Unit.setHealMultiplier, TriggerGD.HEAL, TriggerGD.REMOVE_FX)
	GameEffects.onAddGameFX(Unit, GameFXGD.ABILITY_ACTIVE, {"ability": self}, [Trigger])
	if is_visible: Unit.Model.on_play_animation("Ability")
