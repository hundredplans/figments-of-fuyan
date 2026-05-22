class_name CardInfo extends GameObjectInfo

const FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/field_info/field_info.tscn"
const INSPECT_CARD_SCREEN: String = "res://scenes/game/cards/ui/inspect_card_screen.tscn"
const CARD_UI_SCENE_PATH: String = "res://scenes/game/cards/ui/card_ui.tscn"
const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
const UNIT_VISIBLE_PARTICLE_SCENE_PATH: String = "res://scenes/particles/unit_visible_particle.tscn"

const BASE_MATERIAL_BROWN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_brown_transparent.tres"
const BASE_MATERIAL_GREEN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_green_transparent.tres"
const BASE_MATERIAL_RED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent.tres"
const BASE_MATERIAL_PASSED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_grey_transparent.tres"
const BASE_MATERIAL_SPECULAR_PATH: String = "res://resources/materials/game/base_material_specular.tres"
const BASE_MATERIAL_ALPHAGREY_PATH: String = "res://resources/materials/game/base_material_alphagrey_hashing.tres"

@export var tiers: Array[CardTierDatastore]
@export var archetype: ArchetypeInfo

@export_group("Card")
@export var rarity: Game.Rarities
@export_multiline var flavor_text: String
@export_group("")

@export_group("Art")
@export var art_mini_coordinate: Vector2i
@export var art_mini: Texture2D
@export var art_pop: Image
@export_group("")

@export_group("3D")
@export var model: PackedScene
@export var points: Array
@export var collision_shape: PackedScene
@export_group("")

@export_group("Height")
@export var stat: float
@export var top: float
@export var eye: float
@export_group("")

@export_group("Audio")
@export var attack_audio: AudioStream
@export var awaken_audio: AudioStream
@export var death_audio: AudioStream
@export var hurt_audio: AudioStream
@export_group("")

static func getInfoPath() -> String: return "res://resources/fof/cards"

static func getFofName() -> String: return "Card"

func getArtMini() -> Texture2D: return art_mini
func getArtPop() -> ImageTexture: return ImageTexture.create_from_image(art_pop)
func getIcon() -> Texture2D: return art_mini
func getEye() -> float: return eye
func getTop() -> float: return top
func getPoints() -> Array: return points


func getDescription(tier: int = 1, use_default_values: bool = false) -> String:
	return getTierDatastore(tier).getDescription(use_default_values)

func getTierDatastore(tier: int) -> CardTierDatastore:
	tier -= 1
	return tiers[tier] if tiers.size() > tier else CardTierDatastore.new()
	
func getStats(tier: int) -> StatsDatastore:
	var tier_datastore: CardTierDatastore = getTierDatastore(tier)
	var _attack: int = tier_datastore.getAttack()
	var _health: int = tier_datastore.getHealth()
	var _speed: int = tier_datastore.getSpeed()
	var _energy: int = tier_datastore.getEnergy()
	var stats_datastore := StatsDatastore.new(_attack, _health, _speed, _energy)
	return stats_datastore

func getColoredBaseMaterial(team: int) -> ShaderMaterial:
	match team:
		0: return load(BASE_MATERIAL_GREEN_TRANSPARENT_PATH)
		1: return load(BASE_MATERIAL_RED_TRANSPARENT_PATH)
		2: return load(BASE_MATERIAL_BROWN_TRANSPARENT_PATH)
	return null
	
func getPassedBaseMaterial() -> ShaderMaterial:
	return load(BASE_MATERIAL_PASSED_TRANSPARENT_PATH)
	
func getAwakenAudio() -> AudioStream: return awaken_audio
func getDeathAudio() -> AudioStream: return death_audio
func getHurtAudio() -> AudioStream: return hurt_audio
func getAttackAudio() -> AudioStream: return attack_audio
