class_name SavedDataTrait extends SavedData

@export var coords: Vector4i # The coords of the card
func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _coords := Vector4i.ZERO) -> void:
	super(_id, _first_init, _public_id)
	coords = _coords

func getInfoType() -> GDScript:
	return TraitInfo
