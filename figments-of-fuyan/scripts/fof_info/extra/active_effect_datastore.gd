class_name ActiveEffectDatastore extends Resource

@export var name: String
@export_multiline var description: String
@export var max_charges: int = -1
@export var delay: float

@export_storage var charges: int
@export_storage var used: bool

var owner: FofGD

func getName() -> String:
	return name

func getDescription() -> String:
	return description
	
func getMaxCharges() -> int:
	return max_charges

func getCharges() -> int:
	return charges
	
func isUsed() -> bool:
	return used
