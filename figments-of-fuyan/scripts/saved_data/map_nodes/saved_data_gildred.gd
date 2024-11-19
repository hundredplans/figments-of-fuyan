class_name SavedDataGildred extends SavedDataMapNode

@export var selected_map_effects: Array[MapEffectDatastore]

func _init(_id: int = 0, _first_init: bool = false, _public_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _is_entered: bool = false,\
 _is_finished: bool = false, _rotation_y: float = 0, _selected_map_effects: Array[MapEffectDatastore] = []) -> void:
	super(_id, _first_init, _public_id, _map_location, _links, _is_entered, _is_finished, _rotation_y)
	selected_map_effects = _selected_map_effects
