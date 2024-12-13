class_name SavedDataArchetype extends SavedData

func _init(_id = 0, _first_init: bool = false, _public_id = 0):
	super(_id, _first_init, _public_id)

func getInfoType() -> GDScript: return FofInfo
