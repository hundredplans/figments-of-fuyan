extends GameFXGD

var ability: AbilityGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL),
	]
	Unit.Model.onActivateIdleAbility()
	VFX.onCreateUnitVFX(Unit, "AbilityActive")
	StatusManager.onAddAbilityActiveFX(Unit, ability.ability_name)

func onRemove() -> void:
	Unit.Model.onRemoveIdleAbility()
	VFX.onRemoveUnitVFX(Unit, "AbilityActive")
	StatusManager.onRemoveAbilityActiveFX(Unit, ability.ability_name)
