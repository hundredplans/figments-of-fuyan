class_name EpicCardInfo extends FofInfo

@export var rarity: Game.Rarities
@export var phases: Array[BossPhaseDatastore]

@export_group("Rewards")
@export var card_id: int
@export var tool_id: int
@export var boon_id: int
@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_mini: Texture2D
@export_group("")

@export var awaken_boss_intent_name: String

enum SpeedOrderOverride {FIRST, LAST}

const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
const BASE_MATERIAL_ALPHAGREY_PATH: String = "res://resources/materials/game/base_material_alphagrey_hashing.tres"
const BASE_MATERIAL_RED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent.tres"
const BOSS_FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/boss_field_info/boss_field_info.tscn"

const BASE_MATERIAL_SPECULAR_PATH: String = "res://resources/materials/game/base_material_specular.tres"

static func getInfoPath() -> String: return "res://resources/fof/epic_cards"

static func getFofName() -> String: return "EpicCard"

func getIcon() -> Texture2D:
	return art_mini
	
func getName(phase: int = 1) -> String:
	return phases[phase - 1].getName()
	
func getModel(phase: int = 1) -> PackedScene:
	return phases[phase - 1].getModel()

func getCollisionShape(phase: int = 1) -> PackedScene:
	return phases[phase - 1].getCollision()
	
func getPoints(phase: int = 1) -> Array:
	return phases[phase - 1].getPoints()
	
func getTop(phase: int = 1) -> float:
	return phases[phase - 1].getTop()
	
func getEye(phase: int = 1) -> float:
	return phases[phase - 1].getEye()
	
func getStat(phase: int = 1) -> float:
	return phases[phase - 1].getStat()
	
func getArchetype(phase: int = 1) -> ArchetypeInfo:
	return phases[phase - 1].getArchetype()
	
func getAttack(phase: int = 1) -> int:
	return phases[phase - 1].getAttack()
	
func getHealth(phase: int = 1) -> int:
	return phases[phase - 1].getHealth()
	
func getSpeed(phase: int = 1) -> int:
	return phases[phase - 1].getSpeed()
	
func getBossIntents(phase: int = 1) -> Array[BossIntent]:
	return phases[phase - 1].getBossIntents()
	
func getSpeedOrderOverride(phase: int = 1) -> SpeedOrderOverride:
	return phases[phase - 1].getSpeedOrderOverride()

func getColoredBaseMaterial(_team: int, _ascended: bool) -> ShaderMaterial:
	return load(BASE_MATERIAL_RED_TRANSPARENT_PATH)
	
func getChangeDelay(phase: int = 1) -> float:
	return phases[phase - 1].getChangeDelay()
	
func getEnvironment(phase: int = 1) -> Environment:
	return phases[phase - 1].getEnvironment()
	
func getAwakenBossIntentName() -> String:
	return awaken_boss_intent_name
