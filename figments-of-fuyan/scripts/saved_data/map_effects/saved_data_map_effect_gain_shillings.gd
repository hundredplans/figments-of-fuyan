class_name SavedDataMapEffectGainShillings extends SavedDataMapEffect

@export var shillings: int

func _init(_id: int = 0, _shillings: int = 0) -> void:
	super(_id)
	shillings = _shillings
