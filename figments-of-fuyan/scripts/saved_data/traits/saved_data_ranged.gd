@tool
class_name SavedDataRanged extends SavedDataTrait

@export var ranged: int
func _init(_id: int = 2, _first_init: bool = false, _ranged: int = 0) -> void:
	super(_id, _first_init)
	ranged = _ranged
