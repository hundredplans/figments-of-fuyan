class_name CardTierDatastore extends TierDatastore

@export var attack: int = -1
@export var health: int = -1
@export var speed: int = -1
@export var energy: int = -1
@export var traits: Array[SavedDataTrait]
@export var description_index_for_active_effect_charges: int = -2 # -2 means invalid, -1 means infinite

func getTraits() -> Array[SavedDataTrait]:
	return traits

func getAttack() -> int:
	return attack
	
func getHealth() -> int:
	return health
	
func getSpeed() -> int:
	return speed
	
func getEnergy() -> int:
	return energy
	
func getActiveEffectCharges() -> int:
	if description_index_for_active_effect_charges == -2: return -2
	elif description_index_for_active_effect_charges == -1: return -1
	return description_datastore.getDefaultValue(description_index_for_active_effect_charges)
