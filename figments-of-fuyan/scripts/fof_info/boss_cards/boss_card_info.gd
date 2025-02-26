class_name BossCardInfo extends FofInfo

@export var phase_to_name: Array[String]
@export var rarity: Game.Rarities

@export_group("Stats")
@export var phase_to_attack: Array[int]
@export var phase_to_health: Array[int]
@export var phase_to_speed: Array[int]
@export_group("")

@export_group("Phase To")
@export var phase_to_model: Array[PackedScene] # 0 = Phase One etc
@export var phase_to_collision: Array[PackedScene]
@export var phase_to_points: Array[Array]
@export var phase_to_top: Array[float]
@export var phase_to_eye: Array[float]
@export var phase_to_stat: Array[float]
@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_mini: Texture2D
@export_group("")

@export_group("Gameplay")
@export var awaken_intent_name: String
@export var initial_traits: Array[SavedDataTrait]
@export var phase_to_speed_order_override: Array[SpeedOrderOverride]
@export var phase_to_archetype: Array[ArchetypeInfo]
@export var phase_to_boss_intents: Array[PhaseBossIntents]
@export_group("")

enum SpeedOrderOverride {FIRST, LAST}

const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
const BASE_MATERIAL_ALPHAGREY_PATH: String = "res://resources/materials/game/base_material_alphagrey_hashing.tres"
const BASE_MATERIAL_RED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent.tres"
const BOSS_FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/boss_field_info/boss_field_info.tscn"

static func getInfoPath() -> String: return "res://resources/fof/boss_cards"

static func getFofName() -> String: return "BossCard"

func getIcon() -> Texture2D:
	return art_mini
	
func getName(phase: int = 1) -> String:
	return phase_to_name[phase - 1]
	
func getModel(phase: int = 1) -> PackedScene:
	return phase_to_model[phase - 1]

func getCollisionShape(phase: int = 1) -> PackedScene:
	return phase_to_collision[phase - 1]
	
func getPoints(phase: int = 1) -> Array:
	return phase_to_points[phase - 1]
	
func getTop(phase: int = 1) -> float:
	return phase_to_top[phase - 1]
	
func getEye(phase: int = 1) -> float:
	return phase_to_eye[phase - 1]
	
func getStat(phase: int = 1) -> float:
	return phase_to_stat[phase - 1]
	
func getArchetype(phase: int = 1) -> ArchetypeInfo:
	return phase_to_archetype[phase - 1]
	
func getAttack(phase: int = 1) -> int:
	return phase_to_attack[phase - 1]
	
func getHealth(phase: int = 1) -> int:
	return phase_to_health[phase - 1]
	
func getSpeed(phase: int = 1) -> int:
	return phase_to_speed[phase - 1]
	
func getBossIntents(phase: int = 1) -> PhaseBossIntents:
	return phase_to_boss_intents[phase - 1]
	
func getSpeedOrderOverride(phase: int = 1) -> SpeedOrderOverride:
	return phase_to_speed_order_override[phase - 1]

func getColoredBaseMaterial(_team: int, _ascended: bool) -> ShaderMaterial:
	return load(BASE_MATERIAL_RED_TRANSPARENT_PATH)
