class_name SavedDataCard extends SavedDataGameObject

@export var team: int

func _init(_id: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _team: int = 0) -> void:
	super(_id, _coords, _tile_rotation)
	team = _team
	
func getInfoType() -> GDScript: return CardInfo
