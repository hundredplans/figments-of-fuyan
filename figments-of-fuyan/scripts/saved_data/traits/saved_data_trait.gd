class_name SavedDataTrait extends SavedData

@export var coords: Vector4i # The coords of the card
func _init(_id: int = 0, _first_init: bool = false, _coords := Vector4i.ZERO) -> void:
	super(_id, _first_init)
	coords = _coords

func getInfoType() -> GDScript:
	return TraitInfo
