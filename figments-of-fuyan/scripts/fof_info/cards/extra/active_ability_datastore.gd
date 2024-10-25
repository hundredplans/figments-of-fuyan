class_name ActiveAbilityDatastore extends ActiveEffectDatastore

@export var exists: Game.AscendedExists
@export_group("Ascended")
@export_multiline var ascended_description: String
@export var ascended_max_charges: int = -1
@export_group("")

func getDescription() -> String:
	return description if !owner.ascended else ascended_description
	
func getMaxCharges() -> int:
	return max_charges if !owner.ascended else ascended_max_charges
