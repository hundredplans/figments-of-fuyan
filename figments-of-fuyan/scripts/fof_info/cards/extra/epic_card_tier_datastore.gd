class_name EpicCardTierDatastore extends TierDatastore
	
@export var attack: int = -1
@export var health: int = -1
@export var speed: int = -1
@export var energy: int = -1

func getAttack() -> int:
	return attack
	
func getHealth() -> int:
	return health
	
func getSpeed() -> int:
	return speed
	
func getEnergy() -> int:
	return energy
