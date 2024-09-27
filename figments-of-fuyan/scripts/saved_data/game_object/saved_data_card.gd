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

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _level_visible: bool = true, _team: int = 0, _attack: int = 0, _health: int = 0,\
	_speed: int = 0, _max_speed: int = 0, _max_health: int = 0, _energy: int = 0, _ascended: bool = false,\
	_draw_order: int = 0, _card_place := Game.CardPlaces.NULL, _turn_state := Game.TurnStates.PASSED) -> void:
	super(_id, _first_init, _coords, _tile_rotation, _level_visible)
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
	
func getInfoType() -> GDScript: return CardInfo
