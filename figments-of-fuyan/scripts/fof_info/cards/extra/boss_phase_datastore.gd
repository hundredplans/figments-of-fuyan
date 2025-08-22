class_name BossPhaseDatastore extends Resource

@export var name: String
@export var archetype: ArchetypeInfo

@export var tiers: Array[EpicCardTierDatastore]

@export var model: PackedScene
@export var collision: PackedScene
@export var points: Array[Vector3]

@export var stat: float
@export var top: float
@export var eye: float

@export var speed_order_override: EpicCardInfo.SpeedOrderOverride

@export var env: Environment # If null remains as default for area
@export var change_delay: float
@export var boss_intents: Array[BossIntent]

func getName() -> String:
	return name
	
func getArchetype() -> ArchetypeInfo:
	return archetype
	
func getAttack(tier: int) -> int:
	return tiers[tier - 1].getAttack()

func getHealth(tier: int) -> int:
	return tiers[tier - 1].getHealth()
	
func getSpeed(tier: int) -> int:
	return tiers[tier - 1].getSpeed()
	
func getModel() -> PackedScene:
	return model
	
func getCollision() -> PackedScene:
	return collision
	
func getPoints() -> Array[Vector3]:
	return points

func getStat() -> float:
	return stat
	
func getTop() -> float:
	return top
	
func getEye() -> float:
	return eye

func getSpeedOrderOverride() -> EpicCardInfo.SpeedOrderOverride:
	return speed_order_override
	
func getChangeDelay() -> float:
	return change_delay
	
func getBossIntents() -> Array[BossIntent]:
	return boss_intents
	
func getEnvironment() -> Environment:
	return env
