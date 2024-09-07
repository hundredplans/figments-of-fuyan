class_name SavedDataMapNodeGildred extends SavedDataMapNode

@export var selected_map_effects: Array[MapEffectDatastore]

func _init(_id: int = 0, _map_location: MapLocation = null, _links: Array = [], _selected_map_effects: Array[MapEffectDatastore] = []) -> void:
	super(_id, _map_location, _links)
	selected_map_effects = _selected_map_effects
