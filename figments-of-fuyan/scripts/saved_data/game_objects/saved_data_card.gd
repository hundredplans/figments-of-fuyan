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
@export var attacks: bool
@export var delayed_stats: Array[StatAction]
@export var visible_game_objects_public_ids: Array
@export var ability_save: Dictionary
@export var active_abilities: Array[ActiveAbilityDatastore]

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _level_visible: bool = true, _is_revealed: bool = false, _team: int = 0, _attack: int = 0, _health: int = 0,\
	_speed: int = 0, _max_speed: int = 0, _max_health: int = 0, _energy: int = 0, _ascended: bool = false,\
	_draw_order: int = 0, _card_place := Game.CardPlaces.NULL, _turn_state := Game.TurnStates.PASSED, _field_traits: Array = [],\
	_status_effects: Array = [], _attacks: int = 0,  _delayed_stats: Array[StatAction] = [], _visible_game_objects_public_ids: Array = [],\
	_ability_save: Dictionary = {}, _active_abilities: Array[ActiveAbilityDatastore] = []) -> void:
		
	super(_id, _first_init, _public_id, _coords, _tile_rotation, _level_visible, _is_revealed)
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
	delayed_stats = _delayed_stats
	visible_game_objects_public_ids = _visible_game_objects_public_ids
	ability_save = _ability_save
	active_abilities = _active_abilities
	
func getInfoType() -> GDScript: return CardInfo
