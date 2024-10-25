class_name SavedDataTrait extends SavedData

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0) -> void:
	super(_id, _first_init, _public_id)

func getInfoType() -> GDScript:
	return TraitInfo
