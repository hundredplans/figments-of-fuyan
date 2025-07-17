class_name SavedDataTrait extends SavedData

@export var display_number: int = -1
func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _display_number: int = -1) -> void:
	super(_id, _first_init, _public_id)
	display_number = _display_number

func getInfoType() -> GDScript:
	return TraitInfo
