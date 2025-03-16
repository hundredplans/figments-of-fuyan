class_name BossPhaseDatastore extends Resource

@export var name: String
@export var archetype: ArchetypeInfo

@export var attack: int
@export var health: int
@export var speed: int

@export var model: PackedScene
@export var collision: PackedScene
@export var points: Array[Vector3]

@export var stat: float
@export var top: float
@export var eye: float

@export var awaken_boss_intent_name: String
@export var speed_order_override: EpicCardInfo.SpeedOrderOverride

@export var change_delay: float
@export var boss_intents: Array[BossIntent]

func getName() -> String:
	return name
	
func getArchetype() -> ArchetypeInfo:
	return archetype
	
func getAttack() -> int:
	return attack

func getHealth() -> int:
	return health
	
func getSpeed() -> int:
	return speed
	
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
	
func getAwakenBossIntentName() -> String:
	return awaken_boss_intent_name

func getSpeedOrderOverride() -> EpicCardInfo.SpeedOrderOverride:
	return speed_order_override
	
func getChangeDelay() -> float:
	return change_delay
	
func getBossIntents() -> Array[BossIntent]:
	return boss_intents
