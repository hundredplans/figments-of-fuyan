class_name SavedDataStatusEffect extends SavedData

@export var turns: int # -1 is infinite
@export var coords: Vector4i # Coords of the Card

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _turns: int = 1, _coords := Vector4i.ZERO) -> void:
	super(_id, _first_init, _public_id)
	turns = _turns
	coords = _coords

func getInfoType() -> GDScript: return StatusEffectInfo
