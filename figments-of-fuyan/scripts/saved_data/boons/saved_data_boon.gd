class_name SavedDataBoon extends SavedData

@export var ascended: bool
@export var charges: int
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _ascended: bool = false, _charges: int = 0, _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id)
	ascended = _ascended
	charges = _charges
	ability_save = _ability_save

func getInfoType() -> GDScript: return BoonInfo
