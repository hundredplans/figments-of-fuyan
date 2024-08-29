class_name SavedDataUnit extends SavedDataGameObject

@export var team: int

func _init(_id: int = 0, _variation: int = 0, _coords := Vector4i.ZERO,\
 _tile_rotation: int = 0, _team: int = 0) -> void:
	super(_id, _variation, _coords, _tile_rotation)
	team = _team

func getBaseInfo() -> UnitInfoGD: return Helper.getResourcesRecursiveID(UnitInfoGD, id)
	
