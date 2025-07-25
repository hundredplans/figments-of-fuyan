class_name ActiveAbilityDatastore extends ActiveEffectDatastore

#@warning_ignore("unused_signal")
#signal update

@export_group("Ascended")
@export_multiline var ascended_description: String
@export var ascended_max_charges: int = -1
@export_group("")

func getDescription() -> String:
	var desc: String = description
	return owner.getActiveEffectDescription(self, desc)
	
func getMaxCharges() -> int:
	return max_charges
