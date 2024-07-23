extends GameFXGD

var status_fx: StatusFXGD
var ability: AbilityGD
func onCreateGFX() -> void:
	custom_triggers = [
		TriggerGD.new(self, Unit, onRemove, TriggerGD.REMOVE, TriggerGD.NULL),
	]
	Unit.Model.onActivateIdleAbility()
	VFX.onCreateUnitVFX(Unit, "AbilityActive")
	
	var id: int = 0
	match ability.ability_name:
		"AngrusRampage": id = StatusFXInfoGD.IDS.ANGRUS_RAMPAGE
		"NeckusWhenHealed": id = StatusFXInfoGD.IDS.NECKUS_WHEN_HEALED
		"SwingusOnHit": id = StatusFXInfoGD.IDS.SWINGUS_ON_HIT
	status_fx = StatusManager.onCreateStatusFX(Unit, id)
	StatusManager.onAddAbilityActiveFX(Unit, ability.ability_name)

func onRemove() -> void:
	Unit.Model.onRemoveIdleAbility()
	VFX.onRemoveUnitVFX(Unit, "AbilityActive")
	StatusManager.onRemoveStatusFX(status_fx)
