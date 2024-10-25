@tool
class_name SavedDataRanged extends SavedDataTrait

@export var ranged: int
func _init(_id: int = 2, _first_init: bool = false, _public_id: int = 0, _ranged: int = 0) -> void:
	super(_id, _first_init, _public_id)
	ranged = _ranged
