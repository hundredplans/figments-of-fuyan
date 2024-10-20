class_name ActiveAbilityDatastore extends ActiveEffectDatastore

@export_group("Ascended")
@export var ascended_exists: bool = true
@export_multiline var ascended_description: String
@export var ascended_max_charges: int = -1
@export_group("")
var Card: CardGD

func getDescription() -> String:
	return description if !Card.ascended else ascended_description
	
func getCharges() -> int:
	return max_charges if !Card.ascended else ascended_max_charges
