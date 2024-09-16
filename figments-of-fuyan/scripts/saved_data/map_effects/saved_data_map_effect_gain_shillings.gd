class_name SavedDataMapEffectGainShillings extends SavedDataMapEffect

@export var shillings: int

func _init(_id: int = 0, _first_init: bool = false, _shillings: int = 0) -> void:
	super(_id, _first_init)
	shillings = _shillings
