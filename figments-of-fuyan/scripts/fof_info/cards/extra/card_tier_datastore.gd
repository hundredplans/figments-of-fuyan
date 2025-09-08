class_name CardTierDatastore extends TierDatastore

@export var attack: int = -1
@export var health: int = -1
@export var speed: int = -1
@export var energy: int = -1
@export var traits: Array[SavedDataTrait]
@export var active_abilities: Array[ActiveEffectDatastore]

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

func getActiveAbilities() -> Array:
	return active_abilities.map(func(x: ActiveEffectDatastore): return x.duplicate())
