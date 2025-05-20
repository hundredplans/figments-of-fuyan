class_name SavedDataFieldEffect extends SavedData

@export var fof_object_public_id: int
@export var charges: int
@export var turns: int
@export var display_number: int
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _fof_object_public_id: int = 0, _charges: int = -1, _turns: int = -1,\
	_display_number: int = -1, _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id)
	fof_object_public_id = _fof_object_public_id
	turns = _turns
	charges = _charges
	display_number = _display_number
	ability_save = _ability_save

func getInfoType() -> GDScript: return FieldEffectInfo
