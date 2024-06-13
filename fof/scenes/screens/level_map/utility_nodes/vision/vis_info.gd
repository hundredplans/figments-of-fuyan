class_name VisInfoGD
extends Resource

# The visible tiles this sees
var tiles: Array
# Dictionary of Unit -> Intent (Exit / enter etc)
var unit_vision: Dictionary
# The total unit_vision, aka if all invis it stays invisible etc
var total_vision: int

enum {
	NULL,
	REGULAR,
	ENTER,
	EXIT,
	INVISIBLE
}

func _init(_tiles: Array = [], _unit_vision: Dictionary = {}, _total_vision: int = REGULAR) -> void:
	tiles = _tiles
	unit_vision = _unit_vision
	total_vision = _total_vision

func isNull() -> bool: return total_vision == NULL
