class_name SavedDataArmor extends SavedDataTrait

@export var armor: int
func _init(_id: int = 1, _first_init: bool = false, _public_id: int = 0, _armor: int = 0) -> void:
	super(_id, _first_init, _public_id)
	armor = _armor
