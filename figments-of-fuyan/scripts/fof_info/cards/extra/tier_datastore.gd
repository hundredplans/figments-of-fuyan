class_name TierDatastore extends Resource
# For each if the new value isn't set it takes the value from the previous tier
@export var attack: int = -1
@export var health: int = -1
@export var speed: int = -1
@export var energy: int = -1

@export_multiline var description: String
@export var active_abilities: Array[ActiveEffectDatastore]
@export var traits: Array[SavedDataTrait]

func getAttack() -> int:
	return attack
	
func getHealth() -> int:
	return health
	
func getSpeed() -> int:
	return speed
	
func getEnergy() -> int:
	return energy
	
func getDescription() -> String:
	return description
	
func getActiveAbilities() -> Array[ActiveEffectDatastore]:
	return active_abilities
	
func getTraits() -> Array[SavedDataTrait]:
	return traits
	
