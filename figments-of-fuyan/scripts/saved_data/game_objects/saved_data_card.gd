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
@export var field_traits: Array
@export var status_effects: Array
@export var attacks: int
@export var attack_range: int
@export var delayed_stats: Array[StatInfo]
@export var visible_game_objects_public_ids: Array
@export var ability_save: Dictionary
@export var active_effects: Array[ActiveEffectDatastore]
@export var tool_data: SavedDataTool
@export var field_effects: Array
@export var anibility_datastore: AnibilityDatastore
@export var temporary_card_conditions: Array
@export var is_awakened_in_combat: bool
@export var max_movement_height: float
@export var last_seen_violence: int
@export var last_ignore_behaviour_roll: bool
@export var base_stats: StatsDatastore

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _vision_datastore := VisionDatastore.new(), _team: int = 0, _ascended: bool = false, _attack: int = 0, _health: int = 0,\
	_speed: int = 0, _max_speed: int = 0, _max_health: int = 0, _energy: int = 0,\
	_draw_order: int = 0, _card_place := Game.CardPlaces.NULL, _turn_state := Game.TurnStates.NULL, _field_traits: Array = [],\
	_status_effects: Array = [], _attacks: int = 0, _attack_range: int = 1, _delayed_stats: Array[StatInfo] = [], _visible_game_objects_public_ids: Array = [],\
	_ability_save: Dictionary = {}, _active_effects: Array[ActiveEffectDatastore] = [], _tool_data: SavedDataTool = null,\
	_field_effects: Array = [], _anibility_datastore := AnibilityDatastore.new(), _temporary_card_conditions: Array = [],\
	_is_awakened_in_combat: bool = false, _last_seen_violence: int = -1, _last_ignore_behaviour_roll: bool = false,\
	_base_stats: StatsDatastore = null) -> void:
		
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
	field_traits = _field_traits
	status_effects = _status_effects
	attacks = _attacks
	attack_range = _attack_range
	delayed_stats = _delayed_stats
	visible_game_objects_public_ids = _visible_game_objects_public_ids
	ability_save = _ability_save
	active_effects = _active_effects
	tool_data = _tool_data
	field_effects = _field_effects
	anibility_datastore = _anibility_datastore
	temporary_card_conditions = _temporary_card_conditions
	is_awakened_in_combat = _is_awakened_in_combat
	last_seen_violence = _last_seen_violence
	last_ignore_behaviour_roll = _last_ignore_behaviour_roll
	base_stats = _base_stats
	
func getInfoType() -> GDScript: return CardInfo
