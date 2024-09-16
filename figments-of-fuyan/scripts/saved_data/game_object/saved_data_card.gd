class_name SavedDataCard extends SavedDataGameObject

@export var team: int
@export var is_in_deck: bool

func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _team: int = 0, _is_in_deck: bool = false) -> void:
	super(_id, _first_init, _coords, _tile_rotation)
	team = _team
	is_in_deck = _is_in_deck
	
func getInfoType() -> GDScript: return CardInfo
