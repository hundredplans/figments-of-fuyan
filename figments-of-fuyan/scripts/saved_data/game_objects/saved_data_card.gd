class_name SavedDataCard extends SavedDataGameObject

@export var team: int
@export var attack: int
@export var health: int
@export var speed: int
@export var max_speed: int
@export var max_health: int
@export var energy: int
@export var ascended: bool
@export var draw_order: int
@export var card_place: Game.CardPlaces
@export var turn_state: Game.TurnStates
@export var status_effects: Array
@export var attacks: int
@export var attack_range: int
@export var delayed_stats: Array
@export var ability_save: Dictionary
@export var active_effects: Array[ActiveEffectDatastore]
@export var tool_data: SavedDataTool
@export var field_effects: Array
@export var anibility_datastore: AnibilityDatastore
@export var is_temporary: bool
@export var is_awakened_in_combat: bool
@export var max_movement_height: float
@export var ai_datastore: AIDatastore
@export var base_stats: StatsDatastore
@export var overworld_traits: Array[OverworldTrait]
@export var bounty_kills: BountyKills
@export var boss_datastore: BossDatastore
@export var card_offset: CardOffset
@export var champion_datastore: ChampionDatastore

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _vision_datastore := VisionDatastoreCard.new(), _team: int = 0, _ascended: bool = false, _attack: int = 0, _health: int = 0,\
	_speed: int = 0, _max_speed: int = 0, _max_health: int = 0, _energy: int = 0,\
	_draw_order: int = 0, _card_place := Game.CardPlaces.NULL, _turn_state := Game.TurnStates.NULL,\
	_status_effects: Array = [], _attacks: int = 0, _attack_range: int = 1, _delayed_stats: Array = [],\
	_ability_save: Dictionary = {}, _active_effects: Array[ActiveEffectDatastore] = [], _tool_data: SavedDataTool = null,\
	_field_effects: Array = [], _anibility_datastore := AnibilityDatastore.new(), _is_temporary: bool = false,\
	_is_awakened_in_combat: bool = false, _ai_datastore := AIDatastore.new(),\
	_base_stats: StatsDatastore = null, _overworld_traits: Array[OverworldTrait] = [], _bounty_kills := BountyKills.new(),\
	_boss_datastore: BossDatastore = null, _card_offset := CardOffset.new(), _champion_datastore := ChampionDatastore.new()) -> void:
		
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _vision_datastore)
	
	team = _team
	attack = _attack
	health = _health
	speed = _speed
	max_health = _max_health
	max_speed = _max_speed
	energy = _energy
	ascended = _ascended
	card_place = _card_place
	draw_order = _draw_order
	turn_state = _turn_state
	status_effects = _status_effects
	attacks = _attacks
	attack_range = _attack_range
	delayed_stats = _delayed_stats
	ability_save = _ability_save
	active_effects = _active_effects
	tool_data = _tool_data
	field_effects = _field_effects
	anibility_datastore = _anibility_datastore
	is_temporary = _is_temporary
	is_awakened_in_combat = _is_awakened_in_combat
	ai_datastore = _ai_datastore
	base_stats = _base_stats
	overworld_traits = _overworld_traits
	bounty_kills = _bounty_kills
	boss_datastore = _boss_datastore
	card_offset = _card_offset
	champion_datastore = _champion_datastore
	
func getInfoType() -> GDScript: return CardInfo
func setBaseStats(stat_datastore: StatsDatastore) -> void:
	base_stats = stat_datastore
	attack = stat_datastore.attack
	health = stat_datastore.health
	speed = stat_datastore.speed
	max_speed = stat_datastore.speed
	max_health = stat_datastore.health
	energy = stat_datastore.energy
