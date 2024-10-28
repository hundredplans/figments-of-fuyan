class_name SavedDataFieldEffect extends SavedData

@export var fof_object_public_id: int
func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _fof_object_public_id: int = 0) -> void:
	super(_id, _first_init, _public_id)
	fof_object_public_id = _fof_object_public_id

func getInfoType() -> GDScript: return FieldEffectInfo
