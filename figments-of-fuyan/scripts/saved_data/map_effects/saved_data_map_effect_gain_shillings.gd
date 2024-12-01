class_name SavedDataGainShillings extends SavedDataMapEffect

@export var shillings: int

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _shillings: int = 0) -> void:
	super(_id, _first_init)
	id = 2
	shillings = _shillings
