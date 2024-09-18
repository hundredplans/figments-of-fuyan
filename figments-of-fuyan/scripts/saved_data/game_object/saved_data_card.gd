class_name SavedDataCard extends SavedDataGameObject

@export var team: int
@export var is_in_deck: bool
@export var is_in_hand: bool
@export var attack: int
@export var health: int
@export var speed: int
@export var max_health: int
@export var energy: int
@export var ascended: bool

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _level_visible: bool = true, _team: int = 0, _is_in_deck: bool = false, _attack: int = 0, _health: int = 0,\
	_speed: int = 0, _max_health: int = 0, _energy: int = 0, _ascended: bool = false, _is_in_hand: bool = false) -> void:
	super(_id, _first_init, _coords, _tile_rotation, _level_visible)
	team = _team
	is_in_deck = _is_in_deck
	attack = _attack
	health = _health
	speed = _speed
	max_health = _max_health
	energy = _energy
	ascended = _ascended
	is_in_hand = _is_in_hand
	
func getInfoType() -> GDScript: return CardInfo
