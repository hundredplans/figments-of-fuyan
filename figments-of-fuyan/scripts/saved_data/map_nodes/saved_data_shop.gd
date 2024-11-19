class_name SavedDataShop extends SavedDataMapNode

@export var available_items: Array
@export var purchased_items: Array

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _is_entered: bool = false, _is_finished: bool = false,\
	_rotation_y: float = 0, _available_items: Array = [], _purchased_items: Array = []) -> void:
	super(_id, _first_init, _public_id, _map_location, _links, _is_entered, _is_finished, _rotation_y)
	available_items = _available_items
	purchased_items = _purchased_items
