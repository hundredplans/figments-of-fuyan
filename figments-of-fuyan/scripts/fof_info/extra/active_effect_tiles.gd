class_name ActiveEffectTiles extends Resource

@export var in_range_tiles: Array
@export var pickable_tiles: Array

func _init(_in_range_tiles: Array = [], _pickable_tiles: Array = []) -> void:
	in_range_tiles = _in_range_tiles
	pickable_tiles = _pickable_tiles
