class_name SavedDataStatusEffect extends SavedData

@export var turns: int # -1 is infinite
@export var creator_public_id: int
@export var ability_save: Dictionary

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _turns: int = 1, _creator_public_id: int = 0, _ability_save: Dictionary = {}) -> void:
	super(_id, _first_init, _public_id)
	turns = _turns
	ability_save = _ability_save
	creator_public_id = _creator_public_id

func getInfoType() -> GDScript: return StatusEffectInfo
