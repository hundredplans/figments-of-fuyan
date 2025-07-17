class_name CardInfo extends GameObjectInfo

const FIELD_INFO_SCENE_PATH: String = "res://scenes/game/cards/world/field_info/field_info.tscn"
const INSPECT_CARD_SCREEN: String = "res://scenes/game/cards/ui/inspect_card_screen.tscn"
const CARD_UI_SCENE_PATH: String = "res://scenes/game/cards/ui/card_ui.tscn"
const VISION_RAY_SCENE_PATH: String = "res://scenes/game/cards/world/vision_ray.tscn"
const UNIT_VISIBLE_PARTICLE_SCENE_PATH: String = "res://scenes/particles/unit_visible_particle.tscn"
const BASE_MATERIAL_ASCENDED_PATH: String = "res://resources/materials/game/base_material_ascended_specular.tres"

const BASE_MATERIAL_BROWN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_brown_transparent.tres"
const BASE_MATERIAL_GREEN_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_green_transparent.tres"
const BASE_MATERIAL_RED_TRANSPARENT_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent.tres"

const BASE_MATERIAL_BROWN_TRANSPARENT_ASCENDED_PATH: String = "res://resources/materials/game/base_material_colored/base_material_brown_transparent_ascended.tres"
const BASE_MATERIAL_GREEN_TRANSPARENT_ASCENDED_PATH: String = "res://resources/materials/game/base_material_colored/base_material_green_transparent_ascended.tres"
const BASE_MATERIAL_RED_TRANSPARENT_ASCENDED_PATH: String = "res://resources/materials/game/base_material_colored/base_material_red_transparent_ascended.tres"

const BASE_MATERIAL_SPECULAR_PATH: String = "res://resources/materials/game/base_material_specular.tres"
const BASE_MATERIAL_ASCENDED_SPECULAR_PATH: String = "res://resources/shaders/base_material_ascended_specular.gdshader"

const BASE_MATERIAL_ALPHAGREY_PATH: String = "res://resources/materials/game/base_material_alphagrey_hashing.tres"

@export_group("Card")
@export var tiers: Array[TierDatastore]
@export var attack: int
@export var health: int
@export var speed: int
@export var energy: int
@export var rarity: Game.Rarities
@export var initial_traits: Array[SavedDataTrait]
@export var active_abilities: Array[ActiveAbilityDatastore]
@export_multiline var flavor_text: String
@export_multiline var description: String
@export_multiline var ascended_description: String

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

@export_group("Ascended")
@export var plus_attack: int
@export var plus_health: int
@export var plus_speed: int
@export var plus_energy: int
@export var ascended_traits: Array[SavedDataTrait]
@export_group("")

@export var archetype: ArchetypeInfo

static func getInfoPath() -> String: return "res://resources/fof/cards"

static func getFofName() -> String: return "Card"

func getArtMini() -> Texture2D: return art_mini
func getArtPop() -> ImageTexture: return ImageTexture.create_from_image(art_pop)
func getIcon() -> Texture2D: return art_mini
func getEye() -> float: return eye
func getTop() -> float: return top
func getPoints() -> Array: return points
func getDescription(ascended: bool = false) -> String:
	return description if !ascended else (ascended_description if !ascended_description.is_empty() else description)

func getColoredBaseMaterial(team: int, ascended: bool) -> ShaderMaterial:
	match team:
		0: return load(BASE_MATERIAL_GREEN_TRANSPARENT_PATH if !ascended else BASE_MATERIAL_GREEN_TRANSPARENT_ASCENDED_PATH)
		1: return load(BASE_MATERIAL_RED_TRANSPARENT_PATH if !ascended else BASE_MATERIAL_RED_TRANSPARENT_ASCENDED_PATH)
		2: return load(BASE_MATERIAL_BROWN_TRANSPARENT_PATH if !ascended else BASE_MATERIAL_BROWN_TRANSPARENT_ASCENDED_PATH)
	return null
	
func getTierDatastore(tier: int) -> TierDatastore:
	tier -= 1
	return tiers[tier] if tiers.size() > tier else TierDatastore.new()
	
func getUpdatedTierDatastore(tier: int) -> TierDatastore:
	var tier_datastore := TierDatastore.new()
	for i: int in range(tier - 1, -1, -1):
		var _tier_datastore: TierDatastore = tiers[i] if tiers.size() > i else TierDatastore.new()
		for property: String in ["attack", "health", "speed", "energy"]:
			if tier_datastore[property] == -1:
				tier_datastore[property] = _tier_datastore[property]
		
		if tier_datastore.description.is_empty():
			tier_datastore.description = _tier_datastore.description
			
		if tier_datastore.active_abilities.is_empty() and !_tier_datastore.active_abilities.is_empty():
			tier_datastore.active_abilities = _tier_datastore.active_abilities
			
		if tier_datastore.traits.is_empty() and !_tier_datastore.traits.is_empty():
			tier_datastore.traits = _tier_datastore.traits
			
	return tier_datastore
	
func getStats(tier: int) -> StatsDatastore:
	var tier_datastore: TierDatastore = getUpdatedTierDatastore(tier)
	var attack: int = tier_datastore.getAttack()
	var health: int = tier_datastore.getHealth()
	var speed: int = tier_datastore.getSpeed()
	var energy: int = tier_datastore.getEnergy()
	var stats_datastore := StatsDatastore.new(attack, health, speed, energy)
	return stats_datastore
